// FULL UPDATED BUILD: 2026-08-30 23:32 Europe/Belgrade
import SwiftUI
import Foundation
import SwiftData
import UIKit
import PhotosUI
import UserNotifications
import UniformTypeIdentifiers
import Combine
import MetricKit


private enum AwwRefreshMessage {
    static let messages = """
🧠 I’m the person who remembers.
🥹 OMG, you remembered?
❤️ Oh, you remembered.
😭 You actually remembered that?
🥰 That’s so thoughtful.
🤯 How did you remember?
🫶 Wait, you remembered this?
👂 You listened.
✨ You remembered the tiny detail.
🤏 The little things are the big things.
💭 For all the tiny things they mention.
❤️ Remember the little things.
✨ Tiny detail. Big reaction.
📝 Small note. Big moment.
👀 This is why you write it down.
🔮 Future you says thanks.
💨 Save it before it disappears.
🫠 Before you forget.
🧠 You’ll swear you’ll remember.
😅 You probably won’t.
❤️ AwwList it.
👀 She likes this? AwwList it.
💡 He mentioned it? AwwList it.
🎁 This would be perfect for him.
🎀 This would be perfect for her.
🫶 That’s so them.
📌 Save it for later.
💭 Keep that thought.
🧠 Don’t trust your memory.
🔒 Put it somewhere safe.
👀 You’ll need this later.
⏳ Not now. Someday.
🎂 Birthday-you will thank you.
🎄 Christmas-you will thank you.
❤️ Anniversary-you will thank you.
🎁 Future gift solved.
😌 One less thing to remember.
✨ One more thing remembered.
🧠 Memory saved.
💭 Thought saved.
💡 Idea saved.
😮‍💨 Crisis avoided.
🎁 Gift panic prevented.
👏 Nice save.
👀 Good catch.
❤️ That one’s worth saving.
📌 Keep that one.
💨 Don’t let that disappear.
🗂️ File that away.
🫶 Hold onto that.
🌷 She said she loved it.
👟 He said he wanted one.
👀 She mentioned it once.
🤫 He probably forgot saying it.
😏 They won’t expect you to remember.
🧠 They definitely forgot telling you.
😌 You didn’t.
📝 Quietly taking notes.
👂 Listening level: expert.
😏 Thoughtful people cheat.
🧠 The cheat code is remembering.
💭 Being thoughtful is mostly memory.
🎁 Good gifts start months earlier.
💬 The best gifts start in random conversations.
🎂 The best ideas never arrive on birthdays.
📅 Gift ideas happen on Tuesdays.
✨ Great gifts happen by accident.
👀 Catch them when they happen.
👂 Listen now. Win later.
💡 Notice now. Remember later.
👂 Hear it. Save it. Nail it.
👀 See it. Save it. Remember it.
🧠 Notice. Save. Forget. Remember.
📌 Save now. Think later.
😌 Capture now. Relax later.
📝 Write it down and move on.
❤️ Let AwwList remember.
🧠 Your brain has enough going on.
📦 Outsource your memory.
🧠 Consider this your second brain.
🎁 Your gift memory lives here.
🫶 Your people memory lives here.
🔐 Keep the good stuff here.
🕵️ Store the tiny clues.
👀 Save the clues.
🧩 Collect the hints.
💡 Another clue for later.
👀 That sounded like a hint.
🤨 Was that a hint?
😏 Definitely a hint.
📝 Write that down.
👂 You heard that, right?
❤️ That’s going in AwwList.
🗂️ Adding that to the mental file.
😅 Actually, use the real file.
🧠 Mental notes are dangerous.
⏰ Mental notes expire.
📸 Screenshots disappear into the void.
📝 Notes apps become graveyards.
🔗 Where was that link?
📸 I took a screenshot somewhere.
🤦 She mentioned something but I forgot what.
🫠 What was that thing he wanted?
👜 Which bag was it again?
🎨 What color did she say?
👕 What size was he?
💬 Where did she send that?
📱 Was it Instagram or TikTok?
🛍️ Was it Zara or H&M?
🤔 I know she showed me something.
😭 I swear I saved it.
🔗 I definitely had the link.
📸 Somewhere in my camera roll.
💬 Somewhere in our chat.
🫠 Somewhere in 14,000 screenshots.
📍 Keep it where you can find it.
🗂️ One place for all the hints.
⛏️ No more screenshot archaeology.
💬 No more digging through chats.
🤔 No more “what was it again?”
🎁 No more random gifts.
🎂 No more birthday panic.
🏃 No more last-minute guessing.
💭 No more “I had an idea once.”
🔗 No more lost links.
👀 No more forgotten hints.
😏 No more pretending you remembered.
🧠 You remembered because you wrote it down.
😌 That still counts.
❤️ Thoughtful is thoughtful.
🤫 Nobody needs to know your system.
🔒 Your secret is safe here.
🎁 Quietly becoming the best gift giver.
😌 Quietly becoming everyone’s favorite.
😏 Suspiciously good at gifts.
🤨 Almost too good at gifts.
😂 How are you always this good at this?
😏 Lucky guess.
😏 Totally a lucky guess.
🤫 Definitely not saved six months ago.
😇 Just naturally thoughtful, obviously.
🍀 You remembered. Somehow.
🧾 The receipts are in AwwList.
👂 Proof you actually listen.
✨ Listening pays off.
❤️ Attention is a love language.
🥹 Remembering feels different.
🫶 Being seen feels different.
❤️ “You remembered” is the goal.
🥹 That reaction is the whole point.
🎁 The gift is only half of it.
🧠 The memory is the good part.
❤️ It’s not the thing. It’s remembering.
🫶 They wanted to feel noticed.
👀 You noticed.
🕵️ You caught the detail.
🔐 You kept the detail.
✨ You brought it back at the perfect time.
👏 Nice work.
😎 Future legend behavior.
🫶 Elite friend behavior.
👂 Top-tier listening.
🧠 Top-tier remembering.
🔓 Thoughtfulness unlocked.
🎁 Gift-giving unlocked.
🧠 Memory assist activated.
👀 Tiny clue detected.
💡 Gift idea detected.
🔮 Future win detected.
🥹 Potential “OMG” detected.
😭 Potential happy tears detected.
🧾 Save the evidence.
❤️ Save the moment.
💡 Save the idea.
👀 Save the hint.
💬 Save the random comment.
🔗 Save the random link.
📸 Save the random screenshot.
⏳ Save the “maybe someday.”
🥰 Save the “I love this.”
👀 Save the “look at this.”
💭 Save the “I’ve always wanted one.”
🎀 Save the “this is so cute.”
😭 Save the “I need this.”
✨ Save the “one day.”
🫶 Save the “I’d never buy it for myself.”
🕵️ Someone just gave you a clue.
👂 Keep your ears open.
💡 Good ideas are hiding everywhere.
🎁 Your next great gift already happened.
👀 You just haven’t saved it yet.
📝 One tiny note can make their day.
❤️ Remember what matters to them.
🫶 Keep the things that make them them.
🧠 Be the one who remembers.
❤️ AwwList remembers with you.
""".split(separator: "\n").map(String.init)

    static func random(excluding message: String?) -> String {
        messages.filter { $0 != message }.randomElement()
            ?? "❤️ AwwList remembers with you."
    }
}

private struct AwwRefreshControlBranding: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        UIView(frame: .zero)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.attach(to: uiView)
    }

    final class Coordinator: NSObject {
        private weak var refreshControl: UIRefreshControl?
        private weak var scrollView: UIScrollView?
        private var refreshStateObservation: NSKeyValueObservation?
        private var messageTimer: Timer?
        private var attachmentAttempts = 0
        private var currentMessage: String?

        deinit {
            messageTimer?.invalidate()
        }

        func attach(to view: UIView) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard let scrollView = Self.enclosingScrollView(for: view),
                      let refreshControl = scrollView.refreshControl else {
                    guard self.attachmentAttempts < 10 else { return }
                    self.attachmentAttempts += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.attach(to: view)
                    }
                    return
                }

                self.attachmentAttempts = 0
                guard self.refreshControl !== refreshControl else { return }

                self.refreshStateObservation?.invalidate()
                self.scrollView = scrollView
                self.refreshControl = refreshControl
                self.prepareNextMessage()
                self.startMessageTimer()

                self.refreshStateObservation = refreshControl.observe(
                    \.isRefreshing,
                    options: [.new]
                ) { [weak self] _, change in
                    guard let isRefreshing = change.newValue else { return }

                    if isRefreshing {
                        self?.prepareNextMessage()
                    } else {
                        self?.prepareMessageAfterDismissal()
                    }
                }
            }
        }

        private func startMessageTimer() {
            messageTimer?.invalidate()

            let timer = Timer(timeInterval: 30, repeats: true) { [weak self] _ in
                self?.prepareNextMessage()
            }
            messageTimer = timer
            RunLoop.main.add(timer, forMode: .common)
        }

        private func prepareMessageAfterDismissal(attempt: Int = 0) {
            guard let refreshControl, let scrollView else { return }

            let restingOffset = -scrollView.adjustedContentInset.top
            guard scrollView.contentOffset.y < restingOffset - 1, attempt < 30 else {
                prepareNextMessage()
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard refreshControl.isRefreshing == false else { return }
                self?.prepareMessageAfterDismissal(attempt: attempt + 1)
            }
        }

        private func prepareNextMessage() {
            let message = AwwRefreshMessage.random(excluding: currentMessage)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.secondaryLabel
            ]
            refreshControl?.attributedTitle = NSAttributedString(
                string: message,
                attributes: attributes
            )
            currentMessage = message
        }

        private static func enclosingScrollView(for view: UIView) -> UIScrollView? {
            sequence(first: view.superview, next: { $0?.superview })
                .compactMap { $0 as? UIScrollView }
                .first
        }
    }
}


