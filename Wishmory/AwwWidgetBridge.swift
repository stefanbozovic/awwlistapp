import Foundation
import SwiftData
import WidgetKit

enum AwwWidgetBridge {
    private static let appGroupIdentifier = "group.com.stefanbozovic.awwlist"
    private static let snapshotKey = "AwwList.widgetSnapshot.v1"

    private struct Snapshot: Codable {
        let people: [PersonSnapshot]
    }

    private struct PersonSnapshot: Codable {
        let id: String
        let name: String
        let relation: String
        let emoji: String
        let wishCount: Int
    }

    static func refresh(people: [Person], ideas: [Idea]) {
        let activePeople = people
            .filter { $0.deletedAt == nil }
            .sorted { $0.created < $1.created }

        let snapshots = activePeople.map { person in
            PersonSnapshot(
                id: person.id.uuidString,
                name: person.name,
                relation: person.relation,
                emoji: person.emoji,
                wishCount: ideas.filter {
                    $0.deletedAt == nil && ($0.personIDs?.contains(person.id) == true || $0.person?.id == person.id)
                }.count
            )
        }

        guard let data = try? JSONEncoder().encode(Snapshot(people: snapshots)),
              let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return
        }

        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "AwwListWidget")
    }
}
