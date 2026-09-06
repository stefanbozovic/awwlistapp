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
import StoreKit

// MARK: - Product tips

private enum HomeProductTip: String, CaseIterable, Equatable {
    case pin
    case longPress
    case attachments
    case categories
    case layout
    case search
    case reminders
}

// MARK: - Recently Added review card
// Keep this section at the top of the Recently Added area.
// It now contains ONLY the review card.

struct HomeCommunitySection: View {
    @Binding var feedbackResponse: AppFeedbackResponse?

    @Environment(\.openURL)
    private var openURL

    @Environment(\.requestReview)
    private var requestReview

    // Kept so the existing call site does not have to change.
    // Quick ideas now live in HomeEventCommunitySection below.
    let addQuickIdea: (String) -> Void

    @AppStorage("aww.reviewCard.nextEligibleAt")
    private var reviewCardNextEligibleAt: Double = 0

    @State
    private var showReviewCard = false

    // Closing the review card snoozes it for 30 days.
    private let reviewCardCooldown: TimeInterval = 30 * 24 * 60 * 60

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showReviewCard {
                HomeCommunityCard(
                    symbol: "face.smiling",
                    title: "How’s AwwList treating you?",
                    message: "Is it making the little things easier to remember?",
                    onClose: dismissReviewCard
                ) {
                    HStack(spacing: 10) {
                        HomeCommunityActionButton(
                            title: "Needs work",
                            symbol: "bubble.left",
                            style: .secondary,
                            fullWidth: true
                        ) {
                            guard let feedbackURL = URL(
                                string: "https://forms.gle/2QEjaYCzsRoQsJtEA"
                            ) else {
                                return
                            }

                            openURL(feedbackURL)
                            AwwHaptics.selection()
                            dismissReviewCard()
                        }

                        HomeCommunityActionButton(
                            title: "Love it",
                            symbol: "heart.fill",
                            style: .primary,
                            fullWidth: true
                        ) {
                            feedbackResponse = .happy
                            AwwHaptics.success()
                            requestReview()
                            dismissReviewCard()
                        }
                    }
                }
                .transition(cardTransition)
            }
        }
        .animation(
            .spring(response: 0.42, dampingFraction: 0.86),
            value: showReviewCard
        )
        .onAppear {
            showReviewCardIfEligible()
        }
    }

    private var cardTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .move(edge: .bottom))
                .combined(with: .scale(scale: 0.98)),
            removal: .opacity
                .combined(with: .move(edge: .trailing))
                .combined(with: .scale(scale: 0.94))
        )
    }

    private func showReviewCardIfEligible(now: Date = Date()) {
        guard now.timeIntervalSince1970 >= reviewCardNextEligibleAt else {
            showReviewCard = false
            return
        }

        showReviewCard = true
    }

    private func dismissReviewCard() {
        reviewCardNextEligibleAt = Date()
            .addingTimeInterval(reviewCardCooldown)
            .timeIntervalSince1970

        AwwHaptics.selection()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            showReviewCard = false
        }
    }
}

// MARK: - Above-event rotating card
// Place HomeEventCommunitySection immediately ABOVE the event card.
// It shows at most one card at a time: Invite, Need a spark, or one product tip.
// Invite and Need a spark can return later. Product tips never return after dismissal.

struct HomeEventCommunitySection: View {
    private enum ActiveCard: Equatable {
        case invite
        case spark
        case product(HomeProductTip)

        var id: String {
            switch self {
            case .invite:
                "invite"
            case .spark:
                "spark"
            case .product(let tip):
                "product-\(tip.rawValue)"
            }
        }

        var kind: String {
            switch self {
            case .invite:
                "invite"
            case .spark:
                "spark"
            case .product:
                "product"
            }
        }
    }

    let refreshTrigger: Int
    let addQuickIdea: (String) -> Void

    init(
        refreshTrigger: Int = 0,
        addQuickIdea: @escaping (String) -> Void
    ) {
        self.refreshTrigger = refreshTrigger
        self.addQuickIdea = addQuickIdea
    }

    @State
    private var activeCard: ActiveCard?

    @State
    private var showInviteSheet = false

    @AppStorage("aww.eventCommunity.nextEligibleAt")
    private var nextEventCardEligibleAt: Double = 0

    @AppStorage("aww.eventCommunity.lastKind")
    private var lastEventCardKind = ""

    @AppStorage("aww.eventCommunity.lastRecurringKind")
    private var lastRecurringCardKind = ""

    @AppStorage("aww.homeTip.pin.dismissed")
    private var pinTipDismissed = false

    @AppStorage("aww.homeTip.longPress.dismissed")
    private var longPressTipDismissed = false

    @AppStorage("aww.homeTip.attachments.dismissed")
    private var attachmentsTipDismissed = false