// MARK: - Local diagnostics

nonisolated final class AwwLocalDiagnosticsReporter: NSObject, MXMetricManagerSubscriber {
    static let shared = AwwLocalDiagnosticsReporter()

    private let writerQueue = DispatchQueue(
        label: "AwwList.LocalDiagnostics",
        qos: .utility
    )

    private override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    deinit {
        MXMetricManager.shared.remove(self)
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        persist(
            payloads.map { $0.jsonRepresentation() },
            prefix: "diagnostic"
        )
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        persist(
            payloads.map { $0.jsonRepresentation() },
            prefix: "metric"
        )
    }

    private func persist(_ payloads: [Data], prefix: String) {
        guard !payloads.isEmpty else { return }

        writerQueue.async {
            guard let base = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first else { return }

            let folder = base
                .appendingPathComponent("AwwList", isDirectory: true)
                .appendingPathComponent("Diagnostics", isDirectory: true)

            do {
                try FileManager.default.createDirectory(
                    at: folder,
                    withIntermediateDirectories: true
                )

                let formatter = ISO8601DateFormatter()
                let stamp = formatter
                    .string(from: .now)
                    .replacingOccurrences(of: ":", with: "-")

                for (index, data) in payloads.enumerated() {
                    let target = folder.appendingPathComponent(
                        "\(prefix)-\(stamp)-\(index).json"
                    )
                    try data.write(to: target, options: .atomic)
                }
            } catch {
                UserDefaults.standard.set(
                    String(describing: error),
                    forKey: "lastDiagnosticsWriteError"
                )
            }
        }
    }
}

nonisolated struct AwwForegroundReminder: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let body: String
    let url: URL?
}

@MainActor
final class NotificationRouteCoordinator: ObservableObject {
    static let shared = NotificationRouteCoordinator()

    @Published var pendingURL: URL?

    func handle(url: URL) {
        guard url.scheme?.lowercased() == AwwDeepLink.scheme else { return }
        pendingURL = url
    }

    func handle(userInfo: [AnyHashable: Any]) {
        pendingURL = Self.url(from: userInfo)
    }

    func consume() {
        pendingURL = nil
    }

    nonisolated static func url(from userInfo: [AnyHashable: Any]) -> URL? {
        if let rawIdeaID = (userInfo["ideaID"] ?? userInfo["wishID"]) as? String,
           let ideaID = UUID(uuidString: rawIdeaID) {
            return AwwDeepLink.wish(ideaID)
        }

        if let rawPersonID = userInfo["personID"] as? String,
           let personID = UUID(uuidString: rawPersonID) {
            return AwwDeepLink.person(personID)
        }

        if let rawCategoryID = userInfo["categoryID"] as? String,
           let categoryID = UUID(uuidString: rawCategoryID) {
            return AwwDeepLink.category(categoryID)
        }

        if let category = userInfo["category"] as? String, !category.isEmpty {
            if let categoryID = UUID(uuidString: category) {
                return AwwDeepLink.category(categoryID)
            }
            return AwwDeepLink.legacyCategory(category)
        }

        if (userInfo["openComposer"] as? Bool) == true {
            return URL(string: "\(AwwDeepLink.scheme)://composer")
        }

        return nil
    }
}

nonisolated final class AwwListNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        let reminder = AwwForegroundReminder(
            title: content.title.isEmpty ? "AwwList reminder" : content.title,
            body: content.body,
            url: NotificationRouteCoordinator.url(from: content.userInfo)
        )

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .awwForegroundReminder,
                object: reminder
            )
        }

        // The app is already visible, so use the in-app reminder state only.
        completionHandler([])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let url = NotificationRouteCoordinator.url(
            from: response.notification.request.content.userInfo
        )

        Task { @MainActor in
            let coordinator = NotificationRouteCoordinator.shared
            if let url {
                coordinator.handle(url: url)
            }

            if coordinator.pendingURL == nil {
                UserDefaults.standard.set(
                    true,
                    forKey: NotificationScheduler.openIdeaComposerKey
                )
            }

            completionHandler()
        }
    }
}

@main
struct AwwListApp: App {
    @StateObject private var routes = NotificationRouteCoordinator.shared
    private let notificationDelegate = AwwListNotificationDelegate()
    private let diagnosticsReporter = AwwLocalDiagnosticsReporter.shared

    init() {
        NotificationScheduler.configureCategories()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            Root()
                .tint(.red)
                .environmentObject(routes)
                .onOpenURL { url in
                    routes.handle(url: url)
                }
        }
        .modelContainer(for: [
            AwwUser.self,
            Category.self,
            Person.self,
            Idea.self,
            IdeaAttachment.self,
            Occasion.self,
            AwwReminder.self,
            AwwShareGrant.self,
            AwwSyncRecord.self
        ])
    }
}


// MARK: - Root

struct Root: View {
    @AppStorage("onboarded")
    private var onboarded = false

    @AppStorage("hasMigratedWishStatusNamesV2")
    private var hasMigratedWishStatusNamesV2 = false

    @Environment(\.modelContext)
    private var context

    @Environment(\.scenePhase)
    private var scenePhase

    @Query(sort: \Idea.created)
    private var ideas: [Idea]

    @State private var localDataError = ""

