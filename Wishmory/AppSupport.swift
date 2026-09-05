Warning: truncated output (original token count: 56166)
Total output lines: 6908

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


enum AwwRefreshMessage {
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

struct AwwRefreshControlBranding: UIViewRepresentable {
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


