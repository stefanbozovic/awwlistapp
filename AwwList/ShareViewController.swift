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

    struct SharedAttachment: Codable, Hashable {
        let filename: String
        let contentType: String
        let kind: String
        let relativePath: String?
    }

    struct PendingShare: Codable, Identifiable {
        let id: UUID
        let text: String
        let note: String
        let urlString: String?
        let attachment: SharedAttachment?
        let recipientIDs: [UUID]
        let created: Date
    }

    private static let peopleKey = "AwwList.sharedPeople.v1"
    private static let pendingKey = "AwwList.pendingShares.v1"
    private static let appGroupID = "group.com.stefanbozovic.awwlist"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func people() -> [PersonSnapshot] {
        guard let data = defaults?.data(forKey: peopleKey),
              let people = try? JSONDecoder().decode([PersonSnapshot].self, from: data) else {
            return []
        }

        return people.sorted {
            $0.isOwner != $1.isOwner
                ? $0.isOwner
                : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    static func enqueue(
        text: String,
        note: String,
        url: URL?,
        attachment: SharedAttachment?,
        recipientIDs: Set<UUID>
    ) -> Bool {
        guard let defaults, !recipientIDs.isEmpty else { return false }

        var queue: [PendingShare] = []
        if let existing = defaults.data(forKey: pendingKey) {
            queue = (try? JSONDecoder().decode([PendingShare].self, from: existing)) ?? []
        }

        queue.append(
            PendingShare(
                id: UUID(),
                text: text,
                note: note,
                urlString: url?.absoluteString,
                attachment: attachment,
                recipientIDs: Array(recipientIDs),
                created: .now
            )
        )

        guard let encoded = try? JSONEncoder().encode(queue) else { return false }
        defaults.set(encoded, forKey: pendingKey)
        defaults.synchronize()
        return defaults.data(forKey: pendingKey) == encoded
    }

    static func persistFile(
        from sourceURL: URL,
        type: UTType
    ) -> SharedAttachment? {
        guard let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            return nil
        }

        let directory = container.appendingPathComponent("SharedAttachments", isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )

            let originalName = sourceURL.lastPathComponent.isEmpty
                ? "Shared file"
                : sourceURL.lastPathComponent
            let destinationName = "\(UUID().uuidString)-\(originalName)"
            let destination = directory.appendingPathComponent(destinationName)
            try FileManager.default.copyItem(at: sourceURL, to: destination)

            return SharedAttachment(
                filename: originalName,
                contentType: type.identifier,
                kind: type.conforms(to: .image) ? "image" : "file",
                relativePath: "SharedAttachments/\(destinationName)"
            )
        } catch {
            return nil
        }
    }

    static func image(for attachment: SharedAttachment) -> UIImage? {
        guard let relativePath = attachment.relativePath,
              let container = FileManager.default.containerURL(
                  forSecurityApplicationGroupIdentifier: appGroupID
              ),
              let data = try? Data(
                  contentsOf: container.appendingPathComponent(relativePath)
              ) else {
            return nil
        }
        return UIImage(data: data)
    }
}

private struct SharedPayload {
    var title = ""
    var url: URL?
    var attachment: SharedAwwListBridge.SharedAttachment?

    var displayTitle: String {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        if let attachment { return attachment.filename }
        return url?.absoluteString ?? "Shared item"
    }

    var isURLOnly: Bool {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return url != nil && (clean.isEmpty || clean == url?.absoluteString)
    }

    var savedTitle: String {
        if attachment?.kind == "image" {
            return "Shared image"
        }
        if isURLOnly {
            return "Shared link"
        }
        return displayTitle
    }

    var sourceLabel: String {
        if let attachment {
            return attachment.kind == "image" ? "Shared image" : "Shared file"
        }
        return url == nil ? "Shared item" : "Shared link"
    }
}

