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
// MARK: - Person Form

struct PersonForm: View {
    let person: Person?

    @Environment(\.modelContext)
    private var context

    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \Occasion.date)
    private var occasions: [Occasion]

    @State private var name: String
    @State private var relation: String
    @State private var birthday: Date
    @State private var birthdayEnabled: Bool
    @State private var emoji: String
    @State private var profileImage: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isPhotoPickerPresented = false
    @State private var isEmojiPickerPresented = false
    @State private var isAvatarSourcePresented = false
    @State private var hasCustomEmoji: Bool
    @State private var birthdayReminderEnabled: Bool
    @State private var birthdayReminderOffsets: [Int]
    @State private var momentDrafts: [MomentDraft] = []
    @State private var didLoadMomentDrafts = false
    @State private var suggestionIndex: Int
    @State private var showDiscardChanges = false
    @State private var didSave = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    init(person: Person? = nil) {
        self.person = person

        let initialName = person?.name ?? ""
        let initialRelation = person?.relation ?? "Friend"
        let initialHasCustomEmoji = person.map {
            !isAutomaticAvatarFallback(
                $0.emoji,
                forName: $0.name
            )
        } ?? false
        let initialEmoji = initialHasCustomEmoji
            ? (person?.emoji ?? "")
            : suggestedAvatarEmoji(
                for: initialName,
                relation: initialRelation
            )

        _name = State(initialValue: initialName)
        _relation = State(initialValue: initialRelation)
        _birthday = State(initialValue: person?.birthday ?? .now)
        _birthdayEnabled = State(initialValue: person?.birthday != nil)
        _emoji = State(initialValue: initialEmoji)
        _profileImage = State(initialValue: person?.profileImage)
        _hasCustomEmoji = State(initialValue: initialHasCustomEmoji)
        let initialBirthdayOffsets: [Int]
        if let person {
            initialBirthdayOffsets = person.birthdayReminderOffsets
        } else {
            initialBirthdayOffsets = [5, 3, 0]
        }
        _birthdayReminderEnabled = State(
            initialValue: person?.birthdayReminderEnabled ?? true
        )
        _birthdayReminderOffsets = State(
            initialValue: initialBirthdayOffsets
        )
        _suggestionIndex = State(initialValue: 0)
    }

    private var isEditing: Bool {
        person != nil
    }

    private var existingMoments: [Occasion] {
        guard let person else {
            return []
        }

        return occasions.filter {
            $0.participantIDs.contains(person.id)
        }
    }

    private var momentsChanged: Bool {
        guard didLoadMomentDrafts else { return false }

        let saved = existingMoments
            .map { MomentDraft($0) }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        let draft = momentDrafts
            .sorted { $0.id.uuidString < $1.id.uuidString }

        return saved != draft
    }

    private var hasUnsavedChanges: Bool {
        guard !didSave else { return false }

        if let person {
            return name != person.name
                || relation != person.relation
                || birthdayEnabled != (person.birthday != nil)
                || (birthdayEnabled && person.birthday != birthday)
                || resolvedEmoji != person.emoji
                || profileImage != person.profileImage
                || birthdayReminderEnabled != person.birthdayReminderEnabled
                || birthdayReminderOffsets != person.birthdayReminderOffsets
                || momentsChanged
        }

        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || relation != "Friend"
            || birthdayEnabled
            || profileImage != nil
            || hasCustomEmoji
            || !momentDrafts.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                ContactProfileHeader(
                    name: $name,
                    previewEmoji: resolvedEmoji,
                    profileImage: profileImage,
                    avatarAccent: resolvedAccent,
                    chooseAvatar: {
                        isAvatarSourcePresented = true
                    }
                )

                ContactDetailsSection(relation: $relation)

                ContactMomentsSection(
                    birthday: $birthday,
                    birthdayEnabled: $birthdayEnabled,
                    birthdayReminderEnabled: $birthdayReminderEnabled,
                    birthdayReminderOffsets: $birthdayReminderOffsets,
                    moments: $momentDrafts
                )
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isEditing ? "Edit person" : "Add person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            AwwHaptics.warning()
                            showDiscardChanges = true
                        } else {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        savePerson()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .isEmpty
                    )
                }
            }
            .confirmationDialog(
                "Choose avatar",
                isPresented: $isAvatarSourcePresented,
                titleVisibility: .visible
            ) {
                Button("Choose Emoji") {
                    profileImage = nil
                    isEmojiPickerPresented = true
                }

                Button("Suggest Another Emoji") {
                    suggestAnotherEmoji()
                }

                Button("Choose Photo") {
                    isPhotoPickerPresented = true
                }

                if profileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        profileImage = nil
                        AwwHaptics.soft()
                    }
                }
            }
            .photosPicker(
                isPresented: $isPhotoPickerPresented,
                selection: $selectedPhoto,
                matching: .images
            )
            .task(id: selectedPhoto) {
                guard let selectedPhoto,
                      let imageData = try? await selectedPhoto.loadTransferable(
                        type: Data.self
                      ) else {
                    return
                }

                profileImage = imageData
                AwwHaptics.soft()
            }
            .sheet(isPresented: $isEmojiPickerPresented) {
                EmojiPicker(
                    emoji: $emoji,
                    hasCustomEmoji: $hasCustomEmoji
                )
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
            .alert("Discard unsaved changes?", isPresented: $showDiscardChanges) {
                Button("Keep editing", role: .cancel) {}
                Button("Discard", role: .destructive) { dismiss() }
            } message: {
                Text("Your unsaved changes will be lost.")
            }
            .alert("Couldn’t save this person", isPresented: $showSaveError) {
                Button("Try again") { savePerson() }
                Button("Keep editing", role: .cancel) {}
            } message: {
                Text(
                    saveErrorMessage.isEmpty
                    ? "Your edits are still on this screen. Nothing was intentionally deleted."
                    : saveErrorMessage
                )
            }
            .onAppear {
                loadMomentDraftsIfNeeded()
            }
        }
    }

    private func loadMomentDraftsIfNeeded() {
        guard !didLoadMomentDrafts else { return }
        momentDrafts = existingMoments.map { MomentDraft($0) }
        didLoadMomentDrafts = true
    }

    private func savePerson() {
        let cleanName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !cleanName.isEmpty else { return }

        do {
            let account = try AwwAccountManager.ensureLocalAccount(context: context)
            let savedPerson: Person

            if let person {
                person.ownerUserID = account.id
                person.name = cleanName
                person.relation = person.isOwner ? "Me" : relation
                person.birthday = birthdayEnabled ? birthday : nil
                person.emoji = resolvedEmoji
                person.accent = resolvedAccent
                person.profileImage = profileImage
                person.birthdayReminderEnabled =
                    birthdayEnabled && birthdayReminderEnabled
                person.birthdayReminderOffsets =
                    birthdayEnabled && birthdayReminderEnabled
                    ? birthdayReminderOffsets
                    : []
                person.updated = .now

                if person.isOwner {
                    account.displayName = cleanName
                    account.updatedAt = .now
                }

                savedPerson = person
            } else {
                let newPerson = Person(
                    cleanName,
                    relation: relation,
                    birthday: birthdayEnabled ? birthday : nil,
                    emoji: resolvedEmoji,
                    profileImage: profileImage,
                    birthdayReminderEnabled:
                        birthdayEnabled && birthdayReminderEnabled,
                    birthdayReminderOffsets:
                        birthdayEnabled && birthdayReminderEnabled
                        ? birthdayReminderOffsets
                        : [],
                    ownerUserID: account.id
                )

                newPerson.accent = resolvedAccent
                context.insert(newPerson)
                savedPerson = newPerson
            }

            let existingByID = Dictionary(
                uniqueKeysWithValues: existingMoments.map { ($0.id, $0) }
            )
            let draftIDs = Set(momentDrafts.map(\.id))

            for existing in existingMoments where !draftIDs.contains(existing.id) {
                context.delete(existing)
            }

            var savedMoments: [Occasion] = []

            for draft in momentDrafts {
                let cleanTitle = draft.title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                guard !cleanTitle.isEmpty else { continue }

                if let existing = existingByID[draft.id] {
                    existing.ownerUserID = account.id
                    existing.title = cleanTitle
                    existing.date = draft.date
                    existing.reminderOffsets = draft.reminderOffsets
                    existing.participantIDs = [savedPerson.id]
                    existing.updated = .now
                    savedMoments.append(existing)
                } else {
                    let newMoment = Occasion(
                        title: cleanTitle,
                        date: draft.date,
                        reminderOffsets: draft.reminderOffsets,
                        participantIDs: [savedPerson.id],
                        ownerUserID: account.id
                    )
                    newMoment.id = draft.id
                    context.insert(newMoment)
                    savedMoments.append(newMoment)
                }
            }

            try context.save()

            // Do not dismiss until the just-written row can be fetched back from the
            // same local store. This makes a failed Add Person impossible to look like
            // a successful save.
            let persistedPeople = try context.fetch(FetchDescriptor<Person>())
            guard persistedPeople.contains(where: { $0.id == savedPerson.id }) else {
                saveErrorMessage = "AwwList could not read the new person back from the local database. Nothing was discarded, so you can try again."
                AwwHaptics.warning()
                showSaveError = true
                return
            }

            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            AwwShareBridge.mirrorPeople(
                persistedPeople.filter { $0.deletedAt == nil }
            )

            Task {
                await NotificationScheduler.synchronize(
                    person: savedPerson,
                    occasions: savedMoments
                )
            }

            didSave = true
            saveErrorMessage = ""
            AwwHaptics.success()
            dismiss()
        } catch {
            saveErrorMessage = "Your person is still on this screen. The local save failed: \(error.localizedDescription)"
            AwwHaptics.warning()
            showSaveError = true
        }
    }

    private var resolvedEmoji: String {
        let trimmedEmoji = emoji.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if hasCustomEmoji, !trimmedEmoji.isEmpty {
            return trimmedEmoji
        }

        let suggestion = suggestedAvatarEmoji(
            for: name,
            relation: relation,
            offset: suggestionIndex
        )

        if !suggestion.isEmpty {
            return suggestion
        }

        let initials = personInitials(from: name)
        return initials.isEmpty ? "🎈" : initials
    }

    private var resolvedAccent: String {
        let savedAccent = person?.accent
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if let savedAccent,
           !savedAccent.isEmpty,
           savedAccent != "coral",
           savedAccent != "red" {
            return savedAccent
        }

        return suggestedAvatarAccent(
            for: name,
            relation: relation
        )
    }

    private func suggestAnotherEmoji() {
        suggestionIndex += 1
        hasCustomEmoji = false
        profileImage = nil
        emoji = suggestedAvatarEmoji(
            for: name,
            relation: relation,
            offset: suggestionIndex
        )
    }
}