    @AppStorage("aww.homeTip.categories.dismissed")
    private var categoriesTipDismissed = false

    @AppStorage("aww.homeTip.layout.dismissed")
    private var layoutTipDismissed = false

    @AppStorage("aww.homeTip.search.dismissed")
    private var searchTipDismissed = false

    @AppStorage("aww.homeTip.reminders.dismissed")
    private var remindersTipDismissed = false

    // Hidden for now, but kept in code.
    private let showSocialCard = false

    // After a card is closed or used, wait before showing another one.
    private let eventCardCooldown: TimeInterval = 2 * 24 * 60 * 60

    private let quickIdeas = [
        "Chocolate",
        "Candles",
        "Movie tickets",
        "Phone case",
        "Coffee gift card",
        "Flowers"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let activeCard {
                card(for: activeCard)
                    .id(activeCard.id)
                    .transition(cardTransition)
            }

            // Social card is intentionally hidden for now.
            if showSocialCard {
                HomeCommunityCard(
                    symbol: "heart.text.square.fill",
                    title: "Come hang out",
                    message: "Gift ideas, tiny reminders, and things worth remembering.",
                    onClose: { }
                ) {
                    HomeCommunityActionButton(
                        title: "See you there",
                        symbol: "heart",
                        style: .secondary,
                        fullWidth: true
                    ) {
                        AwwHaptics.selection()
                    }
                }
            }
        }
        .animation(
            .spring(response: 0.42, dampingFraction: 0.86),
            value: activeCard
        )
        .onAppear {
            showEventCardIfEligible()
        }
        .onChange(of: refreshTrigger) { _, _ in
            showEventCardAfterManualRefresh()
        }
        .sheet(isPresented: $showInviteSheet) {
            AwwActivitySheet(
                items: [
                    """
                    I’m using AwwList to remember gift ideas for the people I love. Join me!
                    """
                ]
            )
        }
    }

    @ViewBuilder
    private func card(for card: ActiveCard) -> some View {
        switch card {
        case .invite:
            inviteCard

        case .spark:
            sparkCard

        case .product(let tip):
            productTipCard(for: tip)
        }
    }

    private var inviteCard: some View {
        HomeCommunityCard(
            symbol: "person.2.fill",
            title: "Know someone who needs this?",
            message: "Send AwwList to the friend who’s always saying “I’ll remember.”",
            onClose: {
                dismissRecurringCard(.invite)
            }
        ) {
            HomeCommunityActionButton(
                title: "Share AwwList",
                symbol: "square.and.arrow.up",
                style: .primary,
                fullWidth: true
            ) {
                showInviteSheet = true
                AwwHaptics.selection()
                dismissRecurringCard(.invite)
            }
        }
    }

    private var sparkCard: some View {
        HomeCommunityCard(
            symbol: "sparkles",
            title: "Need a spark?",
            message: "Steal an idea below and make it theirs.",
            onClose: {
                dismissRecurringCard(.spark)
            }
        ) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(quickIdeas, id: \.self) { idea in
                        Button {
                            addQuickIdea(idea)
                            AwwHaptics.selection()
                            dismissRecurringCard(.spark)
                        } label: {
                            Text(idea)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 14)
                                .frame(height: 38)
                                .background(
                                    Color.primary.opacity(0.07),
                                    in: Capsule()
                                )
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            Color.primary.opacity(0.07),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private func productTipCard(for tip: HomeProductTip) -> some View {
        switch tip {
        case .pin:
            HomeCommunityCard(
                symbol: "pin.fill",
                title: "Keep the good ones close",
                message: "Pin the ideas you really don’t want to forget.",
                onClose: { dismissProductTip(.pin) }
            ) {
                productTipButton(
                    title: "Good to know",
                    symbol: "pin.fill",
                    tip: .pin
                )
            }

        case .longPress:
            HomeCommunityCard(
                symbol: "hand.tap.fill",
                title: "Changed your mind?",
                message: "Long-press any idea to quickly get rid of it.",
                onClose: { dismissProductTip(.longPress) }
            ) {
                productTipButton(
                    title: "Good to know",
                    symbol: "hand.tap",
                    tip: .longPress
                )
            }

        case .attachments:
            HomeCommunityCard(
                symbol: "link.badge.plus",
                title: "Save more than a thought",
                message: "Drop in the link, photo, screenshot, or file that made you think of them.",
                onClose: { dismissProductTip(.attachments) }
            ) {
                productTipButton(
                    title: "I’ll remember that",
                    symbol: "paperclip",
                    tip: .attachments
                )
            }

        case .categories:
            HomeCommunityCard(
                symbol: "folder.badge.plus",
                title: "Give the chaos a home",
                message: "Make categories for birthdays, Christmas, random hints, or whatever makes sense to you.",
                onClose: { dismissProductTip(.categories) }
            ) {
                productTipButton(
                    title: "Good to know",
                    symbol: "folder",
                    tip: .categories
                )
            }

        case .layout:
            HomeCommunityCard(
                symbol: "rectangle.grid.2x2",
                title: "List person or grid person?",
                message: "Switch the layout whenever your brain wants something different.",
                onClose: { dismissProductTip(.layout) }
            ) {
                productTipButton(
                    title: "Good to know",
                    symbol: "rectangle.grid.2x2",
                    tip: .layout
                )
            }

        case .search:
            HomeCommunityCard(
                symbol: "magnifyingglass",
                title: "Forgot where you saved it?",
                message: "Search the one detail you do remember. A name, brand, color, anything.",
                onClose: { dismissProductTip(.search) }
            ) {
                productTipButton(
                    title: "Good to know",
                    symbol: "magnifyingglass",
                    tip: .search
                )
            }

        case .reminders:
            HomeCommunityCard(
                symbol: "bell.badge.fill",
                title: "Remember at the right time",
                message: "Set reminders so the perfect idea doesn’t come back to you three days after their birthday.",
                onClose: { dismissProductTip(.reminders) }
            ) {
                productTipButton(
                    title: "Future me says thanks",
                    symbol: "bell",
                    tip: .reminders
                )
            }
        }
    }

    private func showEventCardIfEligible(now: Date = Date()) {
        guard activeCard == nil else { return }
        guard now.timeIntervalSince1970 >= nextEventCardEligibleAt else { return }

        let nextCard = nextCardToShow()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            activeCard = nextCard
        }
    }

    private func showEventCardAfterManualRefresh() {
        // Manual refresh bypasses the normal time cooldown.
        // If a card is already visible, keep it. If the user dismissed it,
        // refresh immediately surfaces the next appropriate card.
        guard activeCard == nil else { return }

        let nextCard = nextCardToShow()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            activeCard = nextCard
        }
    }

    private func nextCardToShow() -> ActiveCard {
        // First ever card is Need a spark.
        guard !lastEventCardKind.isEmpty else {
            return .spark
        }

        // Never show two product tips back-to-back.
        // Alternate a recurring card between product tips.
        if lastEventCardKind == "product" {
            return lastRecurringCardKind == "spark" ? .invite : .spark
        }

        if let nextTip = HomeProductTip.allCases.first(where: { !isTipDismissed($0) }) {
            return .product(nextTip)
        }

        // Once all one-time product tips are finished, keep alternating
        // Need a spark and Invite from time to time.
        return lastRecurringCardKind == "spark" ? .invite : .spark
    }

    private func dismissRecurringCard(_ card: ActiveCard) {
        guard card == .invite || card == .spark else { return }

        lastEventCardKind = card.kind
        lastRecurringCardKind = card.kind
        scheduleNextEventCard()

        AwwHaptics.selection()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            activeCard = nil
        }
    }

    private func dismissProductTip(_ tip: HomeProductTip) {
        setTipDismissed(tip)
        lastEventCardKind = "product"
        scheduleNextEventCard()

        AwwHaptics.selection()

        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            activeCard = nil
        }
    }

    private func scheduleNextEventCard() {
        nextEventCardEligibleAt = Date()
            .addingTimeInterval(eventCardCooldown)
            .timeIntervalSince1970
    }

    private func productTipButton(
        title: String,
        symbol: String,
        tip: HomeProductTip
    ) -> some View {
        HomeCommunityActionButton(
            title: title,
            symbol: symbol,
            style: .secondary,
            fullWidth: true
        ) {
            dismissProductTip(tip)
        }
    }

    private func isTipDismissed(_ tip: HomeProductTip) -> Bool {
        switch tip {
        case .pin:
            pinTipDismissed
        case .longPress:
            longPressTipDismissed
        case .attachments:
            attachmentsTipDismissed
        case .categories:
            categoriesTipDismissed
        case .layout:
            layoutTipDismissed
        case .search:
            searchTipDismissed
        case .reminders:
            remindersTipDismissed
        }
    }

    private func setTipDismissed(_ tip: HomeProductTip) {
        switch tip {
        case .pin:
            pinTipDismissed = true
        case .longPress:
            longPressTipDismissed = true
        case .attachments:
            attachmentsTipDismissed = true
        case .categories:
            categoriesTipDismissed = true
        case .layout:
            layoutTipDismissed = true
        case .search:
            searchTipDismissed = true
        case .reminders:
            remindersTipDismissed = true
        }
    }

    private var cardTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity
                .combined(with: .move(edge: .bottom))
                .combined(with: .scale(scale: 0.98)),
            removal: .opacity
                .combined(with: .move(edge: .trailing))
                .combined(with: .scale(scale: 0.94))
        )
    }
}