final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let host = UIHostingController(
            rootView: AwwListShareView(extensionContext: extensionContext)
        )
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
    @State private var note = ""
    @State private var people: [SharedAwwListBridge.PersonSnapshot] = []
    @State private var selectedIDs: Set<UUID> = []
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Preparing shared item…")
                } else {
                    composer
                }
            }
            .navigationTitle("Add to AwwList")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Adding…" : "Add", action: addToAwwList)
                        .fontWeight(.semibold)
                        .disabled(isSaving || selectedIDs.isEmpty)
                }
            }
        }
        .task {
            people = SharedAwwListBridge.people()
            payload = await loadSharedPayload()
            selectedIDs = Set(people.map(\.id))
            if let url = payload.url {
                note = url.absoluteString
            }
            isLoading = false
        }
        .alert(
            "Couldn’t add this item",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var composer: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                peoplePicker
                noteComposer
                attachmentPreview

            }
            .padding(20)
        }
    }

    private var noteComposer: some View {
        ZStack(alignment: .topLeading) {
            if note.isEmpty {
                Text("Start typing…")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $note)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 150)
                .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var attachmentPreview: some View {
        if let attachment = payload.attachment,
           attachment.kind == "image",
           let image = SharedAwwListBridge.image(for: attachment) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else if let attachment = payload.attachment {
            Label(attachment.filename, systemImage: "doc.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    @ViewBuilder
    private var peoplePicker: some View {
        if people.isEmpty {
            ContentUnavailableView(
                "Open AwwList first",
                systemImage: "person.2.slash",
                description: Text("Open the main app once, then try sharing again.")
            )
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Save for")
                        .font(.headline)

                    Spacer()

                    Button(
                        selectedIDs.count == people.count ? "Deselect all" : "Select all"
                    ) {
                        if selectedIDs.count == people.count {
                            selectedIDs.removeAll()
                        } else {
                            selectedIDs = Set(people.map(\.id))
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                }

                ScrollView(.horizontal) {
                    HStack(spacing: 14) {
                        ForEach(people) { person in
                            personButton(person)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func personButton(
        _ person: SharedAwwListBridge.PersonSnapshot
    ) -> some View {
        let isSelected = selectedIDs.contains(person.id)

        return Button {
            if isSelected {
                selectedIDs.remove(person.id)
            } else {
                selectedIDs.insert(person.id)
            }
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    Text(person.emoji.isEmpty ? "✨" : person.emoji)
                        .font(.title3)
                        .frame(width: 50, height: 50)
                        .background(
                            isSelected ? Color.red.opacity(0.16) : Color.primary.opacity(0.06),
                            in: Circle()
                        )
                        .overlay {
                            Circle()
                                .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
                        }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.white, .red)
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
        .accessibilityLabel(person.isOwner ? "You" : person.name)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var sharedPreview: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: payload.attachment?.kind == "image" ? "photo" : "square.and.arrow.down")
                .font(.title3)
                .foregroundStyle(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(payload.sourceLabel.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(payload.displayTitle)
                    .font(.body.weight(.medium))
                    .lineLimit(3)
                if let url = payload.url {
                    Text(url.host() ?? url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            Color.primary.opacity(0.055),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private func addToAwwList() {
        isSaving = true
        let didQueue = SharedAwwListBridge.enqueue(
            text: payload.savedTitle,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            url: payload.url,
            attachment: payload.attachment,
            recipientIDs: selectedIDs
        )
        isSaving = false

        if didQueue {
            extensionContext?.completeRequest(returningItems: nil)
        } else {
            errorMessage = "AwwList couldn’t save this shared item. Please check that the app and extension both have the App Group capability."
        }
    }

    private func cancel() {
        extensionContext?.cancelRequest(
            withError: NSError(
                domain: "AwwList.ShareExtension",
                code: NSUserCancelledError
            )
        )
    }

    private func loadSharedPayload() async -> SharedPayload {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            return SharedPayload()
        }

        var result = SharedPayload()
        for item in items {
            if result.title.isEmpty, let title = item.attributedTitle?.string {
                result.title = title
            }

            for provider in item.attachments ?? [] {
                if result.url == nil,
                   provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
                   let url = await loadURL(from: provider) {
                    result.url = url
                }

                if result.title.isEmpty,
                   provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                   let text = await loadText(from: provider) {
                    result.title = text
                }

                if result.attachment == nil,
                   let attachment = await loadAttachment(from: provider) {
                    result.attachment = attachment
                }
            }

            if result.title.isEmpty, let content = item.attributedContentText?.string {
                result.title = content
            }
        }
        return result
    }

    private func loadURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                } else if let url = item as? NSURL {
                    continuation.resume(returning: url as URL)
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
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func loadAttachment(
        from provider: NSItemProvider
    ) async -> SharedAwwListBridge.SharedAttachment? {
        guard let identifier = provider.registeredTypeIdentifiers.first(where: {
            guard let type = UTType($0) else { return false }
            return !type.conforms(to: .url) && !type.conforms(to: .plainText)
        }), let type = UTType(identifier) else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: identifier) { url, _ in
                guard let url else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(
                    returning: SharedAwwListBridge.persistFile(from: url, type: type)
                )
            }
        }
    }
}

private struct PeoplePickerSheet: View {
    let people: [SharedAwwListBridge.PersonSnapshot]
    @Binding var selectedIDs: Set<UUID>
    let onDone: () -> Void

    var body: some View {
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
                        Text(person.emoji.isEmpty ? "✨" : person.emoji)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(Color.primary.opacity(0.06), in: Circle())
                        Text(person.isOwner ? "You" : person.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(
                            systemName: selectedIDs.contains(person.id)
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .foregroundStyle(
                            selectedIDs.contains(person.id)
                                ? Color.red
                                : Color.secondary.opacity(0.45)
                        )
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Choose people")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") { selectedIDs.removeAll() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
