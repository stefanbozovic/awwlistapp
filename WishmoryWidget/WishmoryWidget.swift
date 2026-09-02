import SwiftUI
import WidgetKit

struct AwwListWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> AwwListWidgetEntry {
        AwwListWidgetEntry(date: .now, people: .previewPeople)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> AwwListWidgetEntry {
        AwwListWidgetEntry(date: .now, people: displayedPeople(for: configuration))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<AwwListWidgetEntry> {
        Timeline(
            entries: [AwwListWidgetEntry(date: .now, people: displayedPeople(for: configuration))],
            policy: .never
        )
    }

    private func displayedPeople(for configuration: ConfigurationAppIntent) -> [WidgetPersonEntity] {
        let configuredPeople = configuration.people ?? []
        return configuredPeople.isEmpty ? Array(WidgetPeopleStore.people.prefix(4)) : configuredPeople
    }
}

struct AwwListWidgetEntry: TimelineEntry {
    let date: Date
    let people: [WidgetPersonEntity]
}

struct AwwListWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: AwwListWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                AwwSmallWidgetContent(destination: WidgetDestination.composerURL)
            case .systemMedium:
                AwwMediumWidgetContent(destination: WidgetDestination.composerURL)
            default:
                AwwLargeWidgetContent(
                    people: Array(entry.people.prefix(3)),
                    destination: WidgetDestination.composerURL
                )
            }
        }
        .widgetSurface
    }
}

private struct AwwSmallWidgetContent: View {
    let destination: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                AwwWidgetBrand(compact: true)

                Spacer(minLength: 4)

                AwwAddWishButton(destination: destination, size: 42)
            }

            Text("Wishes come true")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text("Save a wish")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct AwwMediumWidgetContent: View {
    let destination: URL?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 9) {
                AwwWidgetBrand()

                Spacer(minLength: 0)

                Text("You remembered!")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Exactly.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            AwwAddWishButton(destination: destination, size: 50)
        }
    }
}

private struct AwwLargeWidgetContent: View {
    let people: [WidgetPersonEntity]
    let destination: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                AwwWidgetBrand()

                Spacer()

                AwwAddWishButton(destination: destination)
            }

            Text("Wishes come true")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Text("Save a wish before it disappears.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            AwwPeopleSummary(people: people)

            Spacer(minLength: 0)
        }
    }
}

private struct AwwWidgetBrand: View {
    var compact = false

    var body: some View {
        HStack(spacing: 8) {
            Image("AwwListLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            if !compact {
                Text("AwwList")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }
}

private struct AwwAddWishButton: View {
    let destination: URL?
    var size: CGFloat = 44

    var body: some View {
        if let destination {
            Link(destination: destination) {
                Image(systemName: "plus")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(AwwWidgetColor.red, in: Circle())
                    .accessibilityLabel("Save a wish")
            }
        }
    }
}

private struct AwwPeopleSummary: View {
    let people: [WidgetPersonEntity]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("YOUR PEOPLE")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            if people.isEmpty {
                Text("Add someone you love in AwwList.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(people, id: \.id) { person in
                    AwwPersonRow(person: person)
                }
            }
        }
        .padding(10)
        .background(AwwWidgetColor.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct AwwPersonRow: View {
    let person: WidgetPersonEntity

    var body: some View {
        HStack(spacing: 9) {
            Text(person.emoji.isEmpty ? "♡" : person.emoji)
                .font(.body)
                .frame(width: 28, height: 28)
                .background(AwwWidgetColor.avatar, in: Circle())
                .overlay(Circle().stroke(AwwWidgetColor.divider, lineWidth: 1))

            Text(person.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text("\(person.wishCount)")
                .font(.caption.weight(.bold))
                .foregroundStyle(AwwWidgetColor.red)
        }
    }
}

private enum WidgetDestination {
    static let composerURL = URL(string: "awwlist://composer")
}

private enum AwwWidgetColor {
    static let red = Color(red: 0.94, green: 0.06, blue: 0.24)
    static let background = Color(uiColor: .systemBackground)
    static let card = Color(uiColor: .secondarySystemBackground)
    static let avatar = Color(uiColor: .tertiarySystemBackground)
    static let divider = Color.black.opacity(0.08)
}

struct AwwListWidget: Widget {
    let kind = "AwwListWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: AwwListWidgetProvider()
        ) { entry in
            AwwListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AwwList")
        .description("Save a wish before it disappears.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

private extension View {
    var widgetSurface: some View {
        self
            .padding(12)
            .containerBackground(AwwWidgetColor.background, for: .widget)
    }
}

private extension Array where Element == WidgetPersonEntity {
    static let previewPeople = [
        WidgetPersonEntity(id: "1", name: "Mia", relation: "Sister", emoji: "🌷", wishCount: 8),
        WidgetPersonEntity(id: "2", name: "Leo", relation: "Best friend", emoji: "✨", wishCount: 4),
        WidgetPersonEntity(id: "3", name: "Nina", relation: "Partner", emoji: "❤️", wishCount: 12)
    ]
}

#Preview(as: .systemSmall) {
    AwwListWidget()
} timeline: {
    AwwListWidgetEntry(date: .now, people: .previewPeople)
}

#Preview(as: .systemMedium) {
    AwwListWidget()
} timeline: {
    AwwListWidgetEntry(date: .now, people: .previewPeople)
}

#Preview(as: .systemLarge) {
    AwwListWidget()
} timeline: {
    AwwListWidgetEntry(date: .now, people: .previewPeople)
}
