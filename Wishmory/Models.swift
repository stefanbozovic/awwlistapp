// AwwList local-first SwiftData schema, V3 foundation
//
// Migration strategy:
// - Existing model/property names are preserved.
// - New ownership/relationship fields are additive and optional where legacy rows may not have values.
// - AwwAccountManager performs an idempotent data migration after a local userID exists.
// - Legacy category strings remain only as a denormalized display/search cache. Category identity is UUID-based.

import Foundation
import SwiftData

let awwDefaultCategoryNames = ["Beauty", "Books", "Fashion", "Home", "Tech"]

enum AwwIdentityCache {
    static let userIDKey = "AwwList.localUserID.v1"

    static var userID: UUID? {
        guard let raw = UserDefaults.standard.string(forKey: userIDKey) else {
            return nil
        }
        return UUID(uuidString: raw)
    }

    @discardableResult
    static func ensureLocalUserID() -> UUID {
        if let existing = userID {
            return existing
        }

        let newID = UUID()
        UserDefaults.standard.set(newID.uuidString, forKey: userIDKey)
        return newID
    }

    static func useExistingLocalUserID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: userIDKey)
    }

}

@Model
final class AwwUser {
    var id: UUID = UUID()
    var displayName: String = ""
    var createdAt: Date = Foundation.Date.now
    var updatedAt: Date = Foundation.Date.now
    var lastSyncAt: Date?

    init(
        id: UUID = UUID(),
        displayName: String = ""
    ) {
        self.id = id
        self.displayName = displayName
    }
}

@Model
final class Category {
    var id: UUID = UUID()
    var ownerUserID: UUID?
    var name: String
    var isDefault: Bool = false
    // Stable origin key for the five built-in categories. Renaming changes `name`,
    // never this identity key.
    var defaultKey: String = ""
    var createdAt: Date = Foundation.Date.now
    var updatedAt: Date = Foundation.Date.now
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        ownerUserID: UUID? = AwwIdentityCache.userID,
        name: String,
        isDefault: Bool = false,
        defaultKey: String = ""
    ) {
        self.id = id
        self.ownerUserID = ownerUserID
        self.name = name
        self.isDefault = isDefault
        self.defaultKey = defaultKey
    }
}

@Model
final class Person {
    var id: UUID = UUID()
    var ownerUserID: UUID?

    var name: String
    var relation: String
    var birthday: Date?
    var notes: String
    var accent: String

    var emoji: String = "✨"
    var profileImage: Data?

    var birthdayReminderEnabled: Bool = false
    var birthdayReminderOffsets: [Int] = [5, 3, 0]
    var wishlistReminderEnabled: Bool = false

    var isOwner: Bool = false
    var deletedAt: Date?

    var created: Date = Foundation.Date.now
    var updated: Date = Foundation.Date.now

    @Relationship(
        deleteRule: .cascade,
        inverse: \Idea.person
    )
    var ideas: [Idea] = []

    init(
        _ name: String,
        relation: String = "Friend",
        birthday: Date? = nil,
        notes: String = "",
        accent: String = "coral",
        emoji: String = "✨",
        profileImage: Data? = nil,
        birthdayReminderEnabled: Bool = false,
        birthdayReminderOffsets: [Int] = [5, 3, 0],
        wishlistReminderEnabled: Bool = false,
        isOwner: Bool = false,
        ownerUserID: UUID? = AwwIdentityCache.userID
    ) {
        self.ownerUserID = ownerUserID
        self.name = name
        self.relation = relation
        self.birthday = birthday
        self.notes = notes
        self.accent = accent
        self.emoji = emoji
        self.profileImage = profileImage
        self.birthdayReminderEnabled = birthdayReminderEnabled
        self.birthdayReminderOffsets = birthdayReminderOffsets
        self.wishlistReminderEnabled = wishlistReminderEnabled
        self.isOwner = isOwner
    }

    var countdown: String {
        guard let birthday else {
            return "No occasion soon"
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let target = calendar.startOfDay(for: birthday)
        let days = calendar.dateComponents([.day], from: today, to: target).day ?? 0

        if days > 0 {
            return "Birthday in \(days) days"
        }

        return "A special day today"
    }
}

@Model
final class Idea {
    var id: UUID = UUID()
    var ownerUserID: UUID?

    var title: String
    var note: String
    var price: Double?

    // Legacy display/search cache only. Category identity lives in categoryIDs.
    var category: String
    var categoryIDs: [UUID]?

    // ID-based recipients are authoritative for sync/sharing. `person` remains the
    // current single-recipient SwiftData relationship used by existing UI.
    var personIDs: [UUID]?

    var status: String

    // Kept for compatibility with older local data.
    var isWish: Bool

    // Legacy thumbnail retained so existing locally saved wishes continue to display.
    var image: Data?

    // Empty values let existing wishes receive a stable palette color derived from their ID.
    // New or edited wishes store the selected palette identifier here.
    var cardColor: String = ""