    var body: some View {
        Group {
            if onboarded {
                Home()
                    .task {
                        prepareData()
                    }
            } else {
                Onboarding(finish: completeOnboarding)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase != .active else { return }
            _ = AwwPersistence.save(context)
        }
        .alert(
            "AwwList couldn’t save local data",
            isPresented: Binding(
                get: { !localDataError.isEmpty },
                set: { if !$0 { localDataError = "" } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(localDataError)
        }
    }

    private func completeOnboarding(
        name: String,
        emoji: String,
        profileImage: Data?,
        birthday: Date?
    ) {
        do {
            let account = try AwwAccountManager.ensureLocalAccount(context: context)
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let owner = try AwwAccountManager.ensureOwnerPerson(
                preferredName: cleanName,
                context: context
            )

            owner.name = cleanName.isEmpty ? (account.displayName.isEmpty ? "Me" : account.displayName) : cleanName
            owner.ownerUserID = account.id
            owner.relation = "Me"
            owner.birthday = birthday
            owner.emoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "❤️" : emoji
            owner.profileImage = profileImage
            owner.isOwner = true
            owner.updated = .now
            ensureOwnerWelcomeWish(for: owner)

            if !cleanName.isEmpty {
                account.displayName = cleanName
                account.updatedAt = .now
            }

            try AwwAccountManager.migrateLegacyData(to: account.id, context: context)
            try context.save()

            UserDefaults.standard.set(true, forKey: "showFirstGiftTip")
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            onboarded = true
        } catch {
            localDataError = "Your information is still on this screen. AwwList could not write it to the local database: \(error.localizedDescription)"
        }
    }

    private func prepareData() {
        do {
            let account = try AwwAccountManager.ensureLocalAccount(context: context)
            try AwwAccountManager.migrateLegacyData(to: account.id, context: context)
            let owner = try AwwAccountManager.ensureOwnerPerson(
                preferredName: account.displayName,
                context: context
            )

            ensureOwnerWelcomeWish(for: owner)
            migrateWishStatusNamesV2()
            repairOrphanedData(using: owner)
            try context.save()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
        } catch {
            localDataError = "AwwList could not prepare the local database: \(error.localizedDescription)"
        }
    }

    private func repairOrphanedData(using owner: Person) {
        for idea in ideas where idea.person == nil {
            idea.person = owner
            idea.personIDs = [owner.id]
            idea.ownerUserID = owner.ownerUserID
            idea.updated = .now
        }
    }

    private func ensureOwnerWelcomeWish(for owner: Person) {
        let storageKey = "hasCreatedOwnerWelcomeWish"
        guard !UserDefaults.standard.bool(forKey: storageKey) else { return }
      
        let welcomeWish = Idea(
            "🎂 Tiny vintage birthday cake",
            note: """
            I saw one of those tiny heart cakes on TikTok and said:

            “Wait this is so cute I NEED one for my birthday 😭”

            Pink frosting. Cherries on top. Very dramatic.
            Future me, you know what to do.

            Tip: Hold any wish to pin or delete it.
            """,
            status: "Would love",
            wish: true,
            person: owner,
            ownerUserID: owner.ownerUserID
        )
        context.insert(welcomeWish)

        if let cakeImageData = UIImage(named: "VintageBirthdayCake")?.pngData() {
            let cakeImage = IdeaAttachment(
                filename: "Vintage birthday cake",
                contentType: UTType.png.identifier,
                kind: "image",
                data: cakeImageData,
                idea: welcomeWish
            )
            context.insert(cakeImage)
        }

        UserDefaults.standard.set(true, forKey: storageKey)
    }

    private func migrateWishStatusNamesV2() {
        guard !hasMigratedWishStatusNamesV2 else { return }

        for idea in ideas {
            switch idea.status {
            case "Maybe":
                idea.status = "Would love"
            case "Definitely":
                idea.status = "Most wanted"
            default:
                break
            }
            idea.updated = .now
        }

        hasMigratedWishStatusNamesV2 = true
    }
}


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

private struct OnboardingCenteredShell<Content: View, Footer: View>: View {
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

private struct OnboardingBrandMark: View {
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

private struct AwwListLogoMark: View {
    var body: some View {
        AwwListLogoPath()
            .fill(
                Color(red: 0.94, green: 0.17, blue: 0.15),
                style: FillStyle(eoFill: true)
            )
            .accessibilityHidden(true)
    }
}

private struct AwwListLogoPath: Shape {
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

private struct OnboardingWishRow: View {
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

// MARK: - Interaction polish

let awwDefaultCategories = ["Beauty", "Books", "Fashion", "Home", "Tech"]

enum AwwCategoryPreferences {
    private static let deletedDefaultsKey = "AwwList.deletedDefaultCategories"
    private static let renamedDefaultsKey = "AwwList.renamedDefaultCategories"

    static var visibleDefaults: [String] {
        let deleted = Set(
            UserDefaults.standard.stringArray(forKey: deletedDefaultsKey) ?? []
        )
        let renamed = UserDefaults.standard.dictionary(
            forKey: renamedDefaultsKey
        ) as? [String: String] ?? [:]

        return awwDefaultCategories.compactMap { original in
            let key = original.lowercased()
            guard !deleted.contains(key) else { return nil }
            return renamed[key] ?? original
        }
    }

    static func deleteDefault(named visibleName: String) {
        guard let originalKey = originalKey(forVisibleName: visibleName) else {
            return
        }

        var deleted = Set(
            UserDefaults.standard.stringArray(forKey: deletedDefaultsKey) ?? []
        )
        deleted.insert(originalKey)
        UserDefaults.standard.set(
            Array(deleted).sorted(),
            forKey: deletedDefaultsKey
        )
    }

    static func renameDefault(from visibleName: String, to newName: String) {
        guard let originalKey = originalKey(forVisibleName: visibleName) else {
            return
        }

        var renamed = UserDefaults.standard.dictionary(
            forKey: renamedDefaultsKey
        ) as? [String: String] ?? [:]
        renamed[originalKey] = newName
        UserDefaults.standard.set(
            renamed,
            forKey: renamedDefaultsKey
        )
    }

    private static func originalKey(forVisibleName visibleName: String) -> String? {
        let renamed = UserDefaults.standard.dictionary(
            forKey: renamedDefaultsKey
        ) as? [String: String] ?? [:]

        for original in awwDefaultCategories {
            let key = original.lowercased()
            let currentName = renamed[key] ?? original

            if currentName.localizedCaseInsensitiveCompare(visibleName) == .orderedSame {
                return key
            }
        }

        return nil
    }
}

func replacingCategoryHashtag(
    in text: String,
    category oldCategory: String,
    with newCategory: String?
) -> String {
    let escaped = NSRegularExpression.escapedPattern(for: oldCategory)
    let pattern = "(?i)(?<!\\S)#\(escaped)(?=$|\\s|[.,!?;:])"

    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return text
    }

    let range = NSRange(text.startIndex..., in: text)
    let replacement = newCategory.map { "#\($0)" } ?? ""
    let result = regex.stringByReplacingMatches(
        in: text,
        options: [],
        range: range,
        withTemplate: replacement
    )

    return result
        .replacingOccurrences(
            of: #"[ \t]{2,}"#,
            with: " ",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"\n[ \t]+"#,
            with: "\n",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

private struct AwwFloatingKeyboardModifier: ViewModifier {
    @State private var isFloatingKeyboard = false

    func body(content: Content) -> some View {
        content
            .ignoresSafeArea(
                .keyboard,
                edges: isFloatingKeyboard ? .bottom : []
            )
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillChangeFrameNotification
                )
            ) { notification in
                updateKeyboardState(notification)
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIResponder.keyboardWillHideNotification
                )
            ) { _ in
                isFloatingKeyboard = false
            }
    }

    private func updateKeyboardState(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .pad,
              let frameValue = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
              ] as? NSValue else {
            isFloatingKeyboard = false
            return
        }

        let frame = frameValue.cgRectValue
        guard let screenBounds = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .screen.bounds else {
            isFloatingKeyboard = false
            return
        }

        let isVisible = frame.minY < screenBounds.maxY && frame.height > 0
        let isDockedToBottom = abs(frame.maxY - screenBounds.maxY) < 10
        let isNearlyFullWidth = frame.width >= screenBounds.width * 0.82

        isFloatingKeyboard =
            isVisible
            && (!isDockedToBottom || !isNearlyFullWidth)
    }
}

extension View {
    func awwStableForFloatingKeyboard() -> some View {
        modifier(AwwFloatingKeyboardModifier())
    }
}

extension Notification.Name {
    static let awwDataDidChange = Notification.Name("AwwList.dataDidChange")
    static let awwOpenDeepLink = Notification.Name("AwwList.openDeepLink")
    static let awwWishSaved = Notification.Name("AwwList.wishSaved")
    static let awwForegroundReminder = Notification.Name("AwwList.foregroundReminder")
}

nonisolated enum AwwAppLimits {
    static let recentWishScanLimit = 120
    static let searchResultLimit = 200
    static let contentMaxWidth: CGFloat = 760
    static let detailMaxWidth: CGFloat = 900
    static let composerMaxWidth: CGFloat = 620
}

enum AwwPersistence {
    @discardableResult
    @MainActor
    static func save(_ context: ModelContext) -> Bool {
        do {
            try context.save()
            UserDefaults.standard.removeObject(forKey: "lastLocalSaveError")
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            return true
        } catch {
            UserDefaults.standard.set(
                String(describing: error),
                forKey: "lastLocalSaveError"
            )
            return false
        }
    }
}

nonisolated enum AwwLocale {
    static var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    static func decimalString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    static func parseDecimal(_ value: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true

        let trimmed = value
            .replacingOccurrences(of: currencyCode, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return formatter.number(from: trimmed)?.doubleValue
    }
}

enum AwwHaptics {
    static var enabled: Bool {
        UserDefaults.standard.object(forKey: "haptics") as? Bool ?? true
    }

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func soft() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func warning() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func deleted() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.9)
    }

    static func selection() {
        guard enabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

enum AwwDeepLink {
    nonisolated static let scheme = "awwlist"

    nonisolated static func person(_ id: UUID) -> URL {
        URL(string: "\(scheme)://person/\(id.uuidString)")!
    }

    nonisolated static func wish(_ id: UUID) -> URL {
        URL(string: "\(scheme)://wish/\(id.uuidString)")!
    }

    nonisolated static func category(_ id: UUID) -> URL {
        URL(string: "\(scheme)://category/\(id.uuidString)")!
    }

    nonisolated static func legacyCategory(_ name: String) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "category"
        components.path = "/" + name
        return components.url!
    }

    nonisolated static func category(_ name: String) -> URL {
        legacyCategory(name)
    }

    nonisolated static func reminder(_ id: UUID) -> URL {
        URL(string: "\(scheme)://reminder/\(id.uuidString)")!
    }

    static func copy(_ url: URL) {
        UIPasteboard.general.url = url
        AwwHaptics.success()
    }

    static func postOpen(_ url: URL) {
        NotificationCenter.default.post(
            name: .awwOpenDeepLink,
            object: url
        )
    }
}


enum AwwShareBridge {
    struct SharedPerson: Codable, Identifiable {
        let id: UUID
        let name: String
        let emoji: String
        let isOwner: Bool
    }

    struct PendingShare: Codable, Identifiable {
        let id: UUID
        let text: String
        let note: String?
        let urlString: String?
        let attachment: SharedAttachment?
        let recipientIDs: [UUID]
        let created: Date
    }

    struct SharedAttachment: Codable {
        let filename: String
        let contentType: String
        let kind: String
        let relativePath: String?
    }

    private static let peopleKey = "AwwList.sharedPeople.v1"
    private static let pendingKey = "AwwList.pendingShares.v1"
    private static let sharedAppGroupID = "group.com.stefanbozovic.awwlist"

    static var appGroupID: String? {
        sharedAppGroupID
    }

    private static var defaults: UserDefaults? {
        guard let appGroupID, !appGroupID.isEmpty else { return nil }
        return UserDefaults(suiteName: appGroupID)
    }

    static func mirrorPeople(_ people: [Person]) {
        guard let defaults else { return }
        let snapshots = people.map {
            SharedPerson(id: $0.id, name: $0.name, emoji: $0.emoji, isOwner: $0.isOwner)
        }
        guard let data = try? JSONEncoder().encode(snapshots) else { return }
        defaults.set(data, forKey: peopleKey)
    }

    @MainActor
    static func importPendingShares(
        context: ModelContext,
        people: [Person]
    ) {
        guard let defaults,
              let data = defaults.data(forKey: pendingKey),
              let queued = try? JSONDecoder().decode([PendingShare].self, from: data),
              !queued.isEmpty else {
            return
        }

        let peopleByID = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        var importedIDs = Set<UUID>()

        for share in queued {
            let recipients = share.recipientIDs.compactMap { peopleByID[$0] }
            guard !recipients.isEmpty else { continue }

            let cleanText = share.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let sharedURL = share.urlString.flatMap(URL.init(string:))
            let isURLOnlyShare = cleanText.isEmpty
                || cleanText == sharedURL?.absoluteString
            let title: String
            if let attachment = share.attachment, isURLOnlyShare {
                title = attachment.kind == "image" ? "Shared image" : attachment.filename
            } else {
                title = cleanText.isEmpty
                    ? (sharedURL?.absoluteString ?? "Shared product")
                    : cleanText
            }

            for person in recipients {
                let idea = Idea(
                    title,
                    note: share.note ?? "",
                    category: "",
                    status: "Would love",
                    person: person
                )

                if share.attachment == nil,
                   let sharedURL,
                   isHTTPURL(sharedURL) {
                    let attachment = IdeaAttachment(
                        filename: sharedURL.host() ?? sharedURL.absoluteString,
                        contentType: UTType.url.identifier,
                        kind: "link",
                        linkURL: sharedURL.absoluteString,
                        idea: idea
                    )
                    context.insert(attachment)
                }

                if let attachment = share.attachment,
                   let data = sharedAttachmentData(attachment) {
                    let importedAttachment = IdeaAttachment(
                        filename: attachment.filename,
                        contentType: attachment.contentType,
                        kind: attachment.kind,
                        data: data,
                        idea: idea
                    )
                    context.insert(importedAttachment)
                }

                context.insert(idea)
            }

            importedIDs.insert(share.id)
        }

        guard !importedIDs.isEmpty else { return }

        if AwwPersistence.save(context) {
            for share in queued where importedIDs.contains(share.id) {
                removeSharedAttachment(share.attachment)
            }
            let remaining = queued.filter { !importedIDs.contains($0.id) }
            if remaining.isEmpty {
                defaults.removeObject(forKey: pendingKey)
            } else if let encoded = try? JSONEncoder().encode(remaining) {
                defaults.set(encoded, forKey: pendingKey)
            }
        }
    }

    private static func sharedAttachmentData(_ attachment: SharedAttachment) -> Data? {
        guard let relativePath = attachment.relativePath,
              let container = FileManager.default.containerURL(
                  forSecurityApplicationGroupIdentifier: sharedAppGroupID
              ) else {
            return nil
        }
        return try? Data(contentsOf: container.appendingPathComponent(relativePath))
    }

    private static func removeSharedAttachment(_ attachment: SharedAttachment?) {
        guard let relativePath = attachment?.relativePath,
              let container = FileManager.default.containerURL(
                  forSecurityApplicationGroupIdentifier: sharedAppGroupID
              ) else {
            return
        }
        try? FileManager.default.removeItem(at: container.appendingPathComponent(relativePath))
    }
}



private struct AwwUndoCard: View {
    let message: String
    let undo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.title3)
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline.weight(.semibold))

            Spacer(minLength: 8)

            Button("Undo", action: undo)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.red)
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 50)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 18,
            x: 0,
            y: 8
        )
    }
}


