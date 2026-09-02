import AppIntents
import Foundation
import WidgetKit

struct WidgetPersonEntity: AppEntity, Hashable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Person"
    static var defaultQuery = WidgetPeopleQuery()

    let id: String
    let name: String
    let relation: String
    let emoji: String
    let wishCount: Int

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: name),
            subtitle: LocalizedStringResource(stringLiteral: relation),
            image: .init(systemName: "heart.fill")
        )
    }
}

struct WidgetPeopleQuery: EntityQuery {
    func entities(for identifiers: [WidgetPersonEntity.ID]) async throws -> [WidgetPersonEntity] {
        let peopleByID = Dictionary(uniqueKeysWithValues: WidgetPeopleStore.people.map { ($0.id, $0) })
        return identifiers.compactMap { peopleByID[$0] }
    }

    func suggestedEntities() async throws -> [WidgetPersonEntity] {
        WidgetPeopleStore.people
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Wishmory" }
    static var description = IntentDescription("Choose the people you want to keep close on your Home Screen.")

    @Parameter(title: "People to show")
    var people: [WidgetPersonEntity]?
}

enum WidgetPeopleStore {
    private static let appGroupIdentifier = "group.com.stefanbozovic.awwlist"
    private static let snapshotKey = "Wishmory.widgetSnapshot.v1"

    private struct Snapshot: Codable {
        let people: [WidgetPersonEntity]
    }

    static var people: [WidgetPersonEntity] {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: snapshotKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return []
        }

        return snapshot.people
    }
}
