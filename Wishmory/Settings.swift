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
import StoreKit

// MARK: - Settings

struct Settings: View {

    @Environment(\.dismiss)

    private var dismiss

    @Environment(\.modelContext)

    private var context

    @Environment(\.openURL)
    private var openURL

    @Environment(\.requestReview)
    private var requestReview

    @Query

    private var categories: [Category]

    @Query

    private var syncRecords: [AwwSyncRecord]

    @Query

    private var people: [Person]

    @Query

    private var ideas: [Idea]

    @Query

    private var occasions: [Occasion]

    @State private var erase = false

    @State private var restartOnboarding = false

    @State private var reminderStatus = ""

    @State private var settingsError = ""

    @State private var profileToEdit: Person?

    @State private var showShareSheet = false

    @AppStorage("onboarded")

    private var onboarded = true

    @AppStorage(NotificationScheduler.generalReminderEnabledKey)

    private var generalReminderEnabled = false

    @AppStorage("generalIdeaReminderWasExplicitlyChanged")

    private var reminderWasExplicitlyChanged = false

    @State private var suppressNextReminderPreferenceChange = false

    @AppStorage("generalIdeaReminderFrequency")

    private var reminderFrequency = GeneralReminderFrequency.daily.rawValue

    @AppStorage("generalIdeaReminderTime")

    private var reminderTimeInterval = Calendar.current.date(

        bySettingHour: 19,

        minute: 0,

        second: 0,

        of: .now

    )?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate

    @AppStorage("generalIdeaReminderWeekday")

    private var reminderWeekday = Calendar.current.component(.weekday, from: .now)

    private var reminderTime: Binding<Date> {

        Binding(

            get: { Date(timeIntervalSinceReferenceDate: reminderTimeInterval) },

            set: { reminderTimeInterval = $0.timeIntervalSinceReferenceDate }

        )

    }

    private var frequency: GeneralReminderFrequency {

        GeneralReminderFrequency(rawValue: reminderFrequency) ?? .daily

    }

    private var owner: Person? {

        people.first { $0.isOwner && $0.deletedAt == nil }

    }