// MARK: - Home

private struct CategorySheetRoute: Identifiable, Equatable {
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


// MARK: - Wish Search

struct WishSearch: View {
    private struct SearchRecord: Sendable {
        let id: UUID
        let haystack: String
    }

    @Query(sort: \Idea.created, order: .reverse)
    private var ideas: [Idea]

    @State private var query = ""
    @State private var searchIndex: [SearchRecord] = []
    @State private var ideaByID: [UUID: Idea] = [:]
    @State private var resultIDs: [UUID] = []
    @State private var hasCompletedSearch = false
    @State private var searchTask: Task<Void, Never>?

    @Environment(\.dismiss)
    private var dismiss

    private var matchingIdeas: [Idea] {
        resultIDs.compactMap { ideaByID[$0] }
    }

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ContentUnavailableView(
                        "Search saved wishes",
                        systemImage: "magnifyingglass",
                        description: Text("Search by wish, note, category, or person.")
                    )
                } else if hasCompletedSearch && matchingIdeas.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(matchingIdeas) { idea in
                        WishSearchResult(idea: idea)
                    }
                }
            }
            .navigationTitle("Search wishes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search every person's wishes")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: rebuildSearchIndex)
            .onChange(of: query) { _, newValue in
                scheduleSearch(for: newValue)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .awwDataDidChange)
            ) { _ in
                rebuildSearchIndex()
                scheduleSearch(for: query)
            }
            .onDisappear {
                searchTask?.cancel()
            }
        }
    }

    private func rebuildSearchIndex() {
        ideaByID = Dictionary(
            uniqueKeysWithValues: ideas.map { ($0.id, $0) }
        )

        searchIndex = ideas.map { idea in
            SearchRecord(
                id: idea.id,
                haystack: [
                    idea.title,
                    idea.note,
                    idea.category,
                    idea.person?.name ?? ""
                ]
                .joined(separator: "\n")
                .folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
            )
        }
    }

    private func scheduleSearch(for rawQuery: String) {
        searchTask?.cancel()

        let needle = rawQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .current
            )

        guard !needle.isEmpty else {
            resultIDs = []
            hasCompletedSearch = false
            return
        }

        let records = searchIndex
        hasCompletedSearch = false

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(160))
            guard !Task.isCancelled else { return }

            let ids = await Task.detached(priority: .userInitiated) {
                Array(
                    records.lazy
                        .filter { $0.haystack.contains(needle) }
                        .prefix(AwwAppLimits.searchResultLimit)
                        .map(\.id)
                )
            }.value

            guard !Task.isCancelled else { return }
            resultIDs = ids
            hasCompletedSearch = true
        }
    }
}


struct WishSearchResult: View {
    let idea: Idea

    var body: some View {
        Group {
            if let person = idea.person {
                NavigationLink {
                    Detail(person: person)
                } label: {
                    row
                }
            } else {
                row
            }
        }
    }

    private var row: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(idea.title)
                .font(.headline)

            Text(idea.person?.name ?? "Unknown person")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !idea.note.isEmpty {
                Text(idea.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

enum WishDisplayStyle: String, CaseIterable, Identifiable {
    case grid
    case list

    var id: Self { self }

    var title: String {
        switch self {
        case .grid:
            return "Grid"
        case .list:
            return "List"
        }
    }

    var symbol: String {
        switch self {
        case .grid:
            return "square.grid.2x2"
        case .list:
            return "list.bullet"
        }
    }
}

struct GiftGridHeader: View {
    let search: () -> Void

    @Binding
    var selectedStatus: IdeaStatus?

    @Binding
    var displayStyle: WishDisplayStyle

    private var isCustomized: Bool {
        selectedStatus != nil || displayStyle != .grid
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("Wishes")
                .font(.title2.weight(.bold))

            Spacer()

            Button(action: search) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Search wishes")

            Menu {
                Menu(
                    "Status",
                    systemImage: "line.3.horizontal.decrease"
                ) {
                    Button {
                        selectedStatus = nil
                    } label: {
                        if selectedStatus == nil {
                            Label("All wishes", systemImage: "checkmark")
                        } else {
                            Text("All wishes")
                        }
                    }

                    Divider()

                    ForEach(IdeaStatus.allCases) { status in
                        Button {
                            selectedStatus = status
                        } label: {
                            if selectedStatus == status {
                                Label(status.title, systemImage: "checkmark")
                            } else {
                                Text(status.title)
                            }
                        }
                    }
                }

                Menu(
                    "View",
                    systemImage: displayStyle.symbol
                ) {
                    ForEach(WishDisplayStyle.allCases) { style in
                        Button {
                            displayStyle = style
                        } label: {
                            if displayStyle == style {
                                Label(style.title, systemImage: "checkmark")
                            } else {
                                Label(style.title, systemImage: style.symbol)
                            }
                        }
                    }
                }

                if isCustomized {
                    Divider()

                    Button("Reset view", systemImage: "arrow.counterclockwise") {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedStatus = nil
                            displayStyle = .grid
                        }
                        AwwHaptics.selection()
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.bold))
                    .foregroundStyle(isCustomized ? Color.red : Color.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        isCustomized
                            ? Color.red.opacity(0.11)
                            : Color.primary.opacity(0.055),
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                isCustomized
                                    ? Color.red.opacity(0.22)
                                    : Color.primary.opacity(0.08),
                                lineWidth: 1
                            )
                    }
                    .animation(.snappy(duration: 0.2), value: isCustomized)
            }
            .accessibilityLabel(
                isCustomized ? "Wish options, customized" : "Wish options"
            )
        }
    }
}

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


// MARK: - Idea Form

enum IdeaStatus: String, CaseIterable, Identifiable {
    case wouldLove = "Would love"
    case mostWanted = "Most wanted"
    case given = "Given"

    var id: Self { self }

    var title: String { rawValue }
}

struct IdeaForm: View {
    let person: Person
    let idea: Idea?

    @Query
    private var ideas: [Idea]

    @Environment(\.modelContext)
    private var context

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var title: String

    @State
    private var note: String

    @State
    private var price: String

    @State
    private var category: String

    @State
    private var status: String

    @State
    private var duplicate = false

    @State
    private var showingPriceField = false

    @State
    private var showingCategoryMenu = false

    @State private var showDiscardChanges = false
    @State private var didSave = false
    @State private var showSaveError = false

    @FocusState
    private var isComposerFocused: Bool

    init(person: Person, idea: Idea? = nil) {
        self.person = person
        self.idea = idea
        _title = State(initialValue: idea?.title ?? "")
        _note = State(initialValue: idea?.note ?? "")
        _price = State(
            initialValue: idea?.price.map(AwwLocale.decimalString) ?? ""
        )
        _category = State(initialValue: idea?.category ?? "")
        _status = State(initialValue: idea?.status ?? "Would love")
        _showingPriceField = State(initialValue: idea?.price != nil)
    }

    private let statuses = [
        "Would love",
        "Most wanted",
        "Given"
    ]

    private var hasUnsavedChanges: Bool {
        guard !didSave else { return false }
        if let idea {
            return title != idea.title || note != idea.note
                || price != (idea.price.map(AwwLocale.decimalString) ?? "")
                || category != idea.category || status != idea.status
        }
        return !cleanTitle.isEmpty || !note.isEmpty || !price.isEmpty || !category.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                recipientHeader

                Spacer(minLength: 0)

                composer
                    .frame(maxWidth: AwwAppLimits.composerMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .background(Backdrop())
            .navigationTitle(idea == nil ? "New gift" : "Edit gift")
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
            }
            .confirmationDialog("Choose a category", isPresented: $showingCategoryMenu) {
                ForEach(existingCategories, id: \.self) { existingCategory in
                    Button(existingCategory) {
                        category = existingCategory
                    }
                }

                if !category.isEmpty {
                    Button("Remove category", role: .destructive) {
                        category = ""
                    }
                }
            } message: {
                Text("Type # followed by a category in your gift idea to create a new one.")
            }
            .onChange(of: title) { _, newTitle in
                updateCategoryFromHashtag(in: newTitle)
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
            .alert("Discard unsaved changes?", isPresented: $showDiscardChanges) {
                Button("Keep editing", role: .cancel) {}
                Button("Discard", role: .destructive) { dismiss() }
            } message: {
                Text("Your unsaved gift idea will be lost.")
            }
            .alert("Couldn’t save this wish", isPresented: $showSaveError) {
                Button("Try again") { save() }
                Button("Keep editing", role: .cancel) {}
            } message: {
                Text("Your draft is still here. Nothing was intentionally removed.")
            }
            .alert("Looks familiar", isPresented: $duplicate) {
                Button(
                    "Save anyway"
                ) {
                    save()
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) {}
            } message: { Text("This may already be saved on this profile.") }
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(
                "Add a gift idea… #category",
                text: $title,
                axis: .vertical
            )
            .font(.body)
            .lineLimit(1...4)
            .focused($isComposerFocused)

            if isComposerFocused || !note.isEmpty {
                TextField(
                    "Add a note (optional)",
                    text: $note,
                    axis: .vertical
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1...3)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if showingPriceField {
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            composerControls
        }
        .padding(14)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.primary.opacity(0.06))
        }
        .animation(.snappy, value: isComposerFocused)
        .animation(.snappy, value: showingPriceField)
    }

