import Foundation
import SwiftData
import AuthenticationServices

// MARK: - Apple identity persistence

struct AwwAppleCredentialSnapshot: Sendable {
    let appleUserIdentifier: String
    let givenName: String?
    let identityToken: Data?
    let authorizationCode: Data?
}

enum AwwAppleIdentityStore {
    private static let appleUserKey = "AwwList.appleUserIdentifier.v1"
    private static let appleGivenNameKey = "AwwList.appleGivenName.v1"

    static var appleUserIdentifier: String? {
        let value = UserDefaults.standard.string(forKey: appleUserKey)
        return value?.isEmpty == false ? value : nil
    }

    static var givenName: String? {
        let value = UserDefaults.standard.string(forKey: appleGivenNameKey)
        return value?.isEmpty == false ? value : nil
    }

    // Apple can provide the name only on the first authorization. Persist it before
    // any network work so it survives app termination immediately after sign-in.
    static func persist(appleUserIdentifier: String, givenName: String?) {
        UserDefaults.standard.set(appleUserIdentifier, forKey: appleUserKey)

        if let givenName = normalizedName(givenName), !givenName.isEmpty {
            UserDefaults.standard.set(givenName, forKey: appleGivenNameKey)
        }
    }

    static func normalizedName(_ value: String?) -> String? {
        guard let value else { return nil }
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}

// MARK: - Account + legacy-data migration

@MainActor
enum AwwAccountManager {
    static func snapshot(from credential: ASAuthorizationAppleIDCredential) -> AwwAppleCredentialSnapshot {
        let givenName = AwwAppleIdentityStore.normalizedName(
            credential.fullName?.givenName
        )

        return AwwAppleCredentialSnapshot(
            appleUserIdentifier: credential.user,
            givenName: givenName,
            identityToken: credential.identityToken,
            authorizationCode: credential.authorizationCode
        )
    }

    @discardableResult
    static func acceptAppleCredential(
        _ credential: ASAuthorizationAppleIDCredential,
        context: ModelContext
    ) throws -> AwwUser {
        let apple = snapshot(from: credential)

        // Persist Apple's one-time name immediately, before server sync.
        AwwAppleIdentityStore.persist(
            appleUserIdentifier: apple.appleUserIdentifier,
            givenName: apple.givenName
        )

        let account = try ensureLocalAccount(context: context)
        account.appleUserIdentifier = apple.appleUserIdentifier

        if let name = apple.givenName {
            account.displayName = name
        } else if account.displayName.isEmpty,
                  let cachedName = AwwAppleIdentityStore.givenName {
            account.displayName = cachedName
        }

        account.updatedAt = .now
        try migrateLegacyData(to: account.id, context: context)
        try context.save()

        return account
    }