struct ContactProfileHeader: View {
    @Binding var name: String
    let previewEmoji: String
    let profileImage: Data?
    let avatarAccent: String
    let chooseAvatar: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        Section {
            VStack(spacing: 14) {
                Button(action: chooseAvatar) {
                    Group {
                        if let profileImage,
                           let image = AwwImageCache.shared.image(
                            from: profileImage,
                            maxPixelSize: 420
                           ) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Text(previewEmoji)
                                .font(.system(size: 58))
                        }
                    }
                    .frame(width: 132, height: 132)
                    .background(palette.fill, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(palette.ring, lineWidth: 1)
                    }
                    .clipShape(Circle())
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(9)
                            .background(.red, in: Circle())
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose avatar")
                .accessibilityHint("Choose a photo or emoji")

                Text("Choose emoji or photo")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TextField("Name", text: $name)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($isNameFocused)
                    .frame(height: 44)
                    .accessibilityLabel("Name")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .listRowBackground(Color.clear)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(220))
            isNameFocused = true
        }
    }

    private var palette: PersonAvatarPalette {
        personAvatarPalette(
            accent: avatarAccent,
            name: name
        )
    }
}


struct ContactDetailsSection: View {
    @Binding var relation: String

    private let relationships = ["Partner", "Family", "Friend", "Colleague", "Other"]

