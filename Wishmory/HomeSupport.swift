import SwiftUI
import Foundation
import SwiftData
import UIKit
import PhotosUI
import UserNotifications
import UniformTypeIdentifiers
import Combine
import MetricKit
import TipKit

// MARK: - Home

struct CategorySheetRoute: Identifiable, Equatable {
    let id: UUID
    let categoryID: UUID?
    let fallbackName: String?
    let legacyName: String?

    init(categoryID: UUID, name: String? = nil) {
        self.id = categoryID
        self.categoryID = categoryID
        self.fallbackName = name
        self.legacyName = nil
    }

    init(legacyName: String) {
        self.id = UUID()
        self.categoryID = nil
        self.fallbackName = legacyName
        self.legacyName = legacyName
    }
}

struct UpcomingEvent: Identifiable {
    let id: String
    let title: String
    let date: Date
    let symbol: String
    let detail: String
    let person: Person?
}

private struct NextEventSummaryCard: View {
    let event: UpcomingEvent

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(event.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(event.relativeDateDescription)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(event.palette.tintColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)

                        Text(event.relativeDateDescription)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(event.palette.tintColor)
                    }
                }

                Text(event.reminder)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(event.palette.tintColor)
                .frame(width: 36, height: 36)
            .accessibilityHidden(true)
        }
        .padding(18)
        .background(
            event.palette.cardFill,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

struct NextEventSummarySection: View {
    let events: [UpcomingEvent]

    var body: some View {
        if let nextEvent = events.first {
            NavigationLink {
                UpcomingEventsView(events: events)
            } label: {
                NextEventSummaryCard(event: nextEvent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Next event: \(nextEvent.title)")
            .accessibilityHint("Shows all upcoming events")
        }
    }
}

enum GiftingCalendar {
    static func upcomingEvents(after date: Date, calendar: Calendar = .current) -> [UpcomingEvent] {
        let fixedEvents = [
            ("new-year", "New Year’s Day", 1, 1, "sparkles"),
            ("valentines-day", "Valentine’s Day", 2, 14, "heart.fill"),
            ("womens-day", "International Women’s Day", 3, 8, "heart.circle.fill"),
            ("halloween", "Halloween", 10, 31, "moon.stars.fill"),
            ("black-friday", "Black Friday", 11, 27, "bag.fill"),
            ("christmas-eve", "Christmas Eve", 12, 24, "gift.fill"),
            ("christmas", "Christmas Day", 12, 25, "tree.fill"),
            ("new-years-eve", "New Year’s Eve", 12, 31, "party.popper.fill")
        ]

        let events = fixedEvents.compactMap { event -> UpcomingEvent? in
            guard let eventDate = nextDate(
                month: event.2,
                day: event.3,
                after: date,
                calendar: calendar
            ) else {
                return nil
            }

            return UpcomingEvent(
                id: event.0,
                title: event.1,
                date: eventDate,
                symbol: event.4,
                detail: "Gifting occasion",
                person: nil
            )
        }

        return events.sorted { $0.date < $1.date }
    }

    static func nextBirthday(
        for person: Person,
        after date: Date,
        calendar: Calendar = .current
    ) -> UpcomingEvent? {
        guard let birthday = person.birthday else { return nil }

        let components = calendar.dateComponents([.month, .day], from: birthday)
        guard let month = components.month,
              let day = components.day,
              let nextDate = nextDate(month: month, day: day, after: date, calendar: calendar) else {
            return nil
        }

        return UpcomingEvent(
            id: "birthday-\(person.id.uuidString)",
            title: "\(person.name)’s birthday",
            date: nextDate,
            symbol: "birthday.cake.fill",
            detail: person.relation,
            person: person
        )
    }

    private static func nextDate(
        month: Int,
        day: Int,
        after date: Date,
        calendar: Calendar
    ) -> Date? {
        let year = calendar.component(.year, from: date)

        for candidateYear in year...(year + 1) {
            var components = DateComponents()
            components.year = candidateYear
            components.month = month
            components.day = day
            components.hour = 9

            if let candidate = calendar.date(from: components),
               candidate >= calendar.startOfDay(for: date) {
                return candidate
            }
        }

        return nil
    }
}


private enum UpcomingEventPalette {
    case rose
    case peach
    case lavender
    case mint
    case sky
    case butter

    /// System colors resolve for the current appearance, keeping event accents
    /// vibrant while their translucent fills remain legible in light and dark mode.
    var tintColor: Color {
        switch self {
        case .rose: Color(uiColor: .systemRed)
        case .peach: Color(uiColor: .systemOrange)
        case .lavender: Color(uiColor: .systemPurple)
        case .mint: Color(uiColor: .systemGreen)
        case .sky: Color(uiColor: .systemBlue)
        case .butter: Color(uiColor: .systemYellow)
        }
    }

    var cardFill: Color {
        tintColor.opacity(0.2)
    }
}

private extension UpcomingEvent {
    var palette: UpcomingEventPalette {
        if id.hasPrefix("birthday-") {
            return .lavender
        }

        if id.hasPrefix("occasion-") {
            return .mint
        }

        switch id {
        case "valentines-day", "womens-day", "halloween", "black-friday":
            return .rose
        case "christmas-eve", "christmas":
            return .mint
        case "new-year", "new-years-eve":
            return .peach
        default:
            return .butter
        }
    }

    var daysUntilEvent: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfEvent = calendar.startOfDay(for: date)
        return max(
            0,
            calendar.dateComponents(
                [.day],
                from: startOfToday,
                to: startOfEvent
            ).day ?? 0
        )
    }

    var relativeDateDescription: LocalizedStringResource {
        switch daysUntilEvent {
        case 0:
            "today"
        case 1:
            "in 1 day"
        default:
            "in \(daysUntilEvent) days"
        }
    }

    var reminder: LocalizedStringResource {
        if id.hasPrefix("birthday-") {
            return "Save a gift idea they’ll genuinely love before their day arrives."
        }

        if id.hasPrefix("occasion-") {
            return "Keep one thoughtful idea ready for the moment worth celebrating."
        }

        switch id {
        case "new-year":
            return "Save a little something to help them begin the year feeling seen."
        case "new-years-eve":
            return "Capture a celebratory idea now, ready for a memorable midnight surprise."
        case "valentines-day":
            return "Turn the small things they love into a personal Valentine’s surprise."
        case "womens-day":
            return "Remember a meaningful way to celebrate the women who inspire you."
        case "halloween":
            return "Save costume, party, and treat ideas before spooky season sneaks up."
        case "black-friday":
            return "Keep their best wish-list picks handy when the offers start appearing."
        case "christmas-eve":
            return "Have their most thoughtful gift idea ready before the festive rush."
        case "christmas":
            return "Hold on to the details that make this year’s gift feel personal."
        default:
            return "Save a small detail today and turn it into a thoughtful moment later."
        }
    }
}

private struct UpcomingEventListCard: View {
    let event: UpcomingEvent

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(event.relativeDateDescription)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(event.palette.tintColor)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(event.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .layoutPriority(1)

                    Text(event.date, format: .dateTime.month(.abbreviated).day())
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(event.palette.tintColor)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text(event.reminder)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let person = event.person {
                Avatar(person: person, size: 42)
            } else {
                Image(systemName: event.symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(event.palette.tintColor)
                    .frame(width: 42, height: 42)
                    .background(event.palette.tintColor.opacity(0.12), in: Circle())
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            event.palette.cardFill,
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct UpcomingEventsView: View {
    let events: [UpcomingEvent]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events) { event in
                    UpcomingEventListCard(event: event)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Next Events")
        .navigationBarTitleDisplayMode(.large)
    }
}

enum AppFeedbackResponse: Equatable {
    case happy
    case unhappy
}