// MARK: - Home Community Card

private struct HomeCommunityCard<Actions: View>: View {
    let symbol: String
    let title: String
    let message: String
    let onClose: (() -> Void)?

    @ViewBuilder
    let actions: () -> Actions

    init(
        symbol: String,
        title: String,
        message: String,
        onClose: (() -> Void)? = nil,
        @ViewBuilder actions: @escaping () -> Actions
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.onClose = onClose
        self.actions = actions
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 42, height: 42)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 0)

                if let onClose {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Color.primary.opacity(0.055),
                                in: Circle()
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
            }

            actions()
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .stroke(
                Color.primary.opacity(0.055),
                lineWidth: 1
            )
        }
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 18,
            x: 0,
            y: 8
        )
        .accessibilityElement(
            children: .contain
        )
    }
}

// MARK: - Community Card Button

private struct HomeCommunityActionButton: View {

    enum Style {

        case primary

        case secondary

    }

    let title: String

    let symbol: String?

    let style: Style

    let fullWidth: Bool

    let action: () -> Void

    init(

        title: String,

        symbol: String? = nil,

        style: Style,

        fullWidth: Bool = false,

        action: @escaping () -> Void

    ) {

        self.title = title

        self.symbol = symbol

        self.style = style

        self.fullWidth = fullWidth

        self.action = action

    }