    var body: some View {

        NavigationStack {

            Form {

                Section {

                    SettingsProfileHeader(owner: owner) {

                        profileToEdit = owner

                    }

                }

                Section("Categories") {

                    NavigationLink {

                        CategoriesView()

                    } label: {

                        SettingsNavigationRow(

                            title: "Categories",

                            systemImage: "tag"

                        )

                    }

                }

                // Always-visible review card
                Section {
                    SettingsCommunityCard(
                        symbol: "face.smiling",
                        title: "How’s AwwList treating you?",
                        message: "Is it making the little things easier to remember?"
                    ) {
                        HStack(spacing: 10) {
                            SettingsCommunityActionButton(
                                title: "Needs work",
                                symbol: "bubble.left",
                                style: .secondary
                            ) {
                                guard let feedbackURL = URL(
                                    string: "https://forms.gle/2QEjaYCzsRoQsJtEA"
                                ) else {
                                    return
                                }

                                openURL(feedbackURL)
                                AwwHaptics.selection()
                            }

                            SettingsCommunityActionButton(
                                title: "Love it",
                                symbol: "heart.fill",
                                style: .primary
                            ) {
                                AwwHaptics.success()
                                requestReview()
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                reminderSection

                Section("Onboarding") {

                    Button("Restart onboarding", systemImage: "arrow.clockwise") {

                        restartOnboarding = true

                    }

                    Text("Replay the welcome setup without removing your saved data.")

                        .font(.footnote)

                        .foregroundStyle(.secondary)

                }

                Section("Your library") {

                    Button("Delete all data", role: .destructive) {

                        erase = true

                    }

                    Text("You can delete an individual person’s list by long pressing their avatar on Home.")

                        .font(.footnote)

                        .foregroundStyle(.secondary)

                }

                // Always-visible share card at the bottom
                Section {
                    SettingsCommunityCard(
                        symbol: "person.2.fill",
                        title: "Know someone who needs this?",
                        message: "Send AwwList to the friend who’s always saying “I’ll remember.”"
                    ) {
                        SettingsCommunityActionButton(
                            title: "Share AwwList",
                            symbol: "square.and.arrow.up",
                            style: .primary,
                            fullWidth: true
                        ) {
                            showShareSheet = true
                            AwwHaptics.selection()
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

            }

            .navigationTitle("Settings")

            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Done") {

                        dismiss()

                    }

                }

            }

            .task {

                await applyNotificationReminderDefaultIfNeeded()

                await synchronizeGeneralReminders()

            }

            .onChange(of: generalReminderEnabled) { _, _ in

                if suppressNextReminderPreferenceChange {

                    suppressNextReminderPreferenceChange = false

                } else {

                    reminderWasExplicitlyChanged = true

                }

                Task {

                    await synchronizeGeneralReminders()

                }

            }

            .onChange(of: reminderFrequency) { _, _ in

                Task {

                    await synchronizeGeneralReminders()

                }

            }

            .onChange(of: reminderTimeInterval) { _, _ in

                Task {

                    await synchronizeGeneralReminders()

                }

            }

            .onChange(of: reminderWeekday) { _, _ in

                Task {

                    await synchronizeGeneralReminders()

                }

            }

            .alert("Restart onboarding?", isPresented: $restartOnboarding) {

                Button("Cancel", role: .cancel) {}

                Button("Restart onboarding") {

                    onboarded = false

                }

            } message: {

                Text("Your people, wishes, categories, and profile will stay in place.")

            }

            .alert("Delete everything?", isPresented: $erase) {

                Button("Cancel", role: .cancel) {}

                Button("Delete all local data", role: .destructive) {

                    deleteEverything()

                }

            } message: {

                Text("This removes every person, wish, category, moment, reminder, and attachment from this iPhone.")

            }

            .alert(

                "Couldn’t reset local data",

                isPresented: Binding(

                    get: { !settingsError.isEmpty },

                    set: { if !$0 { settingsError = "" } }

                )

            ) {

                Button("OK", role: .cancel) {}

            } message: {

                Text(settingsError)

            }

            .sheet(item: $profileToEdit) { owner in

                PersonForm(person: owner)

            }
            .sheet(isPresented: $showShareSheet) {
                SettingsActivitySheet(
                    items: [
                        "I’m using AwwList to remember the little things people mention so I don’t forget them.",
                        URL(string: "https://apps.apple.com/us/app/awwlist/id6807372613")!
                    ]
                )
            }

        }

    }

    private var reminderSection: some View {

        Section("Idea reminders") {

            Toggle("Remind me to save ideas", isOn: $generalReminderEnabled)

            if generalReminderEnabled {

                Picker("Repeat", selection: $reminderFrequency) {

                    ForEach(GeneralReminderFrequency.allCases) { frequency in

                        Text(frequency.title)

                            .tag(frequency.rawValue)

                    }

                }

                if frequency == .weekly {

                    Picker("Day", selection: $reminderWeekday) {

                        ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, weekday in

                            Text(weekday)

                                .tag(index + 1)

                        }

                    }

                }

                DatePicker(

                    "Time",

                    selection: reminderTime,

                    displayedComponents: .hourAndMinute

                )

            }

            Button("Send an example reminder", systemImage: "bell.badge") {

                Task {

                    let status = await NotificationScheduler.authorizationStatus()

                    let isAuthorized = status == .authorized || status == .provisional

                        ? true

                        : await NotificationScheduler.requestAuthorization()

                    let didSchedule = isAuthorized

                        ? await NotificationScheduler.sendExampleReminder()

                        : false

                    reminderStatus = didSchedule

                        ? "Example reminder will arrive in a few seconds."

                        : "Allow notifications in iPhone Settings to send an example."

                }

            }

            if !reminderStatus.isEmpty {

                Text(reminderStatus)

                    .font(.footnote)

                    .foregroundStyle(.secondary)

            }

            Text("Choose a time that fits your routine. You can also turn reminders off directly from any idea reminder.")

                .font(.footnote)

                .foregroundStyle(.secondary)

        }

    }

    private func applyNotificationReminderDefaultIfNeeded() async {

        guard !reminderWasExplicitlyChanged else { return }

        let status = await NotificationScheduler.authorizationStatus()

        guard status == .authorized || status == .provisional else { return }

        guard !generalReminderEnabled else { return }

        suppressNextReminderPreferenceChange = true

        generalReminderEnabled = true

    }

    private func synchronizeGeneralReminders() async {

        await NotificationScheduler.synchronizeGeneralReminders(

            isEnabled: generalReminderEnabled,

            frequency: frequency,

            time: reminderTime.wrappedValue,

            weekday: reminderWeekday

        )

    }

    private func deleteEverything() {

        do {

            ideas.forEach(context.delete)

            people.forEach(context.delete)

            occasions.forEach(context.delete)

            categories.forEach(context.delete)

            syncRecords.forEach(context.delete)

            let account = try AwwAccountManager.ensureLocalAccount(context: context)

            let owner = Person(

                account.displayName.nonEmptyValue ?? "Me",

                relation: "Me",

                accent: "coral",

                emoji: "❤️",

                isOwner: true,

                ownerUserID: account.id

            )

            context.insert(owner)

            for name in awwDefaultCategoryNames {

                context.insert(

                    Category(

                        ownerUserID: account.id,

                        name: name,

                        isDefault: true,

                        defaultKey: name.lowercased()

                    )

                )

            }

            try context.save()

            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)

        } catch {

            settingsError = "Couldn’t reset local data: \(error.localizedDescription)"

        }

    }

}


private struct SettingsCommunityCard<Actions: View>: View {
    let symbol: String
    let title: String
    let message: String

    @ViewBuilder
    let actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            actions()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.055), lineWidth: 1)
        }
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 18,
            x: 0,
            y: 8
        )
        .accessibilityElement(children: .contain)
    }
}

