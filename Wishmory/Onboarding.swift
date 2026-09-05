import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Onboarding

struct Onboarding: View {
    let finish: (String, String, Data?, Date?) -> Void

    @Environment(\.modelContext)
    private var context

    @State private var page = 0
    @State private var name = ""
    @State private var emoji = Onboarding.suggestedEmoji
    @State private var profileImage: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var birthday = Date.now
    @State private var knowsBirthday = true

    private static let emojiSuggestions = [
        "🌼", "🪩", "🍓", "🦋",
        "🌞", "🎈", "🫶", "🍒"
    ]

    private static var suggestedEmoji: String {
        emojiSuggestions.randomElement() ?? "🍒"
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch page {
                case 0:
                    OnboardingWelcomePage(startWishing: startWishing)

                case 1:
                    OnboardingProfilePage(
                        name: $name,
                        emoji: $emoji,
                        profileImage: $profileImage,
                        selectedPhoto: $selectedPhoto,
                        emojiSuggestions: Self.emojiSuggestions,
                        suggestEmoji: suggestEmoji,
                        continueAction: advance
                    )

                case 2:
                    OnboardingBirthdayPage(
                        birthday: $birthday,
                        knowsBirthday: $knowsBirthday,
                        finishAction: advance
                    )

                default:
                    OnboardingNotificationsPage(finishAction: advance)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if page > 1 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: goBack) {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                        }
                        .accessibilityLabel("Back")
                    }
                }
            }
        }
        .tint(.red)
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else { return }

            Task {
                if let data = try? await newPhoto.loadTransferable(type: Data.self) {
                    profileImage = data
                }
            }
        }
    }

    private func startWishing() {
        name = ""

        withAnimation(.snappy(duration: 0.28)) {
            page = 1
        }
    }

    private func advance() {
        if page == 2 {
            Task {
                let status = await NotificationScheduler.authorizationStatus()

                if status == .authorized {
                    completeOnboarding()
                } else {
                    withAnimation(.snappy(duration: 0.28)) {
                        page = 3
                    }
                }
            }
        } else if page < 3 {
            withAnimation(.snappy(duration: 0.28)) {
                page += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        finish(
            trimmedName,
            emoji,
            profileImage,
            knowsBirthday ? birthday : nil
        )
    }

    private func goBack() {
        dismissKeyboard()

        withAnimation(.snappy(duration: 0.28)) {
            page -= 1
        }
    }

    private func suggestEmoji() {
        var nextEmoji = Self.suggestedEmoji
        while nextEmoji == emoji {
            nextEmoji = Self.suggestedEmoji
        }
        emoji = nextEmoji
        profileImage = nil
    }
}

private extension String {
    var nonEmptyValue: String? {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}

struct OnboardingCenteredShell<Content: View, Footer: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    var body: some View {
        ZStack(alignment: .top) {
            Backdrop()

            let cherry = Color(red: 0.66, green: 0.07, blue: 0.09)

            LinearGradient(
                stops: [
                    .init(color: cherry.opacity(0.10), location: 0.00),
                    .init(color: cherry.opacity(0.055), location: 0.28),
                    .init(color: cherry.opacity(0.018), location: 0.58),
                    .init(color: .clear, location: 0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .ignoresSafeArea(edges: [.top, .horizontal])
            .allowsHitTesting(false)

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)

                        content()
                            .frame(maxWidth: 560)
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 24)
                    }
                    .frame(
                        minHeight: max(0, proxy.size.height - 8),
                        alignment: .center
                    )
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer()
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(.clear)
        }
    }
}

struct OnboardingNotificationsPage: View {
    let finishAction: () -> Void

    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        OnboardingCenteredShell {
            VStack(spacing: 18) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 88, height: 88)
                    .glassEffect(.regular, in: Circle())

                VStack(spacing: 10) {
                    Text("Never miss a moment")
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("Turn on notifications and AwwList can remind you before birthdays, anniversaries, and every other important date.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if authorizationStatus == .denied {
                    VStack(spacing: 10) {
                        Text("Notifications are currently off. You can enable them any time in Settings.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Open Settings", systemImage: "gear") {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(url)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        } footer: {
            VStack(spacing: 10) {
                if authorizationStatus == .notDetermined {
                    Button("Enable reminders", systemImage: "bell.fill") {
                        Task {
                            _ = await NotificationScheduler.requestAuthorization()
                            authorizationStatus = await NotificationScheduler.authorizationStatus()
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .controlSize(.large)

                    Button("Not now", action: finishAction)
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .frame(height: 44)
                } else {
                    Button("Continue", action: finishAction)
                        .buttonStyle(.glassProminent)
                        .tint(.red)
                        .controlSize(.large)
                }
            }
        }
        .task {
            authorizationStatus = await NotificationScheduler.authorizationStatus()
        }
    }
}

struct OnboardingWelcomePage: View {
    let startWishing: () -> Void

    var body: some View {
        OnboardingCenteredShell {
            VStack(spacing: 26) {
                VStack(spacing: 14) {
                    OnboardingBrandMark()
                        .frame(width: 110, height: 110)

                    Text("AwwList")
                        .font(.system(size: 42, weight: .bold, design: .rounded))

                    Text("Keep wishes, gift ideas, and the people they belong to together before the thought disappears.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 10) {
                    OnboardingWishRow(
                        symbol: "sparkles",
                        title: "A wish pops up",
                        subtitle: "Save it before you forget it."
                    )

                    OnboardingWishRow(
                        symbol: "gift",
                        title: "Someone drops a hint",
                        subtitle: "Keep it with their name for later."
                    )

                    OnboardingWishRow(
                        symbol: "bell",
                        title: "A birthday sneaks up",
                        subtitle: "Remember what they actually wanted."
                    )
                }
            }
        } footer: {
            VStack(spacing: 8) {
                Button("Start Wishing", systemImage: "heart.fill", action: startWishing)
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .controlSize(.large)
                    .accessibilityHint("Set up your profile to begin using AwwList locally on this iPhone")

                Text("No account. Data is saved locally.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct OnboardingBrandMark: View {
    var body: some View {
        Image("OnboardingLogo")
            .resizable()
            .scaledToFit()
            .padding(12)
            .background(in: Circle())
            .backgroundStyle(.background)
            .shadow(color: .red.opacity(0.18), radius: 14, y: 8)
            .accessibilityHidden(true)
    }
}

struct AwwListLogoMark: View {
    var body: some View {
        AwwListLogoPath()
            .fill(
                Color(red: 0.94, green: 0.17, blue: 0.15),
                style: FillStyle(eoFill: true)
            )
            .accessibilityHidden(true)
    }
}

struct AwwListLogoPath: Shape {
    func path(in rect: CGRect) -> Path {
        let sourceBounds = CGRect(x: 18, y: 114, width: 391, height: 439)
        let scale = min(
            rect.width / sourceBounds.width,
            rect.height / sourceBounds.height
        )
        let horizontalInset = (rect.width - sourceBounds.width * scale) / 2
        let verticalInset = (rect.height - sourceBounds.height * scale) / 2

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + horizontalInset + (x - sourceBounds.minX) * scale,
                y: rect.minY + verticalInset + (y - sourceBounds.minY) * scale
            )
        }

        var path = Path()

        path.move(to: point(305, 124))
        path.addLine(to: point(295, 119))
        path.addLine(to: point(285, 116))
        path.addLine(to: point(274, 115))
        path.addLine(to: point(273, 114))
        path.addLine(to: point(255, 114))
        path.addLine(to: point(254, 115))
        path.addLine(to: point(247, 115))
        path.addLine(to: point(234, 118))
        path.addLine(to: point(217, 125))
        path.addLine(to: point(198, 138))
        path.addLine(to: point(183, 152))
        path.addLine(to: point(161, 179))
        path.addLine(to: point(142, 208))
        path.addLine(to: point(139, 215))
        path.addLine(to: point(132, 225))
        path.addLine(to: point(128, 234))
        path.addLine(to: point(120, 247))
        path.addLine(to: point(110, 268))
        path.addLine(to: point(108, 270))
        path.addLine(to: point(108, 272))
        path.addLine(to: point(101, 284))
        path.addLine(to: point(101, 286))
        path.addLine(to: point(93, 301))
        path.addLine(to: point(93, 303))
        path.addLine(to: point(84, 320))
        path.addLine(to: point(84, 322))
        path.addLine(to: point(64, 365))
        path.addLine(to: point(54, 392))
        path.addLine(to: point(50, 399))
        path.addLine(to: point(49, 404))
        path.addLine(to: point(45, 412))
        path.addLine(to: point(44, 417))
        path.addLine(to: point(42, 420))
        path.addLine(to: point(27, 462))
        path.addLine(to: point(19, 493))
        path.addLine(to: point(18, 514))
        path.addLine(to: point(23, 531))
        path.addLine(to: point(27, 537))
        path.addLine(to: point(33, 543))
        path.addLine(to: point(47, 551))
        path.addLine(to: point(55, 552))
        path.addLine(to: point(56, 553))
        path.addLine(to: point(71, 553))
        path.addLine(to: point(86, 549))
        path.addLine(to: point(105, 538))
        path.addLine(to: point(120, 523))
        path.addLine(to: point(128, 512))
        path.addLine(to: point(147, 474))
        path.addLine(to: point(156, 461))
        path.addLine(to: point(167, 450))
        path.addLine(to: point(177, 443))
        path.addLine(to: point(195, 436))
        path.addLine(to: point(205, 435))
        path.addLine(to: point(206, 434))
        path.addLine(to: point(234, 434))
        path.addLine(to: point(235, 435))
        path.addLine(to: point(244, 436))
        path.addLine(to: point(260, 442))
        path.addLine(to: point(270, 449))
        path.addLine(to: point(282, 463))
        path.addLine(to: point(294, 492))
        path.addLine(to: point(295, 497))
        path.addLine(to: point(307, 519))
        path.addLine(to: point(322, 535))
        path.addLine(to: point(336, 543))
        path.addLine(to: point(346, 546))
        path.addLine(to: point(353, 546))
        path.addLine(to: point(354, 547))
        path.addLine(to: point(371, 545))
        path.addLine(to: point(385, 539))
        path.addLine(to: point(401, 523))
        path.addLine(to: point(405, 515))
        path.addLine(to: point(409, 500))
        path.addLine(to: point(409, 475))
        path.addLine(to: point(408, 474))
        path.addLine(to: point(407, 459))
        path.addLine(to: point(405, 452))
        path.addLine(to: point(404, 439))
        path.addLine(to: point(403, 438))
        path.addLine(to: point(402, 427))
        path.addLine(to: point(400, 421))
        path.addLine(to: point(400, 415))
        path.addLine(to: point(399, 414))
        path.addLine(to: point(398, 403))
        path.addLine(to: point(396, 397))
        path.addLine(to: point(395, 386))
        path.addLine(to: point(394, 385))
        path.addLine(to: point(391, 365))
        path.addLine(to: point(389, 359))
        path.addLine(to: point(389, 354))
        path.addLine(to: point(386, 343))
        path.addLine(to: point(384, 326))
        path.addLine(to: point(380, 312))
        path.addLine(to: point(380, 308))
        path.addLine(to: point(379, 307))
        path.addLine(to: point(373, 273))
        path.addLine(to: point(370, 264))
        path.addLine(to: point(369, 255))
        path.addLine(to: point(366, 246))
        path.addLine(to: point(365, 237))
        path.addLine(to: point(363, 233))
        path.addLine(to: point(358, 211))
        path.addLine(to: point(354, 201))
        path.addLine(to: point(354, 198))
        path.addLine(to: point(350, 186))
        path.addLine(to: point(339, 161))
        path.addLine(to: point(326, 142))
        path.addLine(to: point(316, 132))
        path.closeSubpath()

        path.move(to: point(298, 260))
        path.addLine(to: point(307, 269))
        path.addLine(to: point(311, 277))
        path.addLine(to: point(312, 285))
        path.addLine(to: point(313, 286))
        path.addLine(to: point(313, 296))
        path.addLine(to: point(312, 297))
        path.addLine(to: point(311, 307))
        path.addLine(to: point(304, 322))
        path.addLine(to: point(304, 324))
        path.addLine(to: point(298, 335))
        path.addLine(to: point(279, 360))
        path.addLine(to: point(264, 374))
        path.addLine(to: point(252, 381))
        path.addLine(to: point(241, 382))
        path.addLine(to: point(226, 376))
        path.addLine(to: point(204, 358))
        path.addLine(to: point(192, 344))
        path.addLine(to: point(183, 330))
        path.addLine(to: point(178, 319))
        path.addLine(to: point(174, 304))
        path.addLine(to: point(174, 293))
        path.addLine(to: point(177, 283))
        path.addLine(to: point(181, 277))
        path.addLine(to: point(190, 269))
        path.addLine(to: point(195, 267))
        path.addLine(to: point(205, 266))
        path.addLine(to: point(216, 269))
        path.addLine(to: point(222, 273))
        path.addLine(to: point(242, 293))
        path.addLine(to: point(247, 288))
        path.addLine(to: point(256, 274))
        path.addLine(to: point(264, 266))
        path.addLine(to: point(271, 261))
        path.addLine(to: point(281, 257))
        path.addLine(to: point(291, 257))
        path.closeSubpath()

        return path
    }
}

struct OnboardingWishRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.red)
                .frame(width: 42, height: 42)
                .background(
                        Circle()
                            .fill(.red.opacity(0.06))
                    )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .glassEffect(
            .regular,
            in: .rect(cornerRadius: 24)
        )
    }
}

struct OnboardingProfilePage: View {
    @Binding var name: String
    @Binding var emoji: String
    @Binding var profileImage: Data?
    @Binding var selectedPhoto: PhotosPickerItem?

    let emojiSuggestions: [String]
    let suggestEmoji: () -> Void
    let continueAction: () -> Void

    @State private var showingPhotoPicker = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        OnboardingCenteredShell {
            VStack(spacing: 26) {
                VStack(spacing: 8) {
                    Text("What should we call you?")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("You can change this anytime.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Menu {
                    Menu("Choose emoji", systemImage: "face.smiling") {
                        ForEach(emojiSuggestions, id: \.self) { option in
                            Button(option) {
                                emoji = option
                                profileImage = nil
                            }
                        }
                    }

                    Button("Suggest another emoji", systemImage: "shuffle") {
                        suggestEmoji()
                    }

                    Button("Choose photo", systemImage: "photo") {
                        isNameFocused = false
                        dismissKeyboard()
                        DispatchQueue.main.async {
                            showingPhotoPicker = true
                        }
                    }
                } label: {
                    avatar
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose your avatar")
                .photosPicker(
                    isPresented: $showingPhotoPicker,
                    selection: $selectedPhoto,
                    matching: .images
                )

                TextField("Your name", text: $name)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.continue)
                    .focused($isNameFocused)
                    .onSubmit(continueIfPossible)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .frame(maxWidth: 440)
            }
        } footer: {
            Button(action: continueIfPossible) {
                Label("That’s me", systemImage: "heart.fill")
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 10)
            }
            .buttonStyle(.glassProminent)
            .tint(.red)
            .controlSize(.large)
            .disabled(trimmedName.isEmpty)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(250))
            isNameFocused = true
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let profileImage,
           let image = AwwImageCache.shared.image(
            from: profileImage,
            maxPixelSize: 360
           ) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 112)
                .background(Color.red.opacity(0.14), in: Circle())
                .clipShape(Circle())
        } else {
            Text(emoji)
                .font(.system(size: 54))
                .frame(width: 112, height: 112)
                .background(Color.red.opacity(0.14), in: Circle())
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func continueIfPossible() {
        guard !trimmedName.isEmpty else {
            isNameFocused = true
            return
        }

        isNameFocused = false
        dismissKeyboard()
        continueAction()
    }
}

struct OnboardingBirthdayPage: View {
    @Binding var birthday: Date
    @Binding var knowsBirthday: Bool
    let finishAction: () -> Void

    var body: some View {
        OnboardingCenteredShell {
            VStack(spacing: 26) {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 72, height: 72)
                    .glassEffect(.regular, in: Circle())

                VStack(spacing: 9) {
                    Text("And when’s your birthday?")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("This stays available offline and helps AwwList remember your moments too.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.red)

                    Text("My birthday")
                        .font(.headline)

                    Spacer()

                    DatePicker(
                        "Birthday",
                        selection: $birthday,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.red)
                }
                .padding(16)
                .frame(maxWidth: 520)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 24))
            }
        } footer: {
            VStack(spacing: 10) {
                Button(action: finishWithBirthday) {
                    Label("Take me to my list", systemImage: "heart.fill")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 10)
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
                .controlSize(.large)

                Button("Skip for now", action: skipBirthday)
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .frame(height: 44)
            }
        }
    }

    private func finishWithBirthday() {
        knowsBirthday = true
        finishAction()
    }

    private func skipBirthday() {
        knowsBirthday = false
        finishAction()
    }
}

private func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}

