import SwiftUI
import Foundation
import SwiftData
import UIKit
import PhotosUI
import UserNotifications
import UniformTypeIdentifiers
import Combine
import MetricKit
import TipKit

// MARK: - Person Detail

struct Detail: View {
    @Bindable var person: Person

    @Environment(\.modelContext)
    private var context

    @State private var editPerson = false
    @State private var editingIdea: Idea?
    @State private var ideaPendingDeletion: Idea?
    @State private var hiddenIdeaIDs: Set<UUID> = []
    @State private var lastDeletedIdea: Idea?
    @State private var searchWishes = false
    @State private var statusFilter: IdeaStatus?

    @AppStorage("wishDisplayStyle")
    private var displayStyleRawValue = WishDisplayStyle.grid.rawValue

    @State private var pinnedIdeaIDs: [UUID] = []
    @State private var selectedCategoryRoute: CategorySheetRoute?
    @State private var cachedIdeas: [Idea] = []
    @State private var isWishSaveHighlighted = false

    private var firstName: String {
        person.name
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)
            ?? person.name
    }

    private var displayStyle: WishDisplayStyle {
        WishDisplayStyle(
            rawValue: displayStyleRawValue
        ) ?? .grid
    }

    private var displayStyleBinding: Binding<WishDisplayStyle> {
        Binding(
            get: {
                displayStyle
            },
            set: { newValue in
                displayStyleRawValue =
                    newValue.rawValue
            }
        )
    }

    private var pinStorageKey: String {
        "pinnedWishIDs.\(person.id.uuidString)"
    }

    private var sortedIdeas: [Idea] {
        let newestFirst = cachedIdeas.isEmpty && !person.ideas.isEmpty
            ? person.ideas.sorted { $0.created > $1.created }
            : cachedIdeas

        let ideasByID = Dictionary(
            uniqueKeysWithValues: newestFirst.map { ($0.id, $0) }
        )

        let pinned = pinnedIdeaIDs.compactMap { ideasByID[$0] }
        let pinnedSet = Set(pinnedIdeaIDs)

        return pinned + newestFirst.filter {
            !pinnedSet.contains($0.id)
        }
    }

    private var givenCount: Int {
        cachedIdeas.lazy.filter { $0.status == "Given" }.count
    }

    private var visibleIdeas: [Idea] {
        let available = sortedIdeas.filter { !hiddenIdeaIDs.contains($0.id) }
        guard let statusFilter else {
            return available
        }

        return available.filter { $0.status == statusFilter.title }
    }

    private var nextMoment: String {
        guard person.birthday != nil else {
            return "None"
        }

        if person.countdown == "A special day today" {
            return "Today"
        }

        return person.countdown
            .replacingOccurrences(
                of: "Birthday in ",
                with: ""
            )
    }

    var body: some View {
        detailNavigation
    }

    private var detailNavigation: some View {
        detailDialogs
            .navigationTitle("\(firstName)’s AwwList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { editPerson = true }
                }
            }
    }

    private var detailDialogs: some View {
        detailSheets
    }

    private var detailSheets: some View {
        detailCore
            .sheet(isPresented: $editPerson) {
                PersonForm(person: person)
            }
            .sheet(isPresented: $searchWishes) {
                WishSearch()
            }
            .sheet(item: $editingIdea) { idea in
                WishDetail(person: person, idea: idea)
            }
            .sheet(item: $selectedCategoryRoute) { route in
                if let categoryID = route.categoryID {
                    CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
                } else if let legacyName = route.legacyName {
                    CategoryWishesSheet(category: legacyName)
                }
            }
    }

    private var detailCore: some View {
        ZStack {
            Backdrop()
            detailScrollView
            composerOverlay
        }
        .awwStableForFloatingKeyboard()
        .onAppear {
            loadPinnedIdeaIDs()
            refreshIdeaCache()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .awwDataDidChange)
        ) { _ in
            refreshIdeaCache()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .awwWishSaved)
        ) { notification in
            let ids = notification.object as? [UUID] ?? []
            guard ids.contains(person.id) else { return }

            isWishSaveHighlighted = true
            Task {
                try? await Task.sleep(for: .milliseconds(240))
                await MainActor.run {
                    withAnimation(.easeOut(duration: 1.35)) {
                        isWishSaveHighlighted = false
                    }
                }
            }
        }

    }

    private var detailScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                profileHeader
                metrics

                GiftGridHeader(
                    search: { searchWishes = true },
                    selectedStatus: $statusFilter,
                    displayStyle: displayStyleBinding
                )

                wishesContent
            }
            .frame(maxWidth: AwwAppLimits.detailMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 110)
            .background(AwwRefreshControlBranding())
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    dismissKeyboard()
                }
            )
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            await refreshPerson()
        }
    }

    @ViewBuilder
    private var wishesContent: some View {
        if visibleIdeas.isEmpty {
            emptyIdeas
        } else {
            switch displayStyle {
            case .grid:
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 10),
                        GridItem(.flexible(minimum: 0), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(visibleIdeas) { idea in
                        wishRow(
                            idea,
                            layout: .grid
                        )
                    }
                }

            case .list:
                LazyVStack(spacing: 10) {
                    ForEach(visibleIdeas) { idea in
                        wishRow(
                            idea,
                            layout: .list
                        )
                    }
                }
            }
        }
    }

    private func wishRow(
        _ idea: Idea,
        layout: WishBubbleLayout
    ) -> some View {
        GiftMessageBubble(
            idea: idea,
            layout: layout,
            isPinned:
                pinnedIdeaIDs.contains(
                    idea.id
                ),
            onCategoryTap: { category in
                selectedCategoryRoute = CategorySheetRoute(legacyName: category)
            }
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .contentShape(
            .rect(
                cornerRadius: 21
            )
        )
        .onTapGesture {
            editingIdea = idea
        }
        .accessibilityLabel(
            idea.title.isEmpty
                ? "Edit wish"
                : "Edit \(idea.title)"
        )
        .accessibilityHint(
            "Opens the wish directly in note editing mode"
        )
        .contextMenu {
            if pinnedIdeaIDs.contains(
                idea.id
            ) {
                Button(
                    "Unpin",
                    systemImage: "pin.slash"
                ) {
                    togglePin(idea)
                }
            } else {
                Button(
                    pinnedIdeaIDs.count >= 2
                        ? "Pin to top · 2 max"
                        : "Pin to top",
                    systemImage: "pin"
                ) {
                    togglePin(idea)
                }
                .disabled(
                    pinnedIdeaIDs.count >= 2
                )
            }

            Menu("Move to status") {
                ForEach(IdeaStatus.allCases) { status in
                    Button(status.title) {
                        idea.status = status.title
                        idea.updated = .now
                        AwwHaptics.selection()
                    }
                }
            }

            Button("Copy app link", systemImage: "link") {
                AwwDeepLink.copy(AwwDeepLink.wish(idea.id))
            }

            Button("Copy text", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = displayTextWithoutCategoryHashtags(idea.title)
                AwwHaptics.success()
            }

            Button(
                "Delete",
                systemImage: "trash",
                role: .destructive
            ) {
                ideaPendingDeletion = idea
                deletePendingIdea()
            }
        }
        .transition(
            .scale(
                scale: 0.88,
                anchor: .bottomLeading
            )
            .combined(with: .opacity)
        )
    }

    private var composerOverlay: some View {
        VStack(spacing: 8) {
            Spacer()

            if let idea = lastDeletedIdea, hiddenIdeaIDs.contains(idea.id) {
                AwwUndoCard(message: "Wish deleted") {
                    undoDelete(idea)
                }
                .frame(maxWidth: AwwAppLimits.composerMaxWidth)
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            InlineWishComposer(person: person)
                .frame(maxWidth: AwwAppLimits.composerMaxWidth)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .animation(.snappy(duration: 0.22), value: hiddenIdeaIDs)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    private var deletionDialogBinding: Binding<Bool> {
        Binding(
            get: { ideaPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    ideaPendingDeletion = nil
                }
            }
        )
    }

    private func deletePendingIdea() {
        guard let idea = ideaPendingDeletion else { return }
        let id = idea.id
        withAnimation(.snappy(duration: 0.22)) {
            hiddenIdeaIDs.insert(id)
            lastDeletedIdea = idea
            self.ideaPendingDeletion = nil
        }
        AwwHaptics.deleted()

        Task {
            try? await Task.sleep(for: .seconds(8))
            await MainActor.run {
                guard hiddenIdeaIDs.contains(id) else { return }
                pinnedIdeaIDs.removeAll { $0 == id }
                persistPinnedIdeaIDs()
                idea.attachments.forEach(context.delete)
                context.delete(idea)
                hiddenIdeaIDs.remove(id)
                if lastDeletedIdea?.id == id { lastDeletedIdea = nil }
                _ = AwwPersistence.save(context)
            }
        }
    }

    private func undoDelete(_ idea: Idea) {
        withAnimation(.snappy(duration: 0.22)) {
            hiddenIdeaIDs.remove(idea.id)
            if lastDeletedIdea?.id == idea.id { lastDeletedIdea = nil }
        }
        AwwHaptics.success()
    }

    private func refreshPerson() async {
        await Task.yield()
        loadPinnedIdeaIDs()
        refreshIdeaCache()
        try? await Task.sleep(for: .milliseconds(650))
    }

    private func refreshIdeaCache() {
        cachedIdeas = person.ideas.sorted { $0.created > $1.created }
    }

    private func togglePin(
        _ idea: Idea
    ) {
        withAnimation(.snappy) {
            if let index = pinnedIdeaIDs.firstIndex(
                of: idea.id
            ) {
                pinnedIdeaIDs.remove(
                    at: index
                )
            } else {
                guard pinnedIdeaIDs.count < 2 else {
                    return
                }

                pinnedIdeaIDs.append(
                    idea.id
                )
            }

            persistPinnedIdeaIDs()
        }
    }

    private func loadPinnedIdeaIDs() {
        let savedIDs = UserDefaults.standard
            .stringArray(
                forKey: pinStorageKey
            )
            ?? []

        let validIdeaIDs = Set(
            person.ideas.map {
                $0.id
            }
        )

        let restored = savedIDs
            .compactMap {
                UUID(uuidString: $0)
            }
            .filter {
                validIdeaIDs.contains($0)
            }

        pinnedIdeaIDs = Array(
            restored.prefix(2)
        )

        persistPinnedIdeaIDs()
    }

    private func persistPinnedIdeaIDs() {
        UserDefaults.standard.set(
            pinnedIdeaIDs.map(
                \.uuidString
            ),
            forKey: pinStorageKey
        )
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Avatar(
                person: person,
                size: 86
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                HStack(alignment: .center, spacing: 8) {
                    Text(person.name)
                        .font(
                            .largeTitle
                                .weight(.bold)
                        )

                    WishCountBadge(
                        count: person.ideas.count,
                        avatarSize: 86,
                        isProminent: true,
                        isSaveHighlighted: isWishSaveHighlighted
                    )
                }

                Text(person.relation)
                    .foregroundStyle(.coral)

                Text(person.countdown)
                    .font(.subheadline)
                    .foregroundStyle(.soft)
            }

            Spacer()
        }
    }

    private var metrics: some View {
        HStack {
            metric(
                String(person.ideas.count),
                "Saved"
            )

            metric(
                String(givenCount),
                "Given"
            )

            metric(
                nextMoment,
                "Next moment"
            )
        }
        .padding()
        .background(
            .regularMaterial,
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
    }

    private var emptyIdeas: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(.red)

            Text("Nothing saved yet")
                .font(.headline)

            Text(
                "Add the first little clue whenever something comes up."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            .regularMaterial,
            in: RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
    }

    private func metric(
        _ value: String,
        _ label: String
    ) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(.soft)
        }
        .frame(maxWidth: .infinity)
    }
}