    var body: some View {
        Section("Contact details") {
            Picker("Relationship", selection: $relation) {
                ForEach(relationships, id: \.self) { relationship in
                    Text(relationship)
                }
            }
        }
    }
}


struct MomentDraft: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var reminderOffsets: [Int]

    init(
        id: UUID = UUID(),
        title: String = "Anniversary",
        date: Date = .now,
        reminderOffsets: [Int] = [5, 3, 0]
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.reminderOffsets = reminderOffsets
    }

    init(_ occasion: Occasion) {
        id = occasion.id
        title = occasion.title
        date = occasion.date
        reminderOffsets = occasion.reminderOffsets
    }
}


struct ContactMomentsSection: View {
    @Binding var birthday: Date
    @Binding var birthdayEnabled: Bool
    @Binding var birthdayReminderEnabled: Bool
    @Binding var birthdayReminderOffsets: [Int]
    @Binding var moments: [MomentDraft]

    var body: some View {
        Section {
            birthdayFields
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(
                    EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
                )

            ForEach($moments) { $moment in
                momentFields($moment)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(
                        EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
                    )
            }

            Button {
                withAnimation(.snappy(duration: 0.22)) {
                    moments.append(MomentDraft())
                }
                AwwHaptics.selection()
            } label: {
                Label("Add another moment", systemImage: "plus.circle.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }
            .listRowSeparator(.hidden)
        } header: {
            Text("Moments")
        } footer: {
            Text("Add the dates worth remembering. Each one can have its own reminders.")
        }
    }

    private var birthdayFields: some View {
        momentCard {
            HStack(spacing: 12) {
                Text("Title")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Birthday")
                    .font(.body.weight(.semibold))
            }

            DatePicker(
                "Date",
                selection: Binding(
                    get: { birthday },
                    set: { newDate in
                        birthday = newDate
                        birthdayEnabled = true
                        if birthdayReminderOffsets.isEmpty {
                            birthdayReminderOffsets = [5, 3, 0]
                        }
                        birthdayReminderEnabled = true
                    }
                ),
                displayedComponents: .date
            )

            ReminderOffsetPicker(
                selection: Binding(
                    get: {
                        birthdayReminderEnabled
                            ? birthdayReminderOffsets
                            : []
                    },
                    set: { newValue in
                        birthdayEnabled = true
                        birthdayReminderOffsets = newValue
                        birthdayReminderEnabled = !newValue.isEmpty
                    }
                )
            )
        }
    }

    private func momentFields(
        _ moment: Binding<MomentDraft>
    ) -> some View {
        momentCard {
            HStack(spacing: 12) {
                Text("Title")
                    .foregroundStyle(.secondary)

                TextField("Anniversary", text: moment.title)
                    .multilineTextAlignment(.trailing)
            }

            DatePicker(
                "Date",
                selection: moment.date,
                displayedComponents: .date
            )

            ReminderOffsetPicker(
                selection: moment.reminderOffsets
            )

            HStack {
                Spacer()

                Button(role: .destructive) {
                    let id = moment.wrappedValue.id
                    withAnimation(.snappy(duration: 0.22)) {
                        moments.removeAll { $0.id == id }
                    }
                    AwwHaptics.warning()
                } label: {
                    Label("Remove moment", systemImage: "trash")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func momentCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding(15)
        .background(
            Color.secondary.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }
}


struct ReminderOffsetPicker: View {
    @Binding var selection: [Int]

    private let options = [5, 3, 0]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reminders")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { offset in
                        Button {
                            toggle(offset)
                            AwwHaptics.selection()
                        } label: {
                            reminderChip(
                                Self.label(for: offset),
                                selected: selection.contains(offset)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(
                            selection.contains(offset) ? .isSelected : []
                        )
                    }

                    Button {
                        selection.removeAll()
                        AwwHaptics.selection()
                    } label: {
                        reminderChip(
                            "No reminders",
                            selected: selection.isEmpty
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(
                        selection.isEmpty ? .isSelected : []
                    )
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func reminderChip(
        _ title: String,
        selected: Bool
    ) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                selected
                    ? Color.red
                    : Color.secondary.opacity(0.12),
                in: Capsule()
            )
            .foregroundStyle(
                selected ? Color.white : Color.primary
            )
    }

    nonisolated static func summary(for offsets: [Int]) -> String {
        let labels = offsets.sorted(by: >).map(label(for:))
        return labels.isEmpty ? "No reminders" : labels.joined(separator: " • ")
    }

    nonisolated static func label(for offset: Int) -> String {
        offset == 0 ? "On the day" : "\(offset) days before"
    }

    private func toggle(_ offset: Int) {
        if let index = selection.firstIndex(of: offset) {
            selection.remove(at: index)
        } else {
            selection.append(offset)
            selection.sort(by: >)
        }
    }
}


struct EmojiPicker: View {
    @Environment(\.dismiss)
    private var dismiss

    @Binding var emoji: String
    @Binding var hasCustomEmoji: Bool

    private static let categories: [EmojiPickerCategory] = [
        .init(
            id: "family",
            title: "Family & relationships",
            emojis: ["👩", "👨", "🧑", "👦", "👧", "🧒", "👶", "👵", "👴", "🫶", "❤️", "💍"]
        ),
        .init(
            id: "style",
            title: "Style & favorites",
            emojis: ["🧢", "🍓", "🌷", "🎈", "🎧", "🌼", "🪩", "🍒", "🪴", "🧁", "🎨", "🦋", "💄", "👜", "👠", "💅", "🎀", "⌚️", "👔", "🥾"]
        ),
        .init(
            id: "work",
            title: "Work & occupations",
            emojis: ["🧑‍⚕️", "👩‍🏫", "👨‍🍳", "🧑‍💻", "👩‍🔧", "👨‍🎨", "👩‍🚒", "👨‍✈️", "🧑‍🌾", "👩‍⚖️", "👨‍🔬", "🧑‍🚀"]
        ),
        .init(
            id: "sports",
            title: "Sports & adventure",
            emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏎️", "🏍️", "🚴", "🏊‍♀️", "🏋️‍♂️", "🥊", "🏕️", "🎣", "⛷️", "🏄"]
        ),
        .init(
            id: "tools",
            title: "Tools & interests",
            emojis: ["🔨", "🔧", "🪚", "🧰", "🛠️", "⚙️", "📚", "🎮", "🎸", "📷", "☕️", "🐾"]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    TextField(
                        "Any emoji",
                        text: Binding(
                            get: { emoji },
                            set: {
                                emoji = $0
                                hasCustomEmoji = true
                            }
                        )
                    )
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    ForEach(Self.categories) { category in
                        EmojiPickerCategorySection(
                            category: category,
                            emoji: $emoji,
                            hasCustomEmoji: $hasCustomEmoji
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Choose emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct EmojiPickerCategory: Identifiable {
    let id: String
    let title: LocalizedStringResource
    let emojis: [String]
}

private struct EmojiPickerCategorySection: View {
    let category: EmojiPickerCategory

    @Binding var emoji: String
    @Binding var hasCustomEmoji: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.title)
                .font(.headline)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 16
            ) {
                ForEach(category.emojis, id: \.self) { suggestion in
                    Button(suggestion) {
                        emoji = suggestion
                        hasCustomEmoji = true
                    }
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}

