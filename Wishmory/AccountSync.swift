import Foundation
import SwiftData

// MARK: - Account + legacy-data migration

@MainActor
enum AwwAccountManager {
    @discardableResult
    static func ensureLocalAccount(context: ModelContext) throws -> AwwUser {
        let cachedID = AwwIdentityCache.ensureLocalUserID()
        let users = try context.fetch(FetchDescriptor<AwwUser>())

        if let exact = users.first(where: { $0.id == cachedID }) {
            return exact
        }

        if let existing = users.first {
            // Preserve an already-created local account rather than generating another.
            AwwIdentityCache.useExistingLocalUserID(existing.id)
            return existing
        }

        let newUser = AwwUser(id: cachedID)
        context.insert(newUser)
        return newUser
    }

    @discardableResult
    static func ensureOwnerPerson(
        preferredName: String? = nil,
        context: ModelContext
    ) throws -> Person {
        let account = try ensureLocalAccount(context: context)
        let people = try context.fetch(FetchDescriptor<Person>())

        if let owner = people.first(where: { $0.isOwner }) {
            owner.ownerUserID = account.id
            return owner
        }

        if let recovered = people.first(where: {
            $0.relation.localizedCaseInsensitiveCompare("Me") == .orderedSame
            || $0.name.localizedCaseInsensitiveCompare("Me") == .orderedSame
            || $0.name.localizedCaseInsensitiveCompare("You") == .orderedSame
        }) {
            recovered.isOwner = true
            recovered.ownerUserID = account.id
            recovered.relation = "Me"

            if recovered.name.localizedCaseInsensitiveCompare("You") == .orderedSame {
                recovered.name = preferredName ?? account.displayName.nonEmpty ?? "Me"
            }

            if recovered.emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || recovered.emoji == "✨" {
                recovered.emoji = "❤️"
            }

            recovered.updated = .now
            return recovered
        }

        let name = preferredName?.nonEmpty
            ?? account.displayName.nonEmpty
            ?? "Me"

        let owner = Person(
            name,
            relation: "Me",
            accent: "coral",
            emoji: "❤️",
            isOwner: true,
            ownerUserID: account.id
        )
        context.insert(owner)
        return owner
    }

    static func migrateLegacyData(
        to userID: UUID,
        context: ModelContext
    ) throws {
        let migrationKey = "AwwList.ownerMigration.v3.\(userID.uuidString)"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }

        let people = try context.fetch(FetchDescriptor<Person>())
        let ideas = try context.fetch(FetchDescriptor<Idea>())
        let attachments = try context.fetch(FetchDescriptor<IdeaAttachment>())
        let occasions = try context.fetch(FetchDescriptor<Occasion>())
        var categories = try context.fetch(FetchDescriptor<Category>())

        for person in people where person.ownerUserID == nil {
            person.ownerUserID = userID
        }

        for occasion in occasions where occasion.ownerUserID == nil {
            occasion.ownerUserID = userID
        }

        for attachment in attachments where attachment.ownerUserID == nil {
            attachment.ownerUserID = attachment.idea?.ownerUserID ?? userID
        }

        let legacyDefaultNames = currentLegacyDefaultCategoryNames()
        for name in legacyDefaultNames {
            let key = originalDefaultKey(forVisibleName: name)
                ?? name.lowercased()

            if let existingDefault = categories.first(where: {
                $0.ownerUserID == userID
                && (
                    $0.defaultKey == key
                    || ($0.defaultKey.isEmpty
                        && $0.isDefault
                        && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame)
                )
            }) {
                existingDefault.isDefault = true
                if existingDefault.defaultKey.isEmpty {
                    existingDefault.defaultKey = key
                }
            } else {
                let category = Category(
                    ownerUserID: userID,
                    name: name,
                    isDefault: true,
                    defaultKey: key
                )
                context.insert(category)
                categories.append(category)
            }
        }

        let legacyNames = uniqueCategoryValues(
            ideas.flatMap { categoryValues(from: $0.category) }
        )

        for name in legacyNames {
            if !categories.contains(where: {
                $0.ownerUserID == userID
                && $0.deletedAt == nil
                && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
            }) {
                let category = Category(
                    ownerUserID: userID,
                    name: name
                )
                context.insert(category)
                categories.append(category)
            }
        }

        let activeCategories = categories.filter {
            $0.ownerUserID == userID && $0.deletedAt == nil
        }

        for idea in ideas {
            if idea.ownerUserID == nil {
                idea.ownerUserID = userID
            }

            if idea.personIDs?.isEmpty != false {
                idea.personIDs = idea.person.map { [$0.id] } ?? []
            }

            if idea.categoryIDs?.isEmpty != false {
                let names = categoryValues(from: idea.category)
                idea.categoryIDs = names.compactMap { name in
                    activeCategories.first(where: {
                        $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
                    })?.id
                }
            }
        }