    @Relationship(deleteRule: .cascade, inverse: \IdeaAttachment.idea)
    var attachments: [IdeaAttachment] = []

    var created: Date = Foundation.Date.now
    var updated: Date = Foundation.Date.now
    var deletedAt: Date?

    var person: Person?

    init(
        _ title: String,
        note: String = "",
        price: Double? = nil,
        category: String = "",
        categoryIDs: [UUID]? = nil,
        status: String = "Maybe",
        wish: Bool = false,
        person: Person? = nil,
        personIDs: [UUID]? = nil,
        cardColor: String = "",
        ownerUserID: UUID? = AwwIdentityCache.userID
    ) {
        self.ownerUserID = ownerUserID
        self.title = title
        self.note = note
        self.price = price
        self.category = category
        self.categoryIDs = categoryIDs
        self.status = status
        self.isWish = wish
        self.person = person
        self.personIDs = personIDs ?? person.map { [$0.id] }
        self.cardColor = cardColor
    }
}

@Model
final class IdeaAttachment {
    var id: UUID = UUID()
    var ownerUserID: UUID?
    var filename: String
    var contentType: String
    var kind: String
    var linkURL: String
    var data: Data?
    var created: Date = Foundation.Date.now
    var updated: Date = Foundation.Date.now
    var deletedAt: Date?

    var idea: Idea?

    init(
        filename: String,
        contentType: String,
        kind: String,
        linkURL: String = "",
        data: Data? = nil,
        idea: Idea? = nil,
        ownerUserID: UUID? = nil
    ) {
        self.ownerUserID = ownerUserID ?? idea?.ownerUserID ?? AwwIdentityCache.userID
        self.filename = filename
        self.contentType = contentType
        self.kind = kind
        self.linkURL = linkURL
        self.data = data
        self.idea = idea
    }
}

@Model
final class Occasion {
    var id: UUID = UUID()
    var ownerUserID: UUID?

    var title: String
    var date: Date
    var budget: Double?
    var note: String
    var reminderOffsets: [Int]

    // Already ID-based and intentionally independent of a person's display name.
    var participantIDs: [UUID]

    var created: Date = Foundation.Date.now
    var updated: Date = Foundation.Date.now
    var deletedAt: Date?

    init(
        title: String,
        date: Date,
        budget: Double? = nil,
        note: String = "",
        reminderOffsets: [Int] = [5, 3, 0],
        participantIDs: [UUID] = [],
        ownerUserID: UUID? = AwwIdentityCache.userID
    ) {
        self.ownerUserID = ownerUserID
        self.title = title
        self.date = date
        self.budget = budget
        self.note = note
        self.reminderOffsets = reminderOffsets
        self.participantIDs = participantIDs
    }
}


@Model
final class AwwReminder {
    var id: UUID = UUID()
    var ownerUserID: UUID?

    // Examples: "person", "wish", "moment". The target is always identified by UUID.
    var targetType: String
    var targetID: UUID
    var fireDate: Date
    var isEnabled: Bool

    var createdAt: Date = Foundation.Date.now
    var updatedAt: Date = Foundation.Date.now
    var deletedAt: Date?

    init(
        ownerUserID: UUID? = AwwIdentityCache.userID,
        targetType: String,
        targetID: UUID,
        fireDate: Date,
        isEnabled: Bool = true
    ) {
        self.ownerUserID = ownerUserID
        self.targetType = targetType
        self.targetID = targetID
        self.fireDate = fireDate
        self.isEnabled = isEnabled
    }
}

@Model
final class AwwShareGrant {
    var id: UUID = UUID()
    var ownerUserID: UUID?

    // Sharing UI is intentionally not implemented yet. These fields let the backend
    // grant access to an object without changing that object's ownership model later.
    var resourceType: String
    var resourceID: UUID
    var granteeUserID: UUID?
    var accessLevel: String
    var shareTokenHash: String

    var createdAt: Date = Foundation.Date.now
    var updatedAt: Date = Foundation.Date.now
    var revokedAt: Date?

    init(
        ownerUserID: UUID? = AwwIdentityCache.userID,
        resourceType: String,
        resourceID: UUID,
        granteeUserID: UUID? = nil,
        accessLevel: String = "read",
        shareTokenHash: String = ""
    ) {
        self.ownerUserID = ownerUserID
        self.resourceType = resourceType
        self.resourceID = resourceID
        self.granteeUserID = granteeUserID
        self.accessLevel = accessLevel
        self.shareTokenHash = shareTokenHash
    }
}

@Model
final class AwwSyncRecord {
    var id: UUID = UUID()
    var ownerUserID: UUID
    var entityType: String
    var entityID: UUID
    var operation: String
    var createdAt: Date = Foundation.Date.now
    var attemptCount: Int = 0
    var lastError: String = ""

    init(
        ownerUserID: UUID,
        entityType: String,
        entityID: UUID,
        operation: String = "upsert"
    ) {
        self.ownerUserID = ownerUserID
        self.entityType = entityType
        self.entityID = entityID
        self.operation = operation
    }
}