private struct SettingsCommunityActionButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let symbol: String?
    let style: Style
    let fullWidth: Bool
    let action: () -> Void

    init(
        title: String,
        symbol: String? = nil,
        style: Style,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.style = style
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.subheadline.weight(.semibold))
                }

                Text(title)
                    .font(.subheadline.weight(.bold))
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .foregroundStyle(style == .primary ? Color.white : Color.primary)
            .background {
                if style == .primary {
                    Capsule()
                        .fill(Color.red)
                } else {
                    Capsule()
                        .fill(Color.primary.opacity(0.065))
                }
            }
            .overlay {
                if style == .secondary {
                    Capsule()
                        .stroke(Color.primary.opacity(0.07), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsActivitySheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

private struct SettingsProfileHeader: View {

    let owner: Person?

    let editProfile: () -> Void

    var body: some View {

        Button(action: editProfile) {

            HStack(spacing: 14) {

                if let owner {

                    Avatar(person: owner, size: 64)

                } else {

                    Image(systemName: "person.crop.circle.fill")

                        .font(.system(size: 64))

                        .foregroundStyle(.red)

                }

                VStack(alignment: .leading, spacing: 4) {

                    Text(owner?.name.nonEmptyValue ?? "Your profile")

                        .font(.headline.weight(.semibold))

                        .foregroundStyle(.primary)

                    Text("Edit profile")

                        .font(.subheadline)

                        .foregroundStyle(.red)

                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")

                    .font(.caption.weight(.bold))

                    .foregroundStyle(.tertiary)

            }

            .contentShape(Rectangle())

        }

        .buttonStyle(.plain)

        .disabled(owner == nil)

        .accessibilityHint("Opens your profile editor")

    }

}

private struct SettingsNavigationRow: View {

    let title: LocalizedStringKey

    let systemImage: String

    var body: some View {

        Label(title, systemImage: systemImage)

            .foregroundStyle(.primary)

    }

}
