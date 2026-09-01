import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case NotificationScheduler.addIdeaActionIdentifier,
             UNNotificationDefaultActionIdentifier:
            UserDefaults.standard.set(true, forKey: NotificationScheduler.openIdeaComposerKey)

        case NotificationScheduler.disableReminderActionIdentifier:
            UserDefaults.standard.set(false, forKey: NotificationScheduler.generalReminderEnabledKey)
            NotificationScheduler.removeGeneralReminders()

        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .badge, .sound]
    }
}

enum NotificationScheduler {
    static let openIdeaComposerKey = "openIdeaComposer"
    static let generalReminderEnabledKey = "generalIdeaReminderEnabled"

    static let addIdeaActionIdentifier = "add-idea"
    static let disableReminderActionIdentifier = "disable-idea-reminders"

    private static let momentNotificationPrefix = "moment-reminder-"
    private static let generalReminderIdentifier = "general-idea-reminder"
    private static let generalReminderCategoryIdentifier = "general-idea-reminder-category"

    static func configureCategories() {
        let addIdea = UNNotificationAction(
            identifier: addIdeaActionIdentifier,
            title: "Add an idea",
            options: [.foreground]
        )
        let disable = UNNotificationAction(
            identifier: disableReminderActionIdentifier,
            title: "Turn off reminders",
            options: [.destructive]
        )
        let category = UNNotificationCategory(
            identifier: generalReminderCategoryIdentifier,
            actions: [addIdea, disable],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            return false
        }
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    static func synchronizeGeneralReminders(
        isEnabled: Bool,
        frequency: GeneralReminderFrequency,
        time: Date,
        weekday: Int
    ) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [generalReminderIdentifier])

        guard isEnabled else {
            return
        }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        var triggerComponents = DateComponents()
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute

        if frequency == .weekly {
            triggerComponents.weekday = weekday
        }

        let request = UNNotificationRequest(
            identifier: generalReminderIdentifier,
            content: generalReminderContent(),
            trigger: UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        )

        try? await center.add(request)
    }

    static func sendExampleReminder() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return false
        }

        let request = UNNotificationRequest(
            identifier: "general-idea-reminder-example",
            content: generalReminderContent(),
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            return false
        }
    }

    static func removeGeneralReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [generalReminderIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [generalReminderIdentifier])
    }

    static func synchronize(person: Person, occasions: [Occasion]) async {
        let center = UNUserNotificationCenter.current()
        let identifiers = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(momentNotificationPrefix + person.id.uuidString) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        var reminders: [(id: String, title: String, date: Date, offsets: [Int])] = []
        if person.birthdayReminderEnabled, let birthday = person.birthday {
            reminders.append(("birthday", "Birthday", birthday, person.birthdayReminderOffsets))
        }

        reminders += occasions.map {
            ($0.id.uuidString, $0.title, $0.date, $0.reminderOffsets)
        }

        for reminder in reminders {
            for offset in reminder.offsets {
                await schedule(
                    identifier: "\(momentNotificationPrefix)\(person.id.uuidString)-\(reminder.id)-\(offset)",
                    personName: person.name,
                    momentTitle: reminder.title,
                    date: reminder.date,
                    daysBefore: offset,
                    center: center
                )
            }
        }
    }

    private static func generalReminderContent() -> UNMutableNotificationContent {
        let messages = [
            (
                "Ohhh, they’d love that. Save it now.",
                "Gift-genius later."
            ),
            (
                "Remember that perfect gift idea?",
                "Exactly. You added it on time."
            ),
            (
                "Your brain said “I’ll remember.” Cute.",
                "Save the wish before it vanishes."
            ),
            (
                "Future you will thank you.",
                "Keep wishes, hints, and gift ideas somewhere smarter."
            ),
            (
                "Good gifts start with tiny clues.",
                "Catch them before they disappear."
            )
        ]

        let message = messages.randomElement() ?? messages[0]
        let content = UNMutableNotificationContent()
        content.title = message.0
        content.body = message.1
        content.sound = .default
        content.categoryIdentifier = generalReminderCategoryIdentifier
        content.threadIdentifier = "idea-reminders"
        return content
    }

    private static func schedule(
        identifier: String,
        personName: String,
        momentTitle: String,
        date: Date,
        daysBefore: Int,
        center: UNUserNotificationCenter
    ) async {
        guard let reminderDate = Calendar.current.date(
            byAdding: .day,
            value: -daysBefore,
            to: date
        ) else {
            return
        }

        var components = Calendar.current.dateComponents([.month, .day], from: reminderDate)
        components.hour = 9
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = daysBefore == 0 ? "\(personName)’s \(momentTitle) is today" : "\(personName)’s \(momentTitle) is coming up"
        content.body = daysBefore == 0 ? "Take a moment to celebrate." : "It’s in \(daysBefore) days. Their gift ideas are ready when you are."
        content.sound = .default
        content.threadIdentifier = "moment-\(personName)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        try? await center.add(request)
    }
}

enum GeneralReminderFrequency: String, CaseIterable, Identifiable {
    case daily
    case weekly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily:
            "Daily"
        case .weekly:
            "Weekly"
        }
    }
}