    @discardableResult
    static func ensureLocalAccount(context: ModelContext) throws -> AwwUser {
        let cachedID = AwwIdentityCache.ensureLocalUserID()
        let users = try context.fetch(FetchDescriptor<AwwUser>())

        if let exact = users.first(where: { $0.id == cachedID }) {
            return exact
        }

        if let appleID = AwwAppleIdentityStore.appleUserIdentifier,
           let appleMatch = users.first(where: {
               $0.appleUserIdentifier == appleID
           }) {
            AwwIdentityCache.adoptCanonicalUserID(appleMatch.id)
            return appleMatch
        }

        if let existing = users.first {
            // Preserve an already-created local account rather than generating another.
            AwwIdentityCache.adoptCanonicalUserID(existing.id)
            return existing
        }

        let newUser = AwwUser(
            id: cachedID,
            appleUserIdentifier: AwwAppleIdentityStore.appleUserIdentifier ?? "",
            displayName: AwwAppleIdentityStore.givenName ?? ""
        )
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

        let name = preferredName.nonEmpty
            ?? account.displayName.nonEmpty
            ?? AwwAppleIdentityStore.givenName.nonEmpty
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

    static func adoptCanonicalUserID(
        _ canonicalID: UUID,
        context: ModelContext
    ) throws {
        let oldID = AwwIdentityCache.ensureLocalUserID()
        guard oldID != canonicalID else { return }

        let users = try context.fetch(FetchDescriptor<AwwUser>())
        let people = try context.fetch(FetchDescriptor<Person>())
        let ideas = try context.fetch(FetchDescriptor<Idea>())
        let attachments = try context.fetch(FetchDescriptor<IdeaAttachment>())
        let occasions = try context.fetch(FetchDescriptor<Occasion>())
        let categories = try context.fetch(FetchDescriptor<Category>())
        let reminders = try context.fetch(FetchDescriptor<AwwReminder>())
        let shareGrants = try context.fetch(FetchDescriptor<AwwShareGrant>())
        let syncRecords = try context.fetch(FetchDescriptor<AwwSyncRecord>())

        if let user = users.first(where: { $0.id == oldID }) ?? users.first {
            user.id = canonicalID
            user.updatedAt = .now
        }

        people.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        ideas.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        attachments.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        occasions.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        categories.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        reminders.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        shareGrants.filter { $0.ownerUserID == oldID || $0.ownerUserID == nil }
            .forEach { $0.ownerUserID = canonicalID }
        syncRecords.filter { $0.ownerUserID == oldID }
            .forEach { $0.ownerUserID = canonicalID }

        AwwIdentityCache.adoptCanonicalUserID(canonicalID)
        try context.save()
    }

    static func restoreAppleCredentialState() async -> ASAuthorizationAppleIDProvider.CredentialState? {
        guard let appleUserIdentifier = AwwAppleIdentityStore.appleUserIdentifier else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(
                forUserID: appleUserIdentifier
            ) { state, _ in
                continuation.resume(returning: state)
            }
        }
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

// MARK: - Server-ready auth/sync contract

nonisolated struct AwwCloudAccountResponse: Codable, Sendable {
    let userID: UUID
    let displayName: String?
}

nonisolated struct AwwAppleAuthRequest: Codable, Sendable {
    let proposedUserID: UUID
    let appleUserIdentifier: String
    let displayName: String?
    let identityTokenBase64: String?
    let authorizationCodeBase64: String?
}

protocol AwwSyncTransport: Sendable {
    func linkAppleAccount(_ request: AwwAppleAuthRequest) async throws -> AwwCloudAccountResponse
}

actor AwwURLSyncTransport: AwwSyncTransport {
    static let shared = AwwURLSyncTransport()

    enum TransportError: Error {
        case notConfigured
        case invalidResponse
    }

    private var baseURL: URL? {
        guard let raw = Bundle.main.object(
            forInfoDictionaryKey: "AwwListAPIBaseURL"
        ) as? String else {
            return nil
        }
        return URL(string: raw)
    }

    func linkAppleAccount(
        _ request: AwwAppleAuthRequest
    ) async throws -> AwwCloudAccountResponse {
        guard let baseURL else {
            throw TransportError.notConfigured
        }

        var urlRequest = URLRequest(
            url: baseURL.appendingPathComponent("v1/auth/apple")
        )
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw TransportError.invalidResponse
        }

        return try JSONDecoder().decode(AwwCloudAccountResponse.self, from: data)
    }
}

@MainActor
enum AwwCloudAccountBridge {
    static func linkInBackground(
        credential: AwwAppleCredentialSnapshot,
        localUserID: UUID,
        displayName: String?,
        context: ModelContext,
        transport: any AwwSyncTransport = AwwURLSyncTransport.shared
    ) {
        let request = AwwAppleAuthRequest(
            proposedUserID: localUserID,
            appleUserIdentifier: credential.appleUserIdentifier,
            displayName: displayName,
            identityTokenBase64: credential.identityToken?.base64EncodedString(),
            authorizationCodeBase64: credential.authorizationCode?.base64EncodedString()
        )

        Task {
            do {
                let remote = try await transport.linkAppleAccount(request)
                try AwwAccountManager.adoptCanonicalUserID(
                    remote.userID,
                    context: context
                )

                if let name = remote.displayName.nonEmpty,
                   let user = try context.fetch(FetchDescriptor<AwwUser>()).first {
                    user.displayName = name
                    user.updatedAt = .now
                    try context.save()
                }

                NotificationCenter.default.post(
                    name: .awwDataDidChange,
                    object: nil
                )
            } catch AwwURLSyncTransport.TransportError.notConfigured {
                // Local-first development mode. The app is fully usable offline and
                // will start linking once AwwListAPIBaseURL is configured.
            } catch {
                UserDefaults.standard.set(
                    String(describing: error),
                    forKey: "AwwList.lastAccountSyncError"
                )
            }
        }
    }
}

private extension Optional where Wrapped == String {
    var nonEmpty: String? {
        guard let self else { return nil }
        let cleaned = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}

private extension String {
    var nonEmpty: String? {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}
