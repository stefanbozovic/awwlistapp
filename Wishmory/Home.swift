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

    @Query(sort: \Occasion.date)
    private var occasions: [Occasion]

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
    @State private var savedPulsePersonIDs: Set<UUID> = []
    @State private var savedToastText: String?
    @State private var foregroundReminder: AwwForegroundReminder?
    @State private var recentWishDisplayStyle: WishDisplayStyle = .list
    @State private var quickIdea = ""
    @State private var feedbackResponse: AppFeedbackResponse?

    private var sortedPeople: [Person] {
        people.filter { $0.deletedAt == nil && !hiddenPersonIDs.contains($0.id) }.sorted { first, second in
            if first.isOwner != second.isOwner {
                return first.isOwner
            }

            return first.created < second.created
        }
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

    private var upcomingEvents: [UpcomingEvent] {
        let now = Date.now
        let personalOccasions = occasions.compactMap { occasion -> UpcomingEvent? in
            guard occasion.deletedAt == nil,
                  occasion.date >= Calendar.current.startOfDay(for: now) else {
                return nil
            }

            let participants = occasion.participantIDs.compactMap { id in
                sortedPeople.first(where: { $0.id == id })?.name
            }
            let detail = participants.isEmpty
                ? "Personal occasion"
                : participants.formatted(.list(type: .and))

            return UpcomingEvent(
                id: "occasion-\(occasion.id.uuidString)",
                title: occasion.title,
                date: occasion.date,
                symbol: "gift.fill",
                detail: detail,
                person: nil
            )
        }
        let birthdays = sortedPeople.compactMap {
            GiftingCalendar.nextBirthday(for: $0, after: now)
        }

        return (personalOccasions + birthdays + GiftingCalendar.upcomingEvents(after: now))
            .sorted { $0.date < $1.date }
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
                        Image("AwwListWoodmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 132, height: 40)
                            .accessibilityLabel("AwwList")
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
            .alert("Tell us what could be better", isPresented: feedbackFormConfirmation) {
                Button("Not now", role: .cancel) {
                    feedbackResponse = nil
                }

                Button("Write feedback") {
                    if let feedbackURL = URL(string: "https://forms.gle/2QEjaYCzsRoQsJtEA") {
                        UIApplication.shared.open(feedbackURL)
                    }
                    feedbackResponse = nil
                }
            } message: {
                Text("Your feedback helps us make AwwList better.")
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

            Rectangle()
                .fill(.thickMaterial)
                .frame(height: 260)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black.opacity(0.50), location: 0.30),
                            .init(color: .black, location: 0.68)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

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
            requestFocus: $composerFocusRequest,
            quickIdea: $quickIdea
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
            .tint(.primary)
            .accessibilityLabel("Search wishes")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismissComposerFocus()
                settings = true
            } label: {
                Image(systemName: "person.crop.circle")
                    .foregroundStyle(.primary)
            }
            .tint(.primary)
            .accessibilityLabel("Settings")
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 22) {
            if isComposerFocused {
                peopleHeader
            }

            peopleGrid

            if !isComposerFocused {
                if !upcomingEvents.isEmpty {
                    upcomingEventsSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if !recentWishGroups.isEmpty {
                    recentlyAddedSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if showFirstGiftTip {
                    FirstGiftTip {
                        showFirstGiftTip = false
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                HomeCommunitySection(
                    feedbackResponse: $feedbackResponse,
                    addQuickIdea: addQuickIdea
                )
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

            if !isComposerFocused {
                Button {
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

    private var upcomingEventsSection: some View {
        NextEventSummarySection(events: upcomingEvents)
    }

    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart")
                    .font(.subheadline.weight(.semibold))
                Text("Recently added")
                    .font(.headline.weight(.semibold))

                Spacer()

                Menu {
                    ForEach(WishDisplayStyle.allCases) { style in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) {
                                recentWishDisplayStyle = style
                            }
                            AwwHaptics.selection()
                        } label: {
                            if recentWishDisplayStyle == style {
                                Label(style.title, systemImage: "checkmark")
                            } else {
                                Label(style.title, systemImage: style.symbol)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.bold))
                        .frame(width: 36, height: 36)
                }
                .accessibilityLabel("Choose recently added view")
            }

            switch recentWishDisplayStyle {
            case .grid:
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 0), spacing: 10),
                        GridItem(.flexible(minimum: 0), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(recentWishGroups) { group in
                        RecentWishBubbleCard(group: group, layout: .grid) {
                            editingHomeIdea = group.idea
                        }
                    }
                }

            case .list:
                LazyVStack(spacing: 10) {
                    ForEach(recentWishGroups) { group in
                        RecentWishBubbleCard(group: group, layout: .list) {
                            editingHomeIdea = group.idea
                        }
                    }
                }
            }
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

    private var feedbackFormConfirmation: Binding<Bool> {
        Binding(
            get: { feedbackResponse == .unhappy },
            set: { isPresented in
                if !isPresented {
                    feedbackResponse = nil
                }
            }
        )
    }

    private func addQuickIdea(_ idea: String) {
        selectedPersonIDs = Set(sortedPeople.map(\.id))
        quickIdea = idea
        composerFocusRequest.toggle()
        AwwHaptics.selection()
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
        AwwShareBridge.mirrorPeople(sortedPeople)
        AwwShareBridge.importPendingShares(context: context, people: sortedPeople)
        retryPendingDeepLink()
        try? await Task.sleep(for: .milliseconds(650))
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

