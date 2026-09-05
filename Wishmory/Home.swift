import SwiftUI
import SwiftData
import UIKit
import TipKit

// MARK: - Home

struct CategorySheetRoute: Identifiable, Equatable {
    let id: UUID
    let categoryID: UUID?
    let fallbackName: String?
    let legacyName: String?

    init(categoryID: UUID, name: String? = nil) {
        self.id = categoryID
        self.categoryID = categoryID
        self.fallbackName = name
        self.legacyName = nil
    }

    init(legacyName: String) {
        self.id = UUID()
        self.categoryID = nil
        self.fallbackName = legacyName
        self.legacyName = legacyName
    }
}

struct Home: View {
    @EnvironmentObject private var routes: NotificationRouteCoordinator

    @Environment(\.modelContext)
    private var context

    @Environment(\.colorScheme)
    private var colorScheme

    @Query(sort: \Person.created)
    private var people: [Person]

    @Query(sort: \Idea.created, order: .reverse)
    private var ideas: [Idea]

    @Query(sort: \Category.createdAt)
    private var categoryRecords: [Category]

    @AppStorage("showFirstGiftTip")
    private var showFirstGiftTip = false

    @AppStorage(NotificationScheduler.openIdeaComposerKey)
    private var openIdeaComposer = false

    @State private var addPerson = false
    @State private var searchWishes = false
    @State private var selectedPersonIDs: Set<UUID> = []
    @State private var isComposerFocused = false
    @State private var composerFocusRequest = false
    @State private var settings = false
    @State private var personPendingHistoryClear: Person?
    @State private var personPendingRemoval: Person?
    @State private var editingHomeIdea: Idea?
    @State private var selectedHomeCategoryRoute: CategorySheetRoute?
    @State private var deepLinkedPerson: Person?
    @State private var deepLinkedIdea: Idea?
    @State private var deepLinkedCategoryRoute: CategorySheetRoute?
    @State private var hiddenPersonIDs: Set<UUID> = []
    @State private var lastRemovedPerson: Person?
    @State private var homeCategorySummariesCache: [WishCategorySummary] = []
    @State private var savedPulsePersonIDs: Set<UUID> = []
    @State private var savedToastText: String?
    @State private var foregroundReminder: AwwForegroundReminder?

    private var sortedPeople: [Person] {
        people.filter { $0.deletedAt == nil && !hiddenPersonIDs.contains($0.id) }.sorted { first, second in
            if first.isOwner != second.isOwner {
                return first.isOwner
            }

            return first.created < second.created
        }
    }

    private var shouldShowAddFriendPlaceholder: Bool {
        !isComposerFocused && sortedPeople.count <= 2
    }

    private var recentWishGroups: [RecentWishGroup] {
        var groups: [RecentWishGroup] = []

        for idea in ideas.prefix(AwwAppLimits.recentWishScanLimit) {
            guard let person = idea.person else { continue }

            if let index = groups.firstIndex(where: { group in
                recentWishContentKey(group.idea) == recentWishContentKey(idea)
                    && abs(group.idea.created.timeIntervalSince(idea.created)) < 4
            }) {
                if !groups[index].people.contains(where: { $0.id == person.id }) {
                    groups[index].people.append(person)
                }
            } else {
                groups.append(
                    RecentWishGroup(
                        idea: idea,
                        people: [person]
                    )
                )
            }

            if groups.count >= 12 {
                break
            }
        }

        return Array(groups.prefix(8))
    }

    private var homeCategorySummaries: [WishCategorySummary] {
        homeCategorySummariesCache
    }

    var body: some View {
        homeWithAlerts
    }

