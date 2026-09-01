//
//  ShareExtension.swift
//  Wishlistia
//
//  Created by Stefan Bozovic on 31.08.2026.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

private enum SharedAwwListBridge {
    struct PersonSnapshot: Codable, Identifiable, Hashable {
        let id: UUID
        let name: String
        let emoji: String
        let isOwner: Bool
    }

    struct PendingShare: Codable, Identifiable {
        let id: UUID
        let text: String
        let urlString: String?
        let recipientIDs: [UUID]
        let created: Date
    }

    private static let peopleKey = "AwwList.sharedPeople.v1"
    private static let pendingKey = "AwwList.pendingShares.v1"

    static var appGroupID: String? {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "AwwListAppGroup") as? String,
           !configured.isEmpty {
            return configured
        }

        guard var bundleID = Bundle.main.bundleIdentifier, !bundleID.isEmpty else { return nil }
        if bundleID.hasSuffix(".ShareExtension") {
            bundleID.removeLast(".ShareExtension".count)
        }
        return "group.\(bundleID)"
    }

    private static var defaults: UserDefaults? {
        guard let appGroupID, !appGroupID.isEmpty else { return nil }
        return UserDefaults(suiteName: appGroupID)
    }

    static func people() -> [PersonSnapshot] {
        guard let data = defaults?.data(forKey: peopleKey),
              let people = try? JSONDecoder().decode([PersonSnapshot].self, from: data) else {
            return []
        }

        return people.sorted { first, second in
            if first.isOwner != second.isOwner { return first.isOwner }
            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
    }

    static func enqueue(
        text: String,
        url: URL?,
        recipientIDs: Set<UUID>
    ) -> Bool {
        guard let defaults, !recipientIDs.isEmpty else { return false }

        let pending = PendingShare(
            id: UUID(),
            text: text,
            urlString: url?.absoluteString,
            recipientIDs: Array(recipientIDs),
            created: .now
        )

        var queue: [PendingShare] = []
        if let existing = defaults.data(forKey: pendingKey),
           let decoded = try? JSONDecoder().decode([PendingShare].self, from: existing) {
            queue = decoded
        }

        queue.append(pending)
        guard let encoded = try? JSONEncoder().encode(queue) else { return false }
        defaults.set(encoded, forKey: pendingKey)
        return defaults.synchronize()
    }
}

private struct SharedPayload {
    var text = ""
    var url: URL?

    var displayText: String {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        return url?.absoluteString ?? "Shared product"
    }
}

final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let root = AwwListShareView(
            extensionContext: extensionContext
        )
        let host = UIHostingController(rootView: root)

        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
    }
}

private struct AwwListShareView: View {
    let extensionContext: NSExtensionContext?

    @State private var payload = SharedPayload()
    @State private var people: [SharedAwwListBridge.PersonSnapshot] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var didSave = false
    @State private var errorMessage: String?
    @State private var showingAllPeople = false

    private var visiblePeople: [SharedAwwListBridge.PersonSnapshot] {
        Array(people.prefix(5))
    }

