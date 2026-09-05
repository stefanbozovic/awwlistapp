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

private struct HomeCommunitySection: View {
    @Binding var feedbackResponse: AppFeedbackResponse?

    @Environment(\.openURL)
    private var openURL

    let addQuickIdea: (String) -> Void

    @State
    private var showInviteSheet = false

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

            // MARK: Feedback

            HomeCommunityCard(
                symbol: "face.smiling",
                title: "Enjoying AwwList?",
                message: "Are the app and its features working for you?"
            ) {
                HStack(spacing: 10) {
                    HomeCommunityActionButton(
                        title: "Happy",
                        symbol: "heart.fill",
                        style: .secondary
                    ) {
                        feedbackResponse = .happy
                        AwwHaptics.success()
                    }

                    HomeCommunityActionButton(
                        title: "Write feedback",
                        symbol: "square.and.pencil",
                        style: .primary
                    ) {
                        guard let feedbackURL = URL(
                            string: "https://forms.gle/2QEjaYCzsRoQsJtEA"
                        ) else {
                            return
                        }

                        openURL(feedbackURL)
                        AwwHaptics.selection()
                    }
                }
            }

            // MARK: Invite friends

            HomeCommunityCard(
                symbol: "person.2.fill",
                title: "Invite friends",
                message: "Thoughtful gift ideas are better shared."
            ) {
                HomeCommunityActionButton(
                    title: "Invite",
                    symbol: "square.and.arrow.up",
                    style: .primary,
                    fullWidth: true
                ) {
                    showInviteSheet = true
                    AwwHaptics.selection()
                }
            }

            // MARK: Socials

            HomeCommunityCard(
                symbol: "heart.text.square.fill",
                title: "Follow us on socials",
                message: "Find AwwList on Instagram and TikTok."
            ) {
                HomeCommunityActionButton(
                    title: "Okay",
                    symbol: "checkmark",
                    style: .secondary
                ) {
                    AwwHaptics.selection()
                }
            }

            // MARK: Quick ideas

            HomeCommunityCard(
                symbol: "sparkles",
                title: "Need a little idea?",
                message: "Tap a shortcut to add it to your gift composer."
            ) {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(quickIdeas, id: \.self) { idea in
                            Button {
                                addQuickIdea(idea)
                                AwwHaptics.selection()
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

            // MARK: Product tips

            HomeCommunityCard(
                symbol: "pin.fill",
                title: "Keep favorites close",
                message: "Pin your favorite wishes so they are easy to find."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "hand.tap.fill",
                title: "Tidy up quickly",
                message: "Long-press a wish to delete it when you no longer need it."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "link.badge.plus",
                title: "Save it your way",
                message: "Paste links, add photos, and attach files to any wish."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "folder.badge.plus",
                title: "Make it yours",
                message: "Create categories to keep every gift idea neatly organized."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "rectangle.grid.2x2",
                title: "See it your way",
                message: "Switch between list and grid views whenever you like."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "magnifyingglass",
                title: "Find anything",
                message: "Search by any detail you remember, from a name to a gift idea."
            ) {
                okayButton
            }

            HomeCommunityCard(
                symbol: "bell.badge.fill",
                title: "Never miss the moment",
                message: "Set more than one reminder and choose the days that work for you."
            ) {
                okayButton
            }
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

    private var okayButton: some View {
        HomeCommunityActionButton(
            title: "Okay",
            symbol: "checkmark",
            style: .secondary
        ) {
            // Intentionally does not dismiss the card.
            // These cards always stay visible.
            AwwHaptics.selection()
        }
    }
}


// MARK: - Home Community Card

private struct HomeCommunityCard<Actions: View>: View {
    let symbol: String
    let title: String
    let message: String

    @ViewBuilder
    let actions: () -> Actions

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
            }

            actions()
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(
                uiColor: .secondarySystemBackground
            ),
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