    var body: some View {

        Button(action: action) {

            HStack(spacing: 7) {

                if let symbol {

                    Image(systemName: symbol)

                        .font(.subheadline.weight(.semibold))

                }

                Text(title)

                    .font(.subheadline.weight(.bold))

            }

            .frame(

                maxWidth: fullWidth ? .infinity : nil

            )

            .padding(.horizontal, 16)

            .frame(height: 44)

            .foregroundStyle(

                style == .primary

                    ? Color.white

                    : Color.primary

            )

            .background {

                if style == .primary {

                    Capsule()

                        .fill(Color.red)

                } else {

                    Capsule()

                        .fill(

                            Color.primary.opacity(0.065)

                        )

                }

            }

            .overlay {

                if style == .secondary {

                    Capsule()

                        .stroke(

                            Color.primary.opacity(0.07),

                            lineWidth: 1

                        )

                }

            }

        }

        .buttonStyle(.plain)

    }

}

private struct HomeInlineTip: Tip {

    let id: String

    let titleText: String

    let messageText: String

    let symbol: String

    private let actionTitles: [String]

    init(

        id: String,

        title: String,

        message: String,

        symbol: String,

        actions: [String] = []

    ) {

        self.id = id

        titleText = title

        messageText = message

        self.symbol = symbol

        actionTitles = actions

    }

    var title: Text {

        Text(titleText)

    }

    var message: Text? {

        Text(messageText)

    }

    var image: Image? {

        Image(systemName: symbol)

    }

    var actions: [Tips.Action] {

        actionTitles.enumerated().map { index, title in

            Tips.Action(id: "action-\(index)", title: title)

        }

    }

}

private struct AwwActivitySheet: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {

        UIActivityViewController(activityItems: items, applicationActivities: nil)

    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

}

struct FirstGiftTip: View {

    let dismiss: () -> Void

    var body: some View {
        EmptyView()
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

                                .overlay {

                                    Circle()

                                        .stroke(

                                            Color(uiColor: .systemBackground),

                                            lineWidth: 2

                                        )

                                }

                                .offset(x: 2, y: -2)

                                .transition(.scale.combined(with: .opacity))

                        }

                    }

                }

                .buttonStyle(.plain)

                .accessibilityLabel(

                    isSelected

                        ? "Deselect \(person.name)"

                        : "Select \(person.name)"

                )

                VStack(spacing: 7) {

                    Text(homeDisplayName)

                        .font(.subheadline.weight(.semibold))

                        .lineLimit(1)

                    HomePersonMetadataBadge(

                        giftCount: person.ideas.count,

                        countdown: person.countdown,

                        isSaveHighlighted: isSaveHighlighted

                    )

                }

                .foregroundStyle(

                    isSelected ? Color.primary : Color.secondary

                )

                .opacity(isSelected ? 1 : 0.65)

                .allowsHitTesting(false)

            }

        }

        .frame(maxWidth: .infinity)

        .padding(.vertical, 10)

        .scaleEffect(hasAppeared ? 1 : 0.80)

        .opacity(hasAppeared ? 1 : 0)

        .animation(.snappy, value: isSelected)

        .onAppear {

            guard !hasAppeared else { return }

            withAnimation(

                .spring(

                    response: 0.48,

                    dampingFraction: 0.70,

                    blendDuration: 0.12

                )

            ) {

                hasAppeared = true

            }

        }

    }

    private var homeDisplayName: String {

        person.name

            .split(whereSeparator: \.isWhitespace)

            .first

            .map(String.init)

            ?? person.name

    }

}