    var body: some View {
        NavigationStack {
            Group {
                if didSave {
                    successState
                } else if isLoading {
                    loadingState
                } else {
                    content
                }
            }
            .navigationTitle("Add to AwwList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        extensionContext?.cancelRequest(
                            withError: NSError(
                                domain: "AwwList.ShareExtension",
                                code: NSUserCancelledError
                            )
                        )
                    }
                    .disabled(isSaving)
                }
            }
        }
        .task {
            people = SharedAwwListBridge.people()
            payload = await loadSharedPayload()
            isLoading = false
        }
        .sheet(isPresented: $showingAllPeople) {
            allPeopleSheet
        }
    }

    private var loadingState: some View {
        VStack(spacing: 14) {
            ProgressView()
            Text("Reading shared product…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                sharedPreview

                if people.isEmpty {
                    ContentUnavailableView(
                        "Open AwwList first",
                        systemImage: "person.2.slash",
                        description: Text("Open the main app once so the Share Extension can safely mirror your people list.")
                    )
                } else {
                    peoplePicker
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: 560, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                addToAwwList()
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(isSaving ? "Adding…" : "Add")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isSaving || selectedIDs.isEmpty || people.isEmpty)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.bar)
        }
    }

    private var sharedPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shared from Safari")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(payload.displayText)
                .font(.body.weight(.medium))
                .lineLimit(5)
                .textSelection(.enabled)

            if let url = payload.url {
                Text(url.host() ?? url.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var peoplePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Save for")
                    .font(.headline)

                Spacer()

                Button(selectedIDs.count == people.count ? "Clear" : "Select all") {
                    if selectedIDs.count == people.count {
                        selectedIDs.removeAll()
                    } else {
                        selectedIDs = Set(people.map(\.id))
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)
            }

            HStack(spacing: 10) {
                ForEach(visiblePeople) { person in
                    personButton(person)
                }

                if people.count > visiblePeople.count {
                    Button {
                        showingAllPeople = true
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "ellipsis")
                                .font(.headline.weight(.semibold))
                                .frame(width: 48, height: 48)
                                .background(Color.primary.opacity(0.07), in: Circle())
                            Text("More")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func personButton(_ person: SharedAwwListBridge.PersonSnapshot) -> some View {
        let selected = selectedIDs.contains(person.id)

        return Button {
            if selected {
                selectedIDs.remove(person.id)
            } else {
                selectedIDs.insert(person.id)
            }
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    Text(person.emoji.isEmpty ? "🎁" : person.emoji)
                        .font(.title2)
                        .frame(width: 48, height: 48)
                        .background(Color.primary.opacity(0.06), in: Circle())
                        .scaleEffect(selected ? 1.06 : 1)

                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white, .red)
                            .background(Color.white, in: Circle())
                    }
                }

                Text(person.isOwner ? "You" : person.name)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: selected)
    }

    private var allPeopleSheet: some View {
        NavigationStack {
            List(people) { person in
                Button {
                    if selectedIDs.contains(person.id) {
                        selectedIDs.remove(person.id)
                    } else {
                        selectedIDs.insert(person.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(person.emoji.isEmpty ? "🎁" : person.emoji)
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(Color.primary.opacity(0.06), in: Circle())

                        Text(person.isOwner ? "You" : person.name)
                            .foregroundStyle(.primary)

                        Spacer()

                        if selectedIDs.contains(person.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("People")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingAllPeople = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var successState: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 54))
                .foregroundStyle(.red)

            VStack(spacing: 6) {
                Text("Added to AwwList")
                    .font(.title2.weight(.bold))
                Text("It is safely queued for the selected people.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Done") {
                extensionContext?.completeRequest(returningItems: nil)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addToAwwList() {
        isSaving = true
        errorMessage = nil

        let didQueue = SharedAwwListBridge.enqueue(
            text: payload.text,
            url: payload.url,
            recipientIDs: selectedIDs
        )

        isSaving = false
        if didQueue {
            withAnimation(.snappy(duration: 0.22)) {
                didSave = true
            }
        } else {
            errorMessage = "AwwList could not save this shared item. Your Safari page is unchanged. Check the App Group capability and try again."
        }
    }

    private func loadSharedPayload() async -> SharedPayload {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            return SharedPayload()
        }

        var result = SharedPayload()

        for item in items {
            for provider in item.attachments ?? [] {
                if result.url == nil,
                   provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
                   let url = await loadURL(from: provider) {
                    result.url = url
                }

                if result.text.isEmpty,
                   provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                   let text = await loadText(from: provider) {
                    result.text = text
                }
            }
        }

        if result.text.isEmpty, let attributed = items.first?.attributedContentText {
            result.text = attributed.string
        }

        return result
    }

    private func loadURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                } else if let nsURL = item as? NSURL {
                    continuation.resume(returning: nsURL as URL)
                } else if let data = item as? Data,
                          let string = String(data: data, encoding: .utf8),
                          let url = URL(string: string) {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func loadText(from provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
                if let text = item as? String {
                    continuation.resume(returning: text)
                } else if let text = item as? NSString {
                    continuation.resume(returning: text as String)
                } else if let data = item as? Data {
                    continuation.resume(returning: String(data: data, encoding: .utf8))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