    private var recipientHeader: some View {
        HStack(spacing: 12) {
            Avatar(person: person, size: 42)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Adding to \(person.name)’s list")
                        .font(.headline)

                    WishCountBadge(
                        count: person.ideas.count,
                        avatarSize: 48
                    )
                }

                Text("Use # to add a category as you type.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    private var composerControls: some View {
        HStack(spacing: 8) {
            Button {
                showingPriceField.toggle()
            } label: {
                Label(price.isEmpty ? "Price" : price, systemImage: "tag")
            }
            .buttonStyle(.bordered)

            Button {
                showingCategoryMenu = true
            } label: {
                Label(category.isEmpty ? "Category" : "#\(category)", systemImage: "number")
            }
            .buttonStyle(.bordered)

            Menu {
                Picker("Status", selection: $status) {
                    ForEach(statuses, id: \.self) { state in
                        Text(state)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .frame(width: 36, height: 36)
            }

            Spacer(minLength: 0)

            Button(action: checkForDuplicate) {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .frame(width: 42, height: 42)
                    .background(.red, in: Circle())
                    .foregroundStyle(.white)
            }
            .disabled(cleanTitle.isEmpty)
            .accessibilityLabel("Save gift idea")
        }
    }

    private var existingCategories: [String] {
        Array(Set(ideas.map(\.category).filter { !$0.isEmpty })).sorted()
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateCategoryFromHashtag(in value: String) {
        guard let hashtag = value.split(whereSeparator: \.isWhitespace).last(where: { $0.hasPrefix("#") && $0.count > 1 }) else {
            return
        }

        category = hashtag.dropFirst().trimmingCharacters(in: .punctuationCharacters)
    }

    private func checkForDuplicate() {
        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let alreadyExists =
            person.ideas.contains {
                $0.title
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    .localizedCaseInsensitiveCompare(
                        cleanTitle
                    )
                    == .orderedSame
            }

        if alreadyExists {
            duplicate = true
        } else {
            save()
        }
    }

    private func save() {
        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if let idea {
            idea.ownerUserID = idea.ownerUserID ?? AwwIdentityCache.userID
            idea.personIDs = idea.personIDs?.isEmpty == false
                ? idea.personIDs
                : [person.id]
            idea.title = cleanTitle
            idea.note = note
            idea.price = AwwLocale.parseDecimal(price)
            idea.status = status
            try? AwwCategoryStore.assign(
                names: categoryValues(from: category),
                to: idea,
                context: context
            )
            idea.updated = .now
        } else {
            let newIdea = Idea(
                cleanTitle,
                note: note,
                price: AwwLocale.parseDecimal(price),
                category: category,
                status: status,
                person: person,
                personIDs: [person.id],
                ownerUserID: AwwIdentityCache.userID
            )

            try? AwwCategoryStore.assign(
                names: categoryValues(from: category),
                to: newIdea,
                context: context
            )
            context.insert(newIdea)
        }

        guard AwwPersistence.save(context) else {
            AwwHaptics.warning()
            showSaveError = true
            return
        }

        didSave = true
        AwwHaptics.success()
        dismiss()
    }
}


// MARK: - Wish Detail

struct WishDetail: View {
    let person: Person
    let idea: Idea

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var context

    @Query(sort: \Idea.updated, order: .reverse)
    private var allIdeas: [Idea]

    @State private var bodyText: String
    @State private var categories: [String]
    @State private var status: String
    @State private var priceDraft: String
    @State private var showingPriceAlert = false
    @State private var selectedCategoryRoute: CategorySheetRoute?
    @State private var showingPhotoPicker = false
    @State private var showingFileImporter = false
    @State private var showingCamera = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var cameraImageData: Data?
    @State private var textFocusRequest = 0
    @State private var autosaveTask: Task<Void, Never>?

    init(person: Person, idea: Idea) {
        self.person = person
        self.idea = idea

        let combined = [idea.title, idea.note]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n")

        let savedCategories = categoryValues(from: idea.category)
        let categoriesAlreadyInText = hashtagCategoryValues(in: combined)
        let missingCategories = savedCategories.filter { saved in
            !categoriesAlreadyInText.contains {
                $0.localizedCaseInsensitiveCompare(saved) == .orderedSame
            }
        }
        let missingHashtags = missingCategories
            .map { "#\($0)" }
            .joined(separator: " ")
        let initialText: String
        if combined.isEmpty {
            initialText = missingHashtags
        } else if missingHashtags.isEmpty {
            initialText = combined
        } else {
            initialText = combined + "\n\n" + missingHashtags
        }

        _bodyText = State(initialValue: initialText)
        _categories = State(initialValue: uniqueCategoryValues(savedCategories + categoriesAlreadyInText))
        _status = State(initialValue: idea.status)
        _priceDraft = State(
            initialValue: idea.price.map(AwwLocale.decimalString) ?? ""
        )
    }

    private var hashtagQuery: String? {
        currentHashtagQuery(in: bodyText)
    }

    private var existingCategories: [String] {
        uniqueCategoryValues(
            allIdeas.flatMap {
                categoryValues(from: $0.category)
            }
        )
        .sorted()
    }

    private var categorySuggestions: [String] {
        guard let hashtagQuery else { return [] }

        let options = uniqueCategoryValues(
            AwwCategoryPreferences.visibleDefaults + existingCategories
        )

        if hashtagQuery.isEmpty {
            return Array(options.sorted().prefix(6))
        }

        if options.contains(where: {
            $0.localizedCaseInsensitiveCompare(hashtagQuery) == .orderedSame
        }) {
            return []
        }

        return options
            .filter { $0.localizedCaseInsensitiveContains(hashtagQuery) }
            .sorted()
            .prefix(6)
            .map { $0 }
    }

    private var personDisplayName: String {
        person.name
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)
            ?? person.name
    }

    private var orderedAttachments: [IdeaAttachment] {
        idea.attachments.sorted {
            if $0.created == $1.created {
                return $0.id.uuidString < $1.id.uuidString
            }
            return $0.created < $1.created
        }
    }

    var body: some View {
        wishLifecycleView
    }

    private var wishLifecycleView: some View {
        wishImportView
            .onChange(of: selectedPhotos) { _, photos in
                Task {
                    await importPhotos(photos)
                }
            }
            .onChange(of: cameraImageData) { _, data in
                guard let data else {
                    return
                }
                insertImage(data)
                cameraImageData = nil
            }
            .onChange(of: bodyText) { _, newText in
                handleBodyTextChange(newText)
            }
            .onChange(of: status) { _, newStatus in
                idea.status = newStatus
                idea.updated = .now
                scheduleAutosave()
            }
            .onAppear {
                migrateLegacyImageIfNeeded()
                ensureLinkAttachments(for: bodyText)
            }
            .onDisappear {
                autosaveTask?.cancel()
                saveNow()
            }
    }

    private var wishImportView: some View {
        wishPresentationView
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedPhotos,
                maxSelectionCount: 20,
                matching: .images
            )
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                importFiles(result)
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker(imageData: $cameraImageData)
                    .ignoresSafeArea()
            }
    }

    private var wishPresentationView: some View {
        wishNavigationView
            .alert("Price", isPresented: $showingPriceAlert) {
                TextField("0.00", text: $priceDraft)
                    .keyboardType(.decimalPad)

                if idea.price != nil {
                    Button("Remove price", role: .destructive) {
                        priceDraft = ""
                        idea.price = nil
                        idea.updated = .now
                    }
                }

                Button("Save") {
                    savePrice()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a price using your device’s number format.")
            }
            .sheet(item: $selectedCategoryRoute) { route in
                if let categoryID = route.categoryID {
                    CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
                } else if let legacyName = route.legacyName {
                    CategoryWishesSheet(category: legacyName)
                }
            }
    }

    private var wishNavigationView: some View {
        NavigationStack {
            wishEditorScrollView
                .background(Backdrop())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 7) {
                            Avatar(person: person, size: 28)

                            Text("\(personDisplayName)’s wish", comment: "Navigation title for a person's wish detail.")
                                .font(.headline)
                        }
                        .accessibilityElement(children: .combine)
                    }

                    ToolbarItem(
                        placement:
                            .cancellationAction
                    ) {
                        noteAddMenu
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            saveNow()
                            AwwHaptics.success()
                            dismiss()
                        }
                    }
                }
        }
    }

    private var wishEditorScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                metadataChips
                noteTextEditor

                if !categories.isEmpty {
                    categoryChips
                }

                if !categorySuggestions.isEmpty {
                    categorySuggestionBar
                }

                attachmentsCanvas
                wishTimestamps
            }
            .frame(maxWidth: AwwAppLimits.detailMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var wishTimestamps: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Added: \(idea.created.formatted(date: .abbreviated, time: .shortened))")
            Text("Edited: \(idea.updated.formatted(date: .abbreviated, time: .shortened))")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
    }

    private func handleBodyTextChange(_ newText: String) {
        let hashtagsInText = hashtagCategoryValues(in: newText)
        categories = categories.filter { category in
            hashtagsInText.contains {
                $0.localizedCaseInsensitiveCompare(category) == .orderedSame
            }
        }
        ensureLinkAttachments(for: newText)
        saveText()
        scheduleAutosave()
    }

    private var metadataChips: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(IdeaStatus.allCases) { option in
                    Button {
                        status = option.title
                    } label: {
                        if status == option.title {
                            Label(option.title, systemImage: "checkmark")
                        } else {
                            Text(option.title)
                        }
                    }
                }
            } label: {
                Label(status, systemImage: "gift.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)

            Button {
                priceDraft = idea.price.map(AwwLocale.decimalString) ?? ""
                showingPriceAlert = true
            } label: {
                Label(priceChipText, systemImage: "dollarsign")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)

            Menu {
                ForEach(WishCardPalette.allCases) { palette in
                    Button {
                        idea.cardColor = palette.id
                        idea.updated = .now
                        scheduleAutosave()
                        AwwHaptics.selection()
                    } label: {
                        if idea.cardColor == palette.id {
                            Label(palette.title, systemImage: "checkmark")
                        } else {
                            Text(palette.title)
                        }
                    }
                }
            } label: {
                Circle()
                    .fill(WishCardPalette.color(for: idea))
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle().stroke(.primary.opacity(0.12))
                    }
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
            .accessibilityLabel("Card color")

            Spacer(minLength: 0)
        }
    }

    private var priceChipText: String {
        if let price = idea.price {
            return AwwLocale.decimalString(price)
        }
        return "Price"
    }

    private var noteTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if bodyText.isEmpty {
                Text("Start typing…")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
                    .allowsHitTesting(false)
            }

            LinkAwareTextView(
                text: $bodyText,
                focusRequest: textFocusRequest,
                onFocusChange: { _ in },
                highlightedHashtags: categories,
                font: .preferredFont(forTextStyle: .body),
                minHeight: 150,
                maxHeight: 520
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(
                    categories,
                    id: \.self
                ) { category in
                    Button {
                        selectedCategoryRoute = CategorySheetRoute(legacyName: category)
                    } label: {
                        Text("#\(category)")
                            .font(
                                .subheadline
                                    .weight(
                                        .semibold
                                    )
                            )
                            .foregroundStyle(
                                .red
                            )
                            .padding(
                                .horizontal,
                                11
                            )
                            .padding(
                                .vertical,
                                7
                            )
                            .background(
                                Color.red
                                    .opacity(
                                        0.10
                                    ),
                                in:
                                    Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }


    private var categorySuggestionBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                if let hashtagQuery, !hashtagQuery.isEmpty,
                   !existingCategories.contains(where: {
                       $0.localizedCaseInsensitiveCompare(hashtagQuery) == .orderedSame
                   }) {
                    Button("Add #\(hashtagQuery)") {
                        applyCategory(hashtagQuery)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)
                }

                ForEach(categorySuggestions, id: \.self) { suggestion in
                    Button("#\(suggestion)") {
                        applyCategory(suggestion)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .controlSize(.small)
                }
            }
        }
        .scrollIndicators(.hidden)
    }



    @ViewBuilder
    private var attachmentsCanvas: some View {
        if !orderedAttachments.isEmpty {
            VStack(spacing: 12) {
                ForEach(orderedAttachments) { attachment in
                    noteAttachmentBlock(attachment)
                        .draggable(attachment.id.uuidString)
                        .dropDestination(for: String.self) { values, _ in
                            guard let raw = values.first,
                                  let sourceID = UUID(uuidString: raw) else {
                                return false
                            }
                            moveAttachment(sourceID, before: attachment.id)
                            return true
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func noteAttachmentBlock(_ attachment: IdeaAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch attachment.kind {
                case "image":
                    if let data = attachment.data {
                        AwwDataImage(
                            data: data,
                            maxPixelSize: 1400
                        )
                        .scaledToFit()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 160,
                            maxHeight: 420
                        )
                        .background(Color.primary.opacity(0.035))
                        .clipShape(.rect(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.primary.opacity(0.045))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                    Text("Image unavailable")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(.secondary)
                            }
                    }

                case "link":
                    if let url = URL(string: attachment.linkURL) {
                        VStack(alignment: .leading, spacing: 7) {
                            Link(destination: url) {
                                RichLinkPreview(url: url)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 150)
                                    .clipShape(.rect(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)

                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .lineLimit(2)
                        }
                    }

                default:
                    HStack(spacing: 14) {
                        Image(systemName: fileSymbol(for: attachment.contentType))
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 46, height: 46)
                            .background(Color.primary.opacity(0.055), in: .rect(cornerRadius: 11))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(attachment.filename)
                                .font(.headline)
                                .lineLimit(2)
                            Text(fileKindLabel(for: attachment.contentType))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(Color.primary.opacity(0.045), in: .rect(cornerRadius: 16))
                }
            }

            attachmentDeleteButton(attachment)
                .padding(7)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }

    private func attachmentDeleteButton(_ attachment: IdeaAttachment) -> some View {
        Button {
            context.delete(attachment)
            idea.updated = .now
            _ = AwwPersistence.save(context)
        } label: {
            Image(systemName: "xmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove attachment")
    }

    private var noteAddMenu: some View {
        Menu {
            if UIImagePickerController
                .isSourceTypeAvailable(
                    .camera
                ) {
                Button(
                    "Take Photo",
                    systemImage: "camera"
                ) {
                    showingCamera = true
                }
            }

            Button(
                "Choose Photo",
                systemImage:
                    "photo.on.rectangle"
            ) {
                showingPhotoPicker = true
            }

            Button(
                "Choose Files",
                systemImage: "folder"
            ) {
                showingFileImporter = true
            }

            Button(
                "Paste from Clipboard",
                systemImage:
                    "doc.on.clipboard"
            ) {
                pasteIntoNote()
            }
        } label: {
            Image(systemName: "plus")
                .font(
                    .headline.weight(
                        .semibold
                    )
                )
        }
        .accessibilityLabel(
            "Add content"
        )
    }


    private func applyCategory(_ newCategory: String) {
        let cleaned = newCategory
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
        guard !cleaned.isEmpty else { return }

        let textWithoutCurrentHashtag =
            removingCurrentHashtag(in: bodyText)

        let alreadyExists =
            hashtagCategoryValues(in: textWithoutCurrentHashtag)
                .contains {
                    $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame
                }

        if alreadyExists {
            bodyText = textWithoutCurrentHashtag
        } else {
            bodyText = replacingCurrentHashtag(
                in: bodyText,
                with: cleaned
            )
        }

        categories = uniqueCategoryValues(categories + [cleaned])
        try? AwwCategoryStore.assign(
            names: categories,
            to: idea,
            context: context
        )
        idea.updated = .now
        textFocusRequest &+= 1
        AwwHaptics.light()
        scheduleAutosave()
    }

    private func saveText() {
        let newTitle = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newCategories = categories
        let newCategoryValue = encodedCategoryValues(newCategories)
        let categoryChanged = idea.category != newCategoryValue

        let didChange =
            idea.title != newTitle
            || !idea.note.isEmpty
            || categoryChanged

        idea.ownerUserID = idea.ownerUserID ?? AwwIdentityCache.userID
        idea.personIDs = idea.personIDs?.isEmpty == false
            ? idea.personIDs
            : [person.id]
        idea.title = newTitle
        idea.note = ""
        categories = newCategories

        if categoryChanged {
            try? AwwCategoryStore.assign(
                names: newCategories,
                to: idea,
                context: context
            )
        }

        if didChange {
            idea.updated = .now
        }
    }

    private func savePrice() {
        let newPrice = AwwLocale.parseDecimal(priceDraft)

        if idea.price != newPrice {
            idea.price = newPrice
            idea.updated = .now
            scheduleAutosave()
        }
    }

    private func scheduleAutosave() {
        autosaveTask?.cancel()
        autosaveTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            _ = AwwPersistence.save(context)
        }
    }

    private func saveNow() {
        saveText()
        savePrice()

        if idea.status != status {
            idea.status = status
            idea.updated = .now
        }

        _ = AwwPersistence.save(context)
    }

    private func migrateLegacyImageIfNeeded() {
        guard let legacy = idea.image else { return }
        let alreadySaved = idea.attachments.contains {
            $0.kind == "image" && $0.data == legacy
        }

        if !alreadySaved {
            let attachment = IdeaAttachment(
                filename: "Photo",
                contentType: UTType.image.identifier,
                kind: "image",
                data: legacy,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }

        idea.image = nil
        _ = AwwPersistence.save(context)
    }

    private func ensureLinkAttachments(for text: String) {
        for url in detectedHTTPURLs(in: text) where isHTTPURL(url) {
            let exists = idea.attachments.contains {
                $0.kind == "link" && $0.linkURL == url.absoluteString
            }
            guard !exists else { continue }

            let attachment = IdeaAttachment(
                filename: url.host() ?? url.absoluteString,
                contentType: UTType.url.identifier,
                kind: "link",
                linkURL: url.absoluteString,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }
    }

    private func nextAttachmentDate() -> Date {
        let latest = idea.attachments.map(\.created).max() ?? .now
        return latest.addingTimeInterval(0.01)
    }

    private func insertImage(_ data: Data) {
        let attachment = IdeaAttachment(
            filename: "Photo",
            contentType: UTType.image.identifier,
            kind: "image",
            data: data,
            idea: idea
        )
        attachment.created = nextAttachmentDate()
        context.insert(attachment)
        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func importPhotos(_ photos: [PhotosPickerItem]) async {
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            await MainActor.run { insertImage(data) }
        }
        await MainActor.run { selectedPhotos.removeAll() }
    }

    private func importFiles(_ result: Result<[URL], any Error>) {
        guard case .success(let urls) = result else { return }

        for url in urls {
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else { continue }

            let type = UTType(filenameExtension: url.pathExtension)?.identifier
                ?? UTType.data.identifier
            let attachment = IdeaAttachment(
                filename: url.lastPathComponent,
                contentType: type,
                kind: "file",
                data: data,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }

        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func pasteIntoNote() {
        let pasteboard = UIPasteboard.general

        if let url = pasteboard.url, isHTTPURL(url) {
            appendURLToText(url)
            return
        }

        if let string = pasteboard.string {
            let urls = detectedHTTPURLs(in: string)
            if !urls.isEmpty {
                bodyText += bodyText.isEmpty ? string : "\n\(string)"
                ensureLinkAttachments(for: string)
                textFocusRequest &+= 1
                return
            }
        }

        if let image = pasteboard.image,
           let data = image.jpegData(compressionQuality: 0.9) {
            insertImage(data)
        }
    }

    private func appendURLToText(_ url: URL) {
        guard isHTTPURL(url) else { return }
        if !bodyText.contains(url.absoluteString) {
            bodyText += bodyText.isEmpty ? url.absoluteString : "\n\(url.absoluteString)"
        }
        ensureLinkAttachments(for: url.absoluteString)
        textFocusRequest &+= 1
    }

    private func moveAttachment(_ sourceID: UUID, before targetID: UUID) {
        guard sourceID != targetID else { return }
        var items = orderedAttachments
        guard let from = items.firstIndex(where: { $0.id == sourceID }),
              let to = items.firstIndex(where: { $0.id == targetID }) else {
            return
        }

        let item = items.remove(at: from)
        let insertion = from < to ? max(0, to - 1) : to
        items.insert(item, at: insertion)

        let base = items.map(\.created).min() ?? .now
        for (index, attachment) in items.enumerated() {
            attachment.created = base.addingTimeInterval(Double(index) * 0.01)
        }
        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func fileSymbol(for contentType: String) -> String {
        guard let type = UTType(contentType) else { return "doc.fill" }
        if type.conforms(to: .pdf) { return "doc.richtext.fill" }
        if type.conforms(to: .image) { return "photo.fill" }
        if type.conforms(to: .audio) { return "waveform" }
        if type.conforms(to: .movie) { return "play.rectangle.fill" }
        if type.conforms(to: .archive) { return "archivebox.fill" }
        return "doc.fill"
    }

    private func fileKindLabel(for contentType: String) -> String {
        guard let type = UTType(contentType) else { return "File" }
        return type.localizedDescription ?? "File"
    }
}


private struct RecentWishGroup: Identifiable {
    let id: UUID
    let idea: Idea
    var people: [Person]

    init(idea: Idea, people: [Person]) {
        id = idea.id
        self.idea = idea
        self.people = people
    }
}

private func recentWishContentKey(_ idea: Idea) -> String {
    [idea.title, idea.note, idea.category, idea.status]
        .map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        }
        .joined(separator: "|")
}

struct WishCategorySummary: Identifiable {
    let id: UUID
    let name: String
    let count: Int
}

func wishCategorySummaries(
    from ideas: [Idea],
    categories: [Category]
) -> [WishCategorySummary] {
    let ownerID = AwwIdentityCache.userID
    let active = categories.filter {
        $0.deletedAt == nil
        && (ownerID == nil || $0.ownerUserID == ownerID)
    }

    let ideasByCategoryID = ideas.reduce(into: [UUID: Int]()) { counts, idea in
        guard idea.deletedAt == nil else { return }

        if let ids = idea.categoryIDs, !ids.isEmpty {
            for id in ids {
                counts[id, default: 0] += 1
            }
        } else {
            // One-time migration fallback for a legacy row that has not yet been
            // attached to Category UUIDs.
            for name in categoryValues(from: idea.category) {
                if let match = active.first(where: {
                    $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
                }) {
                    counts[match.id, default: 0] += 1
                }
            }
        }
    }

    return active.map { category in
        WishCategorySummary(
            id: category.id,
            name: category.name,
            count: ideasByCategoryID[category.id, default: 0]
        )
    }
    .sorted { first, second in
        if first.count == second.count {
            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
        return first.count > second.count
    }
}

private struct RecentWishBubbleCard: View {
    let group: RecentWishGroup
    let action: () -> Void

    var body: some View {
        GiftMessageBubble(
            idea: group.idea,
            layout: .grid,
            footerPeople: group.people
        )
        .contentShape(.rect(cornerRadius: 21))
        .onTapGesture(perform: action)
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                action()
            }

            Menu("Move to status") {
                ForEach(IdeaStatus.allCases) { status in
                    Button(status.title) {
                        group.idea.status = status.title
                        group.idea.updated = .now
                        AwwHaptics.selection()
                    }
                }
            }

            Button("Copy app link", systemImage: "link") {
                AwwDeepLink.copy(AwwDeepLink.wish(group.idea.id))
            }

            Button("Copy text", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = textToCopy
                AwwHaptics.success()
            }
        }
        .accessibilityLabel("Recently added wish")
        .accessibilityHint("Opens the saved wish. Long press for options.")
    }

    private var textToCopy: String {
        if !group.idea.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return group.idea.note
        }

        return displayTextWithoutCategoryHashtags(group.idea.title)
    }
}

struct CategoriesView: View {
    @Environment(\.modelContext)
    private var context

    @Query(sort: \Idea.updated, order: .reverse)
    private var ideas: [Idea]

    @Query(sort: \Category.createdAt)
    private var categoryRecords: [Category]

    @State private var selectedCategoryRoute: CategorySheetRoute?
    @State private var summariesCache: [WishCategorySummary] = []
    @State private var categoryToRenameID: UUID?
    @State private var renameText = ""
    @State private var categoryToDeleteID: UUID?
    @State private var categoryError = ""

    private var summaries: [WishCategorySummary] {
        summariesCache
    }

    var body: some View {
        Group {
            if summaries.isEmpty {
                ContentUnavailableView(
                    "No categories yet",
                    systemImage: "number",
                    description: Text("Add #categories to wishes and they’ll appear here.")
                )
            } else {
                List {
                    ForEach(summaries) { summary in
                        categoryRow(summary)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    categoryToDeleteID = summary.id
                                    AwwHaptics.warning()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    beginRename(summary)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Backdrop())
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedCategoryRoute) { route in
            if let categoryID = route.categoryID {
                CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
            } else if let legacyName = route.legacyName {
                CategoryWishesSheet(category: legacyName)
            }
        }
        .alert(
            "Rename category",
            isPresented: Binding(
                get: { categoryToRenameID != nil },
                set: { if !$0 { categoryToRenameID = nil } }
            )
        ) {
            TextField("Category name", text: $renameText)

            Button("Cancel", role: .cancel) {
                categoryToRenameID = nil
            }

            Button("Rename") {
                renameSelectedCategory()
            }
            .disabled(
                renameText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        } message: {
            Text("The category keeps the same ID. Wishes do not move or get recreated.")
        }
        .confirmationDialog(
            "Delete category?",
            isPresented: Binding(
                get: { categoryToDeleteID != nil },
                set: { if !$0 { categoryToDeleteID = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete category", role: .destructive) {
                deleteSelectedCategory()
            }

            Button("Cancel", role: .cancel) {
                categoryToDeleteID = nil
            }
        } message: {
            Text("Only the category relationship is removed. Wishes, notes, photos, and links stay exactly where they are.")
        }
        .alert(
            "Couldn’t update category",
            isPresented: Binding(
                get: { !categoryError.isEmpty },
                set: { if !$0 { categoryError = "" } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(categoryError)
        }
        .onAppear(perform: refreshSummaries)
        .onReceive(
            NotificationCenter.default.publisher(for: .awwDataDidChange)
        ) { _ in
            refreshSummaries()
        }
        .onChange(of: categoryRecords.count) { _, _ in
            refreshSummaries()
        }
    }

    private func categoryRow(_ summary: WishCategorySummary) -> some View {
        Button {
            selectedCategoryRoute = CategorySheetRoute(categoryID: summary.id, name: summary.name)
            AwwHaptics.selection()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "number")
                    .foregroundStyle(.red)

                Text(summary.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(summary.count, format: .number)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                beginRename(summary)
            }

            Button("Copy app link", systemImage: "link") {
                AwwDeepLink.copy(AwwDeepLink.category(summary.id))
            }

            Button("Delete category", systemImage: "trash", role: .destructive) {
                categoryToDeleteID = summary.id
                AwwHaptics.warning()
            }
        }
    }

    private func beginRename(_ summary: WishCategorySummary) {
        categoryToRenameID = summary.id
        renameText = summary.name
        AwwHaptics.selection()
    }

    private func renameSelectedCategory() {
        guard let categoryID = categoryToRenameID else { return }
        let newName = renameText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#|"))
        guard !newName.isEmpty else { return }

        do {
            try AwwCategoryStore.rename(
                categoryID: categoryID,
                to: newName,
                context: context
            )
            try context.save()
            categoryToRenameID = nil
            renameText = ""
            AwwHaptics.success()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            refreshSummaries()
        } catch {
            categoryError = error.localizedDescription
        }
    }

    private func deleteSelectedCategory() {
        guard let categoryID = categoryToDeleteID else { return }

        do {
            try AwwCategoryStore.delete(
                categoryID: categoryID,
                context: context
            )
            try context.save()
            categoryToDeleteID = nil
            AwwHaptics.deleted()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            refreshSummaries()
        } catch {
            categoryError = error.localizedDescription
        }
    }

    private func refreshSummaries() {
        summariesCache = wishCategorySummaries(
            from: ideas,
            categories: categoryRecords
        )
    }
}

struct CategoryWishesSheet: View {
    private let categoryID: UUID?
    private let fallbackCategoryName: String?
    private let legacyCategoryName: String?

    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \Idea.updated, order: .reverse)
    private var ideas: [Idea]

    @Query(sort: \Category.updatedAt, order: .reverse)
    private var categoryRecords: [Category]

    @State private var editingIdea: Idea?
    @State private var matchingIdeasCache: [Idea] = []

    init(categoryID: UUID, fallbackName: String? = nil) {
        self.categoryID = categoryID
        self.fallbackCategoryName = fallbackName
        self.legacyCategoryName = nil
    }

    // Compatibility initializer for older navigation call sites. The sheet resolves
    // the string to a stable Category UUID as soon as the migrated row exists.
    init(category: String) {
        if let id = UUID(uuidString: category) {
            self.categoryID = id
            self.fallbackCategoryName = nil
            self.legacyCategoryName = nil
        } else {
            self.categoryID = nil
            self.fallbackCategoryName = category
            self.legacyCategoryName = category
        }
    }

    private var resolvedCategory: Category? {
        if let categoryID {
            return categoryRecords.first {
                $0.id == categoryID && $0.deletedAt == nil
            }
        }

        guard let legacyCategoryName else { return nil }
        return categoryRecords.first {
            $0.deletedAt == nil
            && $0.name.localizedCaseInsensitiveCompare(legacyCategoryName) == .orderedSame
        }
    }

    private var displayName: String {
        resolvedCategory?.name
            ?? fallbackCategoryName
            ?? legacyCategoryName
            ?? "Category"
    }

    private var matchingIdeas: [Idea] {
        matchingIdeasCache
    }

    var body: some View {
        NavigationStack {
            categoryList
                .background(Backdrop())
                .navigationTitle("#\(displayName)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .sheet(item: $editingIdea) { idea in
                    categoryEditor(for: idea)
                }
                .onAppear(perform: refreshMatchingIdeas)
                .onReceive(
                    NotificationCenter.default.publisher(for: .awwDataDidChange)
                ) { _ in
                    refreshMatchingIdeas()
                }
                .onChange(of: categoryRecords.count) { _, _ in
                    refreshMatchingIdeas()
                }
        }
    }

    private var categoryList: some View {
        ScrollView {
            if matchingIdeas.isEmpty {
                ContentUnavailableView(
                    "Nothing in #\(displayName) yet",
                    systemImage: "number",
                    description: Text("Add #\(displayName) to a wish and it will appear here.")
                )
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(matchingIdeas) { idea in
                        categoryWishRow(idea)
                    }
                }
                .padding(20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func refreshMatchingIdeas() {
        if let id = resolvedCategory?.id {
            matchingIdeasCache = ideas.filter { idea in
                guard idea.deletedAt == nil else { return false }

                if idea.categoryIDs?.contains(id) == true {
                    return true
                }

                // Legacy local rows can still have only the old category string
                // until their ID relationships are migrated. Never show a blank
                // category sheet just because that migration has not run yet.
                if idea.categoryIDs?.isEmpty != false {
                    return categoryValue(idea.category, contains: displayName)
                }

                return false
            }
        } else {
            matchingIdeasCache = ideas.filter {
                $0.deletedAt == nil
                && categoryValue($0.category, contains: displayName)
            }
        }
    }

    @ViewBuilder
    private func categoryWishRow(_ idea: Idea) -> some View {
        if let person = idea.person {
            Button {
                editingIdea = idea
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(person.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    GiftMessageBubble(idea: idea)
                }
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func categoryEditor(for idea: Idea) -> some View {
        if let person = idea.person {
            WishDetail(person: person, idea: idea)
        }
    }
}


// MARK: - Settings

struct Settings: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var context

    @Query
    private var categories: [Category]

    @Query
    private var syncRecords: [AwwSyncRecord]

    @Query
    private var people: [Person]

    @Query
    private var ideas: [Idea]

    @Query
    private var occasions: [Occasion]

    @State private var erase = false
    @State private var restartOnboarding = false
    @State private var reminderStatus = ""
    @State private var settingsError = ""

    @AppStorage("onboarded")
    private var onboarded = true

    @AppStorage(NotificationScheduler.generalReminderEnabledKey)
    private var generalReminderEnabled = false

    @AppStorage("generalIdeaReminderWasExplicitlyChanged")
    private var reminderWasExplicitlyChanged = false

    @State private var suppressNextReminderPreferenceChange = false

    @AppStorage("generalIdeaReminderFrequency")
    private var reminderFrequency = GeneralReminderFrequency.daily.rawValue

    @AppStorage("generalIdeaReminderTime")
    private var reminderTimeInterval = Calendar.current.date(
        bySettingHour: 19,
        minute: 0,
        second: 0,
        of: .now
    )?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate

    @AppStorage("generalIdeaReminderWeekday")
    private var reminderWeekday = Calendar.current.component(.weekday, from: .now)

    private var reminderTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSinceReferenceDate: reminderTimeInterval) },
            set: { reminderTimeInterval = $0.timeIntervalSinceReferenceDate }
        )
    }

    private var frequency: GeneralReminderFrequency {
        GeneralReminderFrequency(rawValue: reminderFrequency) ?? .daily
    }

    var body: some View {
        NavigationStack {
            Form {
                reminderSection

                Section("Onboarding") {
                    Button("Restart onboarding", systemImage: "arrow.clockwise") {
                        restartOnboarding = true
                    }

                    Text("Replay the welcome setup without removing your saved data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Your library") {
                    Button("Delete all data", role: .destructive) {
                        erase = true
                    }

                    Text("You can delete an individual person’s list by long pressing their avatar on Home.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await applyNotificationReminderDefaultIfNeeded()
                await synchronizeGeneralReminders()
            }
            .onChange(of: generalReminderEnabled) { _, _ in
                if suppressNextReminderPreferenceChange {
                    suppressNextReminderPreferenceChange = false
                } else {
                    reminderWasExplicitlyChanged = true
                }
                Task {
                    await synchronizeGeneralReminders()
                }
            }
            .onChange(of: reminderFrequency) { _, _ in
                Task {
                    await synchronizeGeneralReminders()
                }
            }
            .onChange(of: reminderTimeInterval) { _, _ in
                Task {
                    await synchronizeGeneralReminders()
                }
            }
            .onChange(of: reminderWeekday) { _, _ in
                Task {
                    await synchronizeGeneralReminders()
                }
            }
            .alert("Restart onboarding?", isPresented: $restartOnboarding) {
                Button("Cancel", role: .cancel) {}

                Button("Restart onboarding") {
                    onboarded = false
                }
            } message: {
                Text("Your people, wishes, categories, and profile will stay in place.")
            }
            .alert("Delete everything?", isPresented: $erase) {
                Button("Cancel", role: .cancel) {}

                Button("Delete all local data", role: .destructive) {
                    deleteEverything()
                }
            } message: {
                Text("This removes every person, wish, category, moment, reminder, and attachment from this iPhone.")
            }
            .alert(
                "Couldn’t reset local data",
                isPresented: Binding(
                    get: { !settingsError.isEmpty },
                    set: { if !$0 { settingsError = "" } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(settingsError)
            }
        }
    }

    private var reminderSection: some View {
        Section("Idea reminders") {
            Toggle("Remind me to save ideas", isOn: $generalReminderEnabled)

            if generalReminderEnabled {
                Picker("Repeat", selection: $reminderFrequency) {
                    ForEach(GeneralReminderFrequency.allCases) { frequency in
                        Text(frequency.title)
                            .tag(frequency.rawValue)
                    }
                }

                if frequency == .weekly {
                    Picker("Day", selection: $reminderWeekday) {
                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, weekday in
                            Text(weekday)
                                .tag(index + 1)
                        }
                    }
                }

                DatePicker(
                    "Time",
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                )
            }

            Button("Send an example reminder", systemImage: "bell.badge") {
                Task {
                    let status = await NotificationScheduler.authorizationStatus()
                    let isAuthorized = status == .authorized || status == .provisional
                        ? true
                        : await NotificationScheduler.requestAuthorization()

                    let didSchedule = isAuthorized
                        ? await NotificationScheduler.sendExampleReminder()
                        : false

                    reminderStatus = didSchedule
                        ? "Example reminder will arrive in a few seconds."
                        : "Allow notifications in iPhone Settings to send an example."
                }
            }

            if !reminderStatus.isEmpty {
                Text(reminderStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text("Choose a time that fits your routine. You can also turn reminders off directly from any idea reminder.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func applyNotificationReminderDefaultIfNeeded() async {
        guard !reminderWasExplicitlyChanged else { return }

        let status = await NotificationScheduler.authorizationStatus()
        guard status == .authorized || status == .provisional else { return }

        guard !generalReminderEnabled else { return }
        suppressNextReminderPreferenceChange = true
        generalReminderEnabled = true
    }

    private func synchronizeGeneralReminders() async {
        await NotificationScheduler.synchronizeGeneralReminders(
            isEnabled: generalReminderEnabled,
            frequency: frequency,
            time: reminderTime.wrappedValue,
            weekday: reminderWeekday
        )
    }

    private func deleteEverything() {
        do {
            ideas.forEach(context.delete)
            people.forEach(context.delete)
            occasions.forEach(context.delete)
            categories.forEach(context.delete)
            syncRecords.forEach(context.delete)

            let account = try AwwAccountManager.ensureLocalAccount(context: context)
            let owner = Person(
                account.displayName.nonEmptyValue ?? "Me",
                relation: "Me",
                accent: "coral",
                emoji: "❤️",
                isOwner: true,
                ownerUserID: account.id
            )
            context.insert(owner)

            for name in awwDefaultCategoryNames {
                context.insert(
                    Category(
                        ownerUserID: account.id,
                        name: name,
                        isDefault: true,
                        defaultKey: name.lowercased()
                    )
                )
            }

            try context.save()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
        } catch {
            settingsError = "Couldn’t reset local data: \(error.localizedDescription)"
        }
    }
}