        try context.save()
        UserDefaults.standard.set(true, forKey: migrationKey)
    }

    private static func originalDefaultKey(forVisibleName visibleName: String) -> String? {
        let renamedKey = "AwwList.renamedDefaultCategories"
        let renamed = UserDefaults.standard.dictionary(forKey: renamedKey)
            as? [String: String] ?? [:]

        for original in awwDefaultCategoryNames {
            let key = original.lowercased()
            let current = renamed[key] ?? original
            if current.localizedCaseInsensitiveCompare(visibleName) == .orderedSame {
                return key
            }
        }
        return nil
    }

    private static func currentLegacyDefaultCategoryNames() -> [String] {
        let deletedKey = "AwwList.deletedDefaultCategories"
        let renamedKey = "AwwList.renamedDefaultCategories"
        let deleted = Set(
            UserDefaults.standard.stringArray(forKey: deletedKey) ?? []
        )
        let renamed = UserDefaults.standard.dictionary(forKey: renamedKey)
            as? [String: String] ?? [:]

        return awwDefaultCategoryNames.compactMap { original in
            let key = original.lowercased()
            guard !deleted.contains(key) else { return nil }
            return renamed[key] ?? original
        }
    }
}

// MARK: - Category identity

@MainActor
enum AwwCategoryStore {
    static func activeCategories(
        ownerUserID: UUID,
        context: ModelContext
    ) throws -> [Category] {
        try context.fetch(FetchDescriptor<Category>())
            .filter {
                $0.ownerUserID == ownerUserID && $0.deletedAt == nil
            }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
    }

    @discardableResult
    static func ensureCategory(
        named rawName: String,
        ownerUserID: UUID,
        isDefault: Bool = false,
        context: ModelContext
    ) throws -> Category {
        let name = normalizedCategoryName(rawName)
        let all = try context.fetch(FetchDescriptor<Category>())

        if let existing = all.first(where: {
            $0.ownerUserID == ownerUserID
            && $0.deletedAt == nil
            && $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }) {
            if isDefault { existing.isDefault = true }
            return existing
        }

        let category = Category(
            ownerUserID: ownerUserID,
            name: name,
            isDefault: isDefault
        )
        context.insert(category)
        return category
    }

    static func assign(
        names rawNames: [String],
        to idea: Idea,
        context: ModelContext
    ) throws {
        let ownerID = idea.ownerUserID
            ?? AwwIdentityCache.ensureLocalUserID()
        idea.ownerUserID = ownerID

        let names = uniqueCategoryValues(rawNames)
        let categories = try names.map {
            try ensureCategory(
                named: $0,
                ownerUserID: ownerID,
                context: context
            )
        }

        idea.categoryIDs = categories.map(\.id)
        idea.category = encodedCategoryValues(categories.map(\.name))
    }

    static func rename(
        categoryID: UUID,
        to rawName: String,
        context: ModelContext
    ) throws {
        let newName = normalizedCategoryName(rawName)
        guard !newName.isEmpty else { return }

        let categories = try context.fetch(FetchDescriptor<Category>())
        guard let category = categories.first(where: {
            $0.id == categoryID && $0.deletedAt == nil
        }) else { return }

        category.name = newName
        category.updatedAt = .now

        // Only refresh the denormalized legacy string cache. The wish relationship
        // remains categoryID-based and therefore never changes identity on rename.
        let ideas = try context.fetch(FetchDescriptor<Idea>())
        for idea in ideas where idea.categoryIDs?.contains(categoryID) == true {
            let names = try namesForCategoryIDs(
                idea.categoryIDs ?? [],
                context: context
            )
            idea.category = encodedCategoryValues(names)
            idea.updated = .now
        }
    }

    static func delete(
        categoryID: UUID,
        context: ModelContext
    ) throws {
        let categories = try context.fetch(FetchDescriptor<Category>())
        guard let category = categories.first(where: {
            $0.id == categoryID && $0.deletedAt == nil
        }) else { return }

        category.deletedAt = .now
        category.updatedAt = .now

        let ideas = try context.fetch(FetchDescriptor<Idea>())
        for idea in ideas where idea.categoryIDs?.contains(categoryID) == true {
            idea.categoryIDs = (idea.categoryIDs ?? []).filter { $0 != categoryID }
            let names = try namesForCategoryIDs(
                idea.categoryIDs ?? [],
                context: context
            )
            idea.category = encodedCategoryValues(names)
            idea.updated = .now
        }
    }

    static func namesForCategoryIDs(
        _ ids: [UUID],
        context: ModelContext
    ) throws -> [String] {
        let idSet = Set(ids)
        return try context.fetch(FetchDescriptor<Category>())
            .filter { idSet.contains($0.id) && $0.deletedAt == nil }
            .sorted {
                guard let first = ids.firstIndex(of: $0.id),
                      let second = ids.firstIndex(of: $1.id) else {
                    return $0.name < $1.name
                }
                return first < second
            }
            .map(\.name)
    }

    private static func normalizedCategoryName(_ rawName: String) -> String {
        rawName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#|"))
    }
}

private extension String {
    var nonEmpty: String? {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}
