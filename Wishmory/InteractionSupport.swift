import SwiftUI
import Foundation
import UIKit
import UniformTypeIdentifiers

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

struct AwwFloatingKeyboardModifier: ViewModifier {
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



struct AwwUndoCard: View {
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


