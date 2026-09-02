import SwiftUI
import WidgetKit

struct WishmoryWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WishmoryWidgetEntry {
        WishmoryWidgetEntry(date: .now, people: .previewPeople)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WishmoryWidgetEntry {
        WishmoryWidgetEntry(date: .now, people: displayedPeople(for: configuration))
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WishmoryWidgetEntry> {
        Timeline(
            entries: [WishmoryWidgetEntry(date: .now, people: displayedPeople(for: configuration))],
            policy: .never
        )
    }

    private func displayedPeople(for configuration: ConfigurationAppIntent) -> [WidgetPersonEntity] {
        let configuredPeople = configuration.people ?? []
        return configuredPeople.isEmpty ? Array(WidgetPeopleStore.people.prefix(4)) : configuredPeople
    }
}

struct WishmoryWidgetEntry: TimelineEntry {
    let date: Date
    let people: [WidgetPersonEntity]
}

struct WishmoryWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: WishmoryWidgetEntry

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
        VStack(alignment: .leading, spacing: 10) {
            AwwWidgetBrand()

            Spacer(minLength: 0)

            Text("Wishes come true")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            HStack(alignment: .bottom) {
                Text("Save it before it disappears.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                AwwAddWishButton(destination: destination)
            }
        }
    }
}

private struct AwwMediumWidgetContent: View {
    let destination: URL?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 9) {
                AwwWidgetBrand()

                Spacer(minLength: 0)

                Text("Omg you remembered!")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text("Exactly.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 12) {
                AwwAddWishButton(destination: destination, size: 56)

                Text("Save a wish")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
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
    var body: some View {
        HStack(spacing: 8) {
            Image("AwwListLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            Text("AwwList")
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
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
        .padding(12)
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
                .background(.white, in: Circle())
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
    static let card = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let divider = Color.black.opacity(0.08)
}

struct WishmoryWidget: Widget {
    let kind = "WishmoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: WishmoryWidgetProvider()
        ) { entry in
            WishmoryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AwwList")
        .description("Save a wish before it disappears.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

private extension View {
    var widgetSurface: some View {
        self
            .padding()
            .containerBackground(.white, for: .widget)
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
    WishmoryWidget()
} timeline: {
    WishmoryWidgetEntry(date: .now, people: .previewPeople)
}

#Preview(as: .systemMedium) {
    WishmoryWidget()
} timeline: {
    WishmoryWidgetEntry(date: .now, people: .previewPeople)
}

#Preview(as: .systemLarge) {
    WishmoryWidget()
} timeline: {
    WishmoryWidgetEntry(date: .now, people: .previewPeople)
}