    private var homeBase: some View {
        NavigationStack {
            homeLayout
                .awwStableForFloatingKeyboard()
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 1) {
                            Text("AwwList")
                                .font(.headline.weight(.bold))

                            Text("A place for little wants and wishes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture(perform: dismissComposerFocus)
                    }

                    homeToolbar
                }
        }
    }

    private var homeWithSheets: some View {
        homeBase
            .sheet(isPresented: $addPerson) {
                PersonForm()
            }
            .sheet(isPresented: $searchWishes) {
                WishSearch()
            }
            .sheet(isPresented: $settings) {
                Settings()
            }
            .sheet(item: $editingHomeIdea) { idea in
                if let person = idea.person {
                    WishDetail(person: person, idea: idea)
                }
            }
            .sheet(item: $selectedHomeCategoryRoute) { route in
                categoryWishesSheet(for: route)
            }
            .sheet(item: $deepLinkedPerson) { person in
                NavigationStack { Detail(person: person) }
            }
            .sheet(item: $deepLinkedIdea) { idea in
                if let person = idea.person {
                    WishDetail(person: person, idea: idea)
                }
            }
            .sheet(item: $deepLinkedCategoryRoute) { route in
                categoryWishesSheet(for: route)
            }
    }

    private var homeWithEvents: some View {
        homeWithSheets
            .onChange(of: isComposerFocused) { _, isFocused in
                if isFocused {
                    selectedPersonIDs = Set(sortedPeople.map(\.id))
                }
            }
            .onChange(of: openIdeaComposer, initial: true) { _, shouldOpen in
                guard shouldOpen else { return }
                selectedPersonIDs = Set(sortedPeople.map(\.id))
                composerFocusRequest.toggle()
                openIdeaComposer = false
            }
            .onChange(of: routes.pendingURL, initial: true) { _, url in
                guard let url, openDeepLink(url) else { return }
                routes.consume()
            }
            .onReceive(NotificationCenter.default.publisher(for: .awwOpenDeepLink)) { notification in
                guard let url = notification.object as? URL else { return }
                routes.handle(url: url)
                if openDeepLink(url) {
                    routes.consume()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .awwDataDidChange)) { _ in
                refreshHomeCategorySummaries()
                AwwShareBridge.mirrorPeople(sortedPeople)
                AwwWidgetBridge.refresh(people: sortedPeople, ideas: ideas)
            }
            .onReceive(NotificationCenter.default.publisher(for: .awwWishSaved)) {
                handleWishSavedFeedback($0)
            }
            .onReceive(NotificationCenter.default.publisher(for: .awwForegroundReminder)) { notification in
                guard let reminder = notification.object as? AwwForegroundReminder else { return }
                presentForegroundReminder(reminder)
            }
            .task {
                refreshHomeCategorySummaries()
                AwwShareBridge.mirrorPeople(sortedPeople)
                AwwWidgetBridge.refresh(people: sortedPeople, ideas: ideas)
                AwwShareBridge.importPendingShares(context: context, people: sortedPeople)
                retryPendingDeepLink()
            }
            .onChange(of: people.count) { _, _ in
                retryPendingDeepLink()
                AwwShareBridge.mirrorPeople(sortedPeople)
                AwwShareBridge.importPendingShares(context: context, people: sortedPeople)
            }
            .onChange(of: ideas.count) { _, _ in
                retryPendingDeepLink()
                AwwWidgetBridge.refresh(people: sortedPeople, ideas: ideas)
            }
            .onChange(of: categoryRecords.count) { _, _ in
                retryPendingDeepLink()
            }
    }

    private var homeWithAlerts: some View {
        homeWithEvents
            .alert("Clear this profile’s wish history?", isPresented: historyClearConfirmation) {
                Button(role: .cancel) {
                    personPendingHistoryClear = nil
                } label: {
                    Text("Cancel")
                        .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                }
                .keyboardShortcut(.defaultAction)

                Button("Clear wish history", role: .destructive) {
                    clearHistory()
                }
            } message: {
                Text("This removes all saved wishes for this person and lets you start fresh.")
            }
            .alert("Remove this person?", isPresented: personRemovalConfirmation) {
                Button(role: .cancel) {
                    personPendingRemoval = nil
                } label: {
                    Text("Cancel")
                        .foregroundStyle(colorScheme == .light ? Color.white : Color.black)
                }
                .keyboardShortcut(.defaultAction)

                Button("Remove person", role: .destructive) {
                    removePerson()
                }
            } message: {
                Text("Their profile and saved wish history will be removed.")
            }
    }

    @ViewBuilder
    private func categoryWishesSheet(for route: CategorySheetRoute) -> some View {
        if let categoryID = route.categoryID {
            CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
        } else if let legacyName = route.legacyName {
            CategoryWishesSheet(category: legacyName)
        }
    }

    private var homeLayout: some View {
        ZStack(alignment: .top) {
            Backdrop()

            TopPageGradient()
                .allowsHitTesting(false)

            homeScrollView
        }
    }

    private var homeScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .background(AwwRefreshControlBranding())
            .animation(.snappy(duration: 0.24), value: isComposerFocused)
            .frame(maxWidth: AwwAppLimits.contentMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: dismissComposerFocus)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await refreshHome()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                if let person = lastRemovedPerson, hiddenPersonIDs.contains(person.id) {
                    AwwUndoCard(message: "Person removed") {
                        undoRemovePerson(person)
                    }
                    .frame(maxWidth: AwwAppLimits.composerMaxWidth)
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if let foregroundReminder {
                    Button {
                        if let url = foregroundReminder.url {
                            openDeepLink(url)
                        }
                        self.foregroundReminder = nil
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(foregroundReminder.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                if !foregroundReminder.body.isEmpty {
                                    Text(foregroundReminder.body)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }

                            Spacer(minLength: 4)

                            if foregroundReminder.url != nil {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if let savedToastText {
                    Text(savedToastText)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(.regularMaterial, in: Capsule())
                        .transition(.scale(scale: 0.94).combined(with: .opacity))
                }

                composer
            }
            .animation(.snappy(duration: 0.22), value: hiddenPersonIDs)
        }
    }

   

    private var composer: some View {
        InlineWishComposer(
            people: sortedPeople,
            selectedPersonIDs: $selectedPersonIDs,
            requestFocus: $composerFocusRequest
        ) { isFocused in
            if isComposerFocused != isFocused {
                isComposerFocused = isFocused
            }
        }
        .frame(maxWidth: AwwAppLimits.composerMaxWidth)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    @ToolbarContentBuilder
    private var homeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismissComposerFocus()
                searchWishes = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Search wishes")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismissComposerFocus()
                settings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Settings")
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 22) {
            peopleHeader
            peopleGrid

            if !isComposerFocused {
                if !recentWishGroups.isEmpty {
                    recentlyAddedSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if !homeCategorySummaries.isEmpty {
                    categoriesSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if showFirstGiftTip {
                    FirstGiftTip {
                        showFirstGiftTip = false
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .animation(.snappy(duration: 0.24), value: isComposerFocused)
    }

    private var peopleHeader: some View {
        PeopleSectionHeader(
            isSelecting: isComposerFocused,
            selectedCount: selectedPersonIDs.count,
            allSelected:
                !sortedPeople.isEmpty
                && selectedPersonIDs.count == sortedPeople.count,
            addPerson: {
                dismissComposerFocus()
                addPerson = true
            },
            done: dismissComposerFocus,
            toggleAll: {
                if selectedPersonIDs.count == sortedPeople.count {
                    selectedPersonIDs.removeAll()
                } else {
                    selectedPersonIDs = Set(sortedPeople.map(\.id))
                }
                AwwHaptics.selection()
            }
        )
    }

    private var peopleGrid: some View {
        LazyVGrid(
            columns: peopleColumns,
            spacing: 20
        ) {
            ForEach(sortedPeople) { person in
                personCell(person)
            }

            if shouldShowAddFriendPlaceholder {
                Button {
                    dismissComposerFocus()
                    addPerson = true
                } label: {
                    AddFriendPlaceholderTile()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add a friend")
            }
        }
    }

    private var peopleColumns: [GridItem] {
        [
            GridItem(
                .adaptive(minimum: 92, maximum: 132),
                spacing: 12,
                alignment: .top
            )
        ]
    }

    @ViewBuilder
    private func personCell(_ person: Person) -> some View {
        if isComposerFocused {
            SelectablePersonTile(
                person: person,
                isSelected: selectedPersonIDs.contains(person.id),
                isSaveHighlighted: savedPulsePersonIDs.contains(person.id),
                toggleSelection: {
                    toggleSelection(for: person)
                },
                dismissKeyboard: {
                    dismissComposerFocus()
                }
            )
            .accessibilityLabel(person.name)
            .accessibilityValue(
                selectedPersonIDs.contains(person.id)
                    ? "Selected"
                    : "Not selected"
            )
            .scaleEffect(
                savedPulsePersonIDs.contains(person.id) ? 1.06 : 1
            )
            .animation(
                .spring(response: 0.24, dampingFraction: 0.72),
                value: savedPulsePersonIDs
            )
        } else {
            NavigationLink {
                Detail(person: person)
            } label: {
                PersonTile(
                    person: person,
                    isSaveHighlighted: savedPulsePersonIDs.contains(person.id)
                )
            }
            .tint(.primary)
            .scaleEffect(
                savedPulsePersonIDs.contains(person.id) ? 1.06 : 1
            )
            .animation(
                .spring(response: 0.24, dampingFraction: 0.72),
                value: savedPulsePersonIDs
            )
            .contextMenu {
                Button("Add wish", systemImage: "plus.circle") {
                    selectedPersonIDs = [person.id]
                    composerFocusRequest.toggle()
                }

                Button("Copy app link", systemImage: "link") {
                    AwwDeepLink.copy(AwwDeepLink.person(person.id))
                }

                Button("Clear wish history", systemImage: "arrow.counterclockwise") {
                    AwwHaptics.warning()
                    personPendingHistoryClear = person
                }

                if !person.isOwner {
                    Button("Remove person", systemImage: "trash", role: .destructive) {
                        AwwHaptics.warning()
                        personPendingRemoval = person
                    }
                }
            }
            .accessibilityHint(
                "Long press for profile options"
            )
        }
    }

    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart")
                    .font(.subheadline.weight(.semibold))
                Text("Recently added")
                    .font(.headline.weight(.semibold))
            }

            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(recentWishGroups) { group in
                        RecentWishBubbleCard(group: group) {
                            editingHomeIdea = group.idea
                        }
                        .frame(width: 178)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
            }
            .contentMargins(.horizontal, 1)
            .scrollIndicators(.hidden)
        }
    }

    private var categoriesSection: some View {
        HStack(alignment: .firstTextBaseline) {
            HStack(spacing: 6) {
                Image(systemName: "tag")
                    .font(.subheadline.weight(.semibold))
                Text("Categories")
                    .font(.headline.weight(.semibold))
            }

            Spacer()

            NavigationLink {
                CategoriesView()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("View all categories")
        }
    }

    private var historyClearConfirmation: Binding<Bool> {
        Binding(
            get: { personPendingHistoryClear != nil },
            set: { isPresented in
                if !isPresented {
                    personPendingHistoryClear = nil
                }
            }
        )
    }

    private var personRemovalConfirmation: Binding<Bool> {
        Binding(
            get: { personPendingRemoval != nil },
            set: { isPresented in
                if !isPresented {
                    personPendingRemoval = nil
                }
            }
        )
    }

    private func clearHistory() {
        guard let person = personPendingHistoryClear else {
            return
        }

        withAnimation(.snappy) {
            for idea in person.ideas {
                idea.attachments.forEach(context.delete)
                context.delete(idea)
            }
            personPendingHistoryClear = nil
        }
        _ = AwwPersistence.save(context)
    }

    private func removePerson() {
        guard let person = personPendingRemoval, !person.isOwner else {
            personPendingRemoval = nil
            return
        }
        let id = person.id
        withAnimation(.snappy(duration: 0.22)) {
            hiddenPersonIDs.insert(id)
            lastRemovedPerson = person
            personPendingRemoval = nil
        }
        AwwHaptics.deleted()

        Task {
            try? await Task.sleep(for: .seconds(8))
            await MainActor.run {
                guard hiddenPersonIDs.contains(id) else { return }
                for idea in person.ideas {
                    idea.attachments.forEach(context.delete)
                    context.delete(idea)
                }
                context.delete(person)
                hiddenPersonIDs.remove(id)
                if lastRemovedPerson?.id == id { lastRemovedPerson = nil }
                _ = AwwPersistence.save(context)
            }
        }
    }

    private func undoRemovePerson(_ person: Person) {
        withAnimation(.snappy(duration: 0.22)) {
            hiddenPersonIDs.remove(person.id)
            if lastRemovedPerson?.id == person.id { lastRemovedPerson = nil }
        }
        AwwHaptics.success()
    }

    private func toggleSelection(for person: Person) {
        if selectedPersonIDs.contains(person.id) {
            selectedPersonIDs.remove(person.id)
            AwwHaptics.light()
        } else {
            selectedPersonIDs.insert(person.id)
            AwwHaptics.light()
        }
    }

    private func handleWishSavedFeedback(_ notification: Notification) {
        let ids = notification.object as? [UUID] ?? []
        let names = notification.userInfo?["names"] as? [String] ?? []

        withAnimation(.snappy(duration: 0.2)) {
            savedPulsePersonIDs = Set(ids)
            if names.count == 1, let name = names.first {
                savedToastText = "Saved for \(name)"
            } else if names.count > 1 {
                savedToastText = "Saved for \(names.count) people"
            } else {
                savedToastText = "Wish saved"
            }
        }

        Task {
            try? await Task.sleep(for: .milliseconds(240))
            await MainActor.run {
                withAnimation(.easeOut(duration: 1.35)) {
                    savedPulsePersonIDs.removeAll()
                }
            }

            try? await Task.sleep(for: .milliseconds(760))
            await MainActor.run {
                withAnimation(.snappy(duration: 0.2)) {
                    savedToastText = nil
                }
            }
        }
    }

    private func presentForegroundReminder(_ reminder: AwwForegroundReminder) {
        withAnimation(.snappy(duration: 0.22)) {
            foregroundReminder = reminder
        }

        let reminderID = reminder.id
        Task {
            try? await Task.sleep(for: .seconds(5))
            await MainActor.run {
                guard foregroundReminder?.id == reminderID else { return }
                withAnimation(.snappy(duration: 0.2)) {
                    foregroundReminder = nil
                }
            }
        }
    }

    private func refreshHome() async {
        await Task.yield()
        refreshHomeCategorySummaries()
        AwwShareBridge.mirrorPeople(sortedPeople)
        AwwShareBridge.importPendingShares(context: context, people: sortedPeople)
        retryPendingDeepLink()
        try? await Task.sleep(for: .milliseconds(650))
    }

    private func refreshHomeCategorySummaries() {
        homeCategorySummariesCache = Array(
            wishCategorySummaries(from: ideas, categories: categoryRecords).prefix(5)
        )
    }

    @discardableResult
    private func openDeepLink(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == AwwDeepLink.scheme else { return false }
        let kind = url.host?.lowercased() ?? ""
        let value = url.pathComponents.dropFirst().joined(separator: "/")

        switch kind {
        case "person":
            guard let id = UUID(uuidString: value),
                  let person = people.first(where: { $0.id == id && $0.deletedAt == nil }) else {
                return false
            }
            deepLinkedPerson = person
            return true

        case "wish":
            guard let id = UUID(uuidString: value),
                  let idea = ideas.first(where: { $0.id == id && $0.deletedAt == nil }) else {
                return false
            }
            deepLinkedIdea = idea
            return true

        case "category":
            let decoded = value.removingPercentEncoding ?? value
            guard !decoded.isEmpty else { return false }

            if let categoryID = UUID(uuidString: decoded) {
                guard let category = categoryRecords.first(where: {
                    $0.id == categoryID && $0.deletedAt == nil
                }) else {
                    return false
                }
                deepLinkedCategoryRoute = CategorySheetRoute(
                    categoryID: categoryID,
                    name: category.name
                )
            } else {
                deepLinkedCategoryRoute = CategorySheetRoute(legacyName: decoded)
            }
            return true

        case "reminder":
            guard let id = UUID(uuidString: value) else { return false }
            if let idea = ideas.first(where: { $0.id == id && $0.deletedAt == nil }) {
                deepLinkedIdea = idea
                return true
            }
            if let person = people.first(where: { $0.id == id && $0.deletedAt == nil }) {
                deepLinkedPerson = person
                return true
            }
            return false

        case "composer":
            guard !sortedPeople.isEmpty else { return false }
            selectedPersonIDs = Set(sortedPeople.map(\.id))
            composerFocusRequest.toggle()
            return true

        default:
            return false
        }
    }

    private func retryPendingDeepLink() {
        guard let url = routes.pendingURL else { return }
        if openDeepLink(url) {
            routes.consume()
        }
    }

    private func dismissComposerFocus() {
        guard isComposerFocused else {
            return
        }

        // Do not drive the TextField's FocusState from this parent view.
        // Resign the actual first responder instead, then let the composer
        // report its focus change back through onFocusChange.
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        isComposerFocused = false
    }
}

struct FirstGiftTip: View {
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down")
                .font(.headline.weight(.bold))
                .foregroundStyle(.red)
                .frame(width: 38, height: 38)
                .glassEffect(
                    .regular,
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Got ideas for more people?")
                    .font(.subheadline.weight(.bold))

                Text("Start typing, then select the people you want.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .glassEffect(
                .regular.interactive(),
                in: Circle()
            )
            .accessibilityLabel("Close quick tip")
        }
        .padding(14)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: 24)
        )
        .accessibilityElement(children: .contain)
    }
}


struct PeopleSectionHeader: View {
    let isSelecting: Bool
    let selectedCount: Int
    let allSelected: Bool
    let addPerson: () -> Void
    let done: () -> Void
    let toggleAll: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person")
                    .font(.subheadline.weight(.semibold))
                Text("People")
                    .font(.headline.weight(.semibold))
            }

            if isSelecting {
                Text("\(selectedCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 9)
                    .frame(height: 26)
                    .background(
                        Color.primary.opacity(0.065),
                        in: Capsule()
                    )
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer(minLength: 8)

            if isSelecting {
                HStack(spacing: 12) {
                    Button(
                        allSelected ? "Deselect" : "Select",
                        action: toggleAll
                    )
                    .accessibilityLabel(
                        allSelected ? "Deselect all people" : "Select all people"
                    )

                    Button("Done", action: done)
                        .accessibilityLabel("Finish selecting people")
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            } else {
                Button("Add", action: addPerson)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                .buttonStyle(.plain)
                .accessibilityLabel("Add person")
            }
        }
        .animation(.snappy, value: isSelecting)
    }
}


struct SelectablePersonTile: View {
    let person: Person
    let isSelected: Bool
    let isSaveHighlighted: Bool
    let toggleSelection: () -> Void
    let dismissKeyboard: () -> Void

    @State
    private var hasAppeared = false

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture(perform: dismissKeyboard)

            VStack(spacing: 12) {
                Button(action: toggleSelection) {
                    ZStack {
                        Avatar(
                            person: person,
                            size: 78
                        )
                        .opacity(isSelected ? 1 : 0.48)
                        .saturation(isSelected ? 1 : 0.35)

                        Circle()
                            .stroke(
                                isSelected ? Color.red : .clear,
                                lineWidth: 3
                            )
                            .frame(width: 86, height: 86)
                    }
                    .frame(width: 86, height: 86)
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(.red, in: Circle())
            …6166 tokens truncated…ing: $0)
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
