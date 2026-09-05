import SwiftUI
import SwiftData
import Foundation
import UIKit
import UniformTypeIdentifiers

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


