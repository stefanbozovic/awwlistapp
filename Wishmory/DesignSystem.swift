// FULL UPDATED BUILD: 2026-08-30 23:32 Europe/Belgrade
import SwiftUI
import Foundation
import ImageIO
import SwiftData
import UIKit
import PhotosUI
import UniformTypeIdentifiers
import LinkPresentation



// MARK: - Image performance

final class AwwImageCache {
    static let shared = AwwImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.totalCostLimit = 64 * 1024 * 1024
        cache.countLimit = 240
    }

    func image(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard !data.isEmpty else { return nil }

        let key = "\(data.count)-\(data.hashValue)-\(Int(maxPixelSize))" as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        var decodedImage: UIImage?

        if let source = CGImageSourceCreateWithData(
            data as CFData,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ) {
            let options: CFDictionary = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary

            if let cgImage = CGImageSourceCreateThumbnailAtIndex(
                source,
                0,
                options
            ) {
                decodedImage = UIImage(cgImage: cgImage)
            }
        }

        // Older local images can still decode through UIImage even when
        // ImageIO cannot create a thumbnail directly.
        if decodedImage == nil,
           let fullImage = UIImage(data: data) {
            let dimension = max(fullImage.size.width, fullImage.size.height)

            if dimension > maxPixelSize, dimension > 0 {
                let scale = maxPixelSize / dimension
                let target = CGSize(
                    width: max(1, fullImage.size.width * scale),
                    height: max(1, fullImage.size.height * scale)
                )
                decodedImage = fullImage.preparingThumbnail(of: target) ?? fullImage
            } else {
                decodedImage = fullImage
            }
        }

        guard let image = decodedImage else {
            return nil
        }

        let pixelWidth = max(1, Int(image.size.width * image.scale))
        let pixelHeight = max(1, Int(image.size.height * image.scale))
        cache.setObject(
            image,
            forKey: key,
            cost: pixelWidth * pixelHeight * 4
        )
        return image
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}

struct AwwDataImage: View {
    let data: Data
    let maxPixelSize: CGFloat

    var body: some View {
        Group {
            if let image = AwwImageCache.shared.image(
                from: data,
                maxPixelSize: maxPixelSize
            ) {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .fill(Color.primary.opacity(0.05))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.tertiary)
                    }
            }
        }
    }
}


// MARK: - Top Gradient

struct TopPageGradient: View {
    var body: some View {
        ZStack {
            // Deep cherry base
            RadialGradient(
                colors: [
                    Color(red: 0.72, green: 0.08, blue: 0.10).opacity(0.30),
                    Color(red: 0.55, green: 0.04, blue: 0.07).opacity(0.12),
                    .clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 360
            )

            // Warm red / orange light
            RadialGradient(
                colors: [
                    Color(red: 0.95, green: 0.22, blue: 0.10).opacity(0.18),
                    Color(red: 0.82, green: 0.10, blue: 0.06).opacity(0.08),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 300
            )

            // Fade everything naturally into the page
            LinearGradient(
                colors: [
                    .clear,
                    Color(.systemBackground).opacity(0.10),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .ignoresSafeArea(edges: [.top, .horizontal])
    }
}


// MARK: - Floating Action

struct FloatingComposer: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        let button = Button(
            action: action
        ) {
            Label(
                title,
                systemImage: symbol
            )
            .font(
                .headline
                    .weight(.semibold)
            )
            .padding(
                .horizontal,
                12
            )
            .padding(
                .vertical,
                5
            )
        }

        button
            .buttonStyle(.glassProminent)
            .tint(.red)
            .controlSize(.large)
    }
}


// MARK: - Inline Wish Composer

struct InlineWishComposer: View {
    let people: [Person]
    let onFocusChange: (Bool) -> Void

    @Binding private var selectedPersonIDs: Set<UUID>
    @Binding private var requestFocus: Bool

    @Environment(\.modelContext)
    private var context

    @Query
    private var ideas: [Idea]

    @Query(sort: \Category.name)
    private var categoryRecords: [Category]

    @State private var title = ""
    @State private var category = ""
    @State private var status = "Would love"
    @State private var cardColor = WishCardPalette.defaultID
    @State private var imageData: Data?
    @State private var imageAttachments: [Data] = []
    @State private var fileAttachments: [ImportedAttachment] = []
    @State private var linkAttachments: [URL] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingPhotoPicker = false
    @State private var showingFileImporter = false
    @State private var showingCamera = false
    @State private var isDropTarget = false
    @State private var isTitleFocused = false
    @State private var focusRequestID = 0
    @State private var didRestoreDraft = false
    @State private var draftSaveTask: Task<Void, Never>?

    init(person: Person) {
        people = [person]
        _selectedPersonIDs = .constant([person.id])
        _requestFocus = .constant(false)
        onFocusChange = { _ in }
    }

    init(
        people: [Person],
        selectedPersonIDs: Binding<Set<UUID>>,
        requestFocus: Binding<Bool> = .constant(false),
        onFocusChange: @escaping (Bool) -> Void = { _ in }
    ) {
        self.people = people
        _selectedPersonIDs = selectedPersonIDs
        _requestFocus = requestFocus
        self.onFocusChange = onFocusChange
    }

    private var defaultCategories: [String] {
        let ownerID = AwwIdentityCache.userID
        let active = categoryRecords.filter {
            $0.deletedAt == nil
            && (ownerID == nil || $0.ownerUserID == ownerID)
        }
        let names = active.map(\.name)
        return names.isEmpty ? AwwCategoryPreferences.visibleDefaults : names
    }

    private let statuses = ["Would love", "Most wanted", "Given"]

    private var hashtagQuery: String? {
        currentHashtagQuery(in: title)
    }

    private var suggestedCategories: [String] {
        guard let hashtagQuery else { return [] }

        let categories = uniqueCategoryValues(
            defaultCategories
            + ideas.flatMap { categoryValues(from: $0.category) }
        )

        if hashtagQuery.isEmpty {
            return Array(categories.sorted().prefix(6))
        }

        return categories
            .filter { $0.localizedCaseInsensitiveContains(hashtagQuery) }
            .sorted()
            .prefix(6)
            .map { $0 }
    }

    private var hasAttachments: Bool {
        !imageAttachments.isEmpty || !fileAttachments.isEmpty || !linkAttachments.isEmpty
    }

    private var hasAnythingToSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hasAttachments
    }

    var body: some View {
        GlassEffectContainer {
            VStack(alignment: .leading, spacing: isTitleFocused ? 10 : 0) {
                if hasAttachments {
                    attachmentStrip
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                HStack(alignment: .center, spacing: 10) {
                    plusMenu
                        .frame(width: isTitleFocused ? 0 : 32)
                        .opacity(isTitleFocused ? 0 : 1)
                        .clipped()
                        .allowsHitTesting(!isTitleFocused)

                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            ShimmeringComposerPrompt(
                                text: "Add a gift idea… #category"
                            )
                            .allowsHitTesting(false)
                        }

                        LinkAwareTextView(
                            text: $title,
                            focusRequest: focusRequestID,
                            onFocusChange: composerFocusChanged,
                            font: .preferredFont(forTextStyle: .body),
                            minHeight: 28,
                            maxHeight: isTitleFocused ? 96 : 44
                        )
                    }
                    .padding(.horizontal, isTitleFocused ? 4 : 0)

                    saveButton
                        .frame(width: isTitleFocused ? 0 : 44)
                        .opacity(isTitleFocused ? 0 : 1)
                        .clipped()
                        .allowsHitTesting(!isTitleFocused)
                }
                .frame(minHeight: isTitleFocused ? 32 : 44)

                if isTitleFocused {
                    if !suggestedCategories.isEmpty {
                        categorySuggestions
                    }

                    HStack(alignment: .center, spacing: 10) {
                        plusMenu
                        Spacer(minLength: 0)
                        saveButton
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, isTitleFocused || hasAttachments ? 12 : 6)
            .frame(height: isTitleFocused || hasAttachments ? nil : 56)
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        isDropTarget
                            ? Color.red.opacity(0.78)
                            : isTitleFocused
                                ? Color.red.opacity(0.15)
                                : Color.red.opacity(0.20),
                        lineWidth: isTitleFocused ? 1.2 : 0.9
                    )
                    .allowsHitTesting(false)
            }
            .background {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color(uiColor: .systemBackground).opacity(0.26))
            }
            .compositingGroup()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 30))
            .shadow(
                color: Color.black.opacity(0.16),
                radius: 30,
                x: 0,
                y: 14
            )
            .shadow(
                color: Color.black.opacity(0.06),
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .animation(.snappy(duration: 0.22), value: isTitleFocused)
        .animation(.snappy(duration: 0.22), value: hasAttachments)
        .onChange(of: requestFocus) { _, shouldFocus in
            guard shouldFocus else { return }
            focusRequestID &+= 1
            requestFocus = false
        }
        .onDrop(
            of: [
                UTType.image.identifier,
                UTType.fileURL.identifier,
                UTType.url.identifier,
                UTType.plainText.identifier,
                UTType.data.identifier
            ],
            isTargeted: $isDropTarget,
            perform: importDroppedItems
        )
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .images
        )
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            importFiles(result)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(imageData: $imageData)
                .ignoresSafeArea()
        }
        .onChange(of: selectedPhotos) { _, photos in
            Task { await importPhotos(photos) }
        }
        .onChange(of: imageData) { _, newImageData in
            if let newImageData, !imageAttachments.contains(newImageData) {
                imageAttachments.append(newImageData)
                AwwHaptics.soft()
                scheduleDraftSave()
            }
        }
        .onChange(of: title) { _, newTitle in
            category = encodedCategoryValues(
                hashtagCategoryValues(in: newTitle)
            )
            addDetectedLinks(from: newTitle)
            scheduleDraftSave()
        }
        .onChange(of: selectedPersonIDs) { _, _ in
            scheduleDraftSave()
        }
        .onChange(of: status) { _, _ in
            scheduleDraftSave()
        }
        .onAppear {
            restoreDraftIfNeeded()
        }
        .onDisappear {
            draftSaveTask?.cancel()
            saveDraftNow()
        }
    }

    private func composerFocusChanged(_ focused: Bool) {
        guard isTitleFocused != focused else { return }
        isTitleFocused = focused
        onFocusChange(focused)
    }

    private var attachmentStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(Array(imageAttachments.enumerated()), id: \.offset) { index, data in
                    photoThumbnail(data) {
                        imageAttachments.remove(at: index)
                    }
                }

                ForEach(fileAttachments) { attachment in
                    fileThumbnail(attachment) {
                        fileAttachments.removeAll { $0.id == attachment.id }
                    }
                }

                ForEach(linkAttachments, id: \.absoluteString) { link in
                    linkThumbnail(link) {
                        linkAttachments.removeAll { $0 == link }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.trailing, 2)
        }
        .contentMargins(.horizontal, 2)
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
    }

    private func photoThumbnail(
        _ data: Data,
        remove: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            AwwDataImage(
                data: data,
                maxPixelSize: 420
            )
            .scaledToFill()
            .frame(width: 132, height: 104)
            .clipped()
            .clipShape(.rect(cornerRadius: 14))

            thumbnailRemoveButton(remove)
                .padding(6)
        }
        .frame(width: 132, height: 104)
        .contentShape(.rect(cornerRadius: 14))
    }

    private func fileThumbnail(
        _ attachment: ImportedAttachment,
        remove: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.055))
                .frame(width: 132, height: 104)
                .overlay(alignment: .center) {
                    VStack(spacing: 8) {
                        Image(systemName: attachmentSymbol(for: attachment.contentType))
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text(attachment.filename)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .padding(.top, 4)
                }

            thumbnailRemoveButton(remove)
                .padding(6)
        }
        .frame(width: 132, height: 104)
    }

    private func linkThumbnail(
        _ url: URL,
        remove: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RichLinkPreview(url: url, compact: true)
                .frame(width: 174, height: 104)
                .clipShape(.rect(cornerRadius: 14))

            thumbnailRemoveButton(remove)
                .padding(6)
        }
        .frame(width: 174, height: 104)
    }

    private func thumbnailRemoveButton(
        _ remove: @escaping () -> Void
    ) -> some View {
        Button(action: remove) {
            Image(systemName: "xmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 26, height: 26)
                .background(.ultraThinMaterial, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove attachment")
    }

    private var plusMenu: some View {
        Menu {
            // iOS renders this menu from the bottom of the declaration upward.
            // Keep Status first in source so the visible menu ends with Status.
            Menu("Status", systemImage: "gift.fill") {
                ForEach(statuses, id: \.self) { option in
                    Button {
                        status = option
                        AwwHaptics.selection()
                    } label: {
                        if status == option {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            }

            Menu("Card color", systemImage: "paintpalette") {
                ForEach(WishCardPalette.allCases) { palette in
                    Button {
                        cardColor = palette.id
                        AwwHaptics.selection()
                    } label: {
                        if cardColor == palette.id {
                            Label(palette.title, systemImage: "checkmark")
                        } else {
                            Text(palette.title)
                        }
                    }
                }
            }

            Divider()

            Button("Paste from Clipboard", systemImage: "doc.on.clipboard") {
                pasteFromClipboard()
            }

            Button("Choose Files", systemImage: "folder") {
                presentFileImporter()
            }

            Button("Choose Photo", systemImage: "photo.on.rectangle") {
                presentPhotoPicker()
            }

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo", systemImage: "camera") {
                    presentCamera()
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.primary)
                .frame(width: 32, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .tint(.primary)
        .accessibilityLabel("Add content")
    }

    private func presentCamera() {
        presentMediaPicker { showingCamera = true }
    }

    private func presentPhotoPicker() {
        presentMediaPicker { showingPhotoPicker = true }
    }

    private func presentFileImporter() {
        presentMediaPicker { showingFileImporter = true }
    }

    private func presentMediaPicker(
        _ presentation: @escaping () -> Void
    ) {
        // Let the candidate bar finish dismissing before UIKit hides this text view.
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        DispatchQueue.main.async {
            presentation()
        }
    }

    private var saveButton: some View {
        Button(action: save) {
            Label("Save wish", systemImage: "arrow.up")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.glassProminent)
        .tint(.red)
        .accessibilityLabel("Save wish")
        .opacity(hasAnythingToSave ? 1 : 0.82)
    }

    private var categorySuggestions: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Image(systemName: "number")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)

                ForEach(suggestedCategories, id: \.self) { suggestion in
                    Button("#\(suggestion)") {
                        AwwHaptics.light()
                        title = replacingCurrentHashtag(in: title, with: suggestion)
                        category = encodedCategoryValues(
                            hashtagCategoryValues(in: title)
                        )
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.red)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func save() {
        let trimmedText = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let recipients = people.filter { selectedPersonIDs.contains($0.id) }

        guard !recipients.isEmpty, !trimmedText.isEmpty || hasAttachments else {
            focusRequestID &+= 1
            return
        }

        for person in recipients {
            let idea = Idea(
                trimmedText,
                category: category,
                status: status,
                person: person,
                personIDs: [person.id],
                cardColor: cardColor,
                ownerUserID: AwwIdentityCache.userID
            )

            try? AwwCategoryStore.assign(
                names: categoryValues(from: category),
                to: idea,
                context: context
            )

            var creationOffset: TimeInterval = 0
            func nextCreated() -> Date {
                defer { creationOffset += 0.001 }
                return Date.now.addingTimeInterval(creationOffset)
            }

            for imageData in imageAttachments {
                let attachment = IdeaAttachment(
                    filename: "Photo",
                    contentType: UTType.image.identifier,
                    kind: "image",
                    data: imageData,
                    idea: idea
                )
                attachment.created = nextCreated()
                context.insert(attachment)
            }

            for file in fileAttachments {
                let attachment = IdeaAttachment(
                    filename: file.filename,
                    contentType: file.contentType,
                    kind: "file",
                    data: file.data,
                    idea: idea
                )
                attachment.created = nextCreated()
                context.insert(attachment)
            }

            for link in linkAttachments {
                let attachment = IdeaAttachment(
                    filename: link.host() ?? link.absoluteString,
                    contentType: UTType.url.identifier,
                    kind: "link",
                    linkURL: link.absoluteString,
                    idea: idea
                )
                attachment.created = nextCreated()
                context.insert(attachment)
            }

            context.insert(idea)
        }

        guard AwwPersistence.save(context) else {
            AwwHaptics.warning()
            saveDraftNow()
            return
        }

        let savedIDs = recipients.map(\.id)
        let savedNames = recipients.map(\.name)

        withAnimation(.snappy(duration: 0.22)) {
            title = ""
            category = ""
            status = "Would love"
            cardColor = WishCardPalette.defaultID
            imageData = nil
            imageAttachments.removeAll()
            fileAttachments.removeAll()
            linkAttachments.removeAll()
            selectedPhotos.removeAll()
        }

        draftSaveTask?.cancel()
        AwwDraftStore.clear()

        NotificationCenter.default.post(
            name: .awwWishSaved,
            object: savedIDs,
            userInfo: ["names": savedNames]
        )

        AwwHaptics.success()
    }

    private func importDroppedItems(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    guard let data else { return }
                    DispatchQueue.main.async { addImageAttachment(data) }
                }
                continue
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                provider.loadObject(ofClass: NSURL.self) { object, _ in
                    guard let url = object as? URL else { return }
                    DispatchQueue.main.async { addDroppedURL(url, insertIntoText: true) }
                }
                continue
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                provider.loadObject(ofClass: NSString.self) { object, _ in
                    guard let text = object as? String else { return }
                    DispatchQueue.main.async { addDroppedText(text) }
                }
                continue
            }

            provider.loadFileRepresentation(forTypeIdentifier: UTType.data.identifier) { url, _ in
                guard let url, let data = try? Data(contentsOf: url) else { return }
                let filename = provider.suggestedName ?? "File"
                let contentType = UTType(filenameExtension: url.pathExtension)?.identifier
                    ?? UTType.data.identifier
                DispatchQueue.main.async {
                    addFileAttachment(data, filename: filename, contentType: contentType)
                }
            }
        }

        return !providers.isEmpty
    }

    private func pasteFromClipboard() {
        let pasteboard = UIPasteboard.general

        if let url = pasteboard.url, isHTTPURL(url) {
            addDroppedURL(url, insertIntoText: true)
            return
        }

        if let string = pasteboard.string {
            let urls = detectedHTTPURLs(in: string)
            if !urls.isEmpty {
                title += title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? string
                    : "\n\(string)"
                urls.forEach(addLinkAttachment)
                focusRequestID &+= 1
                return
            }
        }

        if let image = pasteboard.image,
           let data = image.jpegData(compressionQuality: 0.85) {
            addImageAttachment(data)
            return
        }

        if let string = pasteboard.string {
            addDroppedText(string)
        }
    }

    private func addDroppedText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        title += title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? trimmedText
            : "\n\(trimmedText)"

        detectedHTTPURLs(in: trimmedText).forEach(addLinkAttachment)
        focusRequestID &+= 1
    }

    private func addDroppedURL(_ url: URL, insertIntoText: Bool) {
        guard isHTTPURL(url) else { return }
        addLinkAttachment(url)

        if insertIntoText, !title.contains(url.absoluteString) {
            title += title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? url.absoluteString
                : "\n\(url.absoluteString)"
        }

        focusRequestID &+= 1
    }

    private func addDetectedLinks(from text: String) {
        detectedHTTPURLs(in: text).forEach(addLinkAttachment)
    }

    private func addLinkAttachment(_ url: URL) {
        guard isHTTPURL(url), !linkAttachments.contains(url) else { return }
        linkAttachments.append(url)
        AwwHaptics.soft()
        scheduleDraftSave()
    }

    private func addImageAttachment(_ data: Data) {
        guard !imageAttachments.contains(data) else { return }
        imageAttachments.append(data)
        AwwHaptics.soft()
        focusRequestID &+= 1
        scheduleDraftSave()
    }

    private func addFileAttachment(
        _ data: Data,
        filename: String,
        contentType: String
    ) {
        let attachment = ImportedAttachment(
            filename: filename,
            contentType: contentType,
            data: data
        )
        guard !fileAttachments.contains(attachment) else { return }
        fileAttachments.append(attachment)
        focusRequestID &+= 1
        scheduleDraftSave()
    }

    private func importPhotos(_ photos: [PhotosPickerItem]) async {
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self),
                  !imageAttachments.contains(data) else { continue }
            imageAttachments.append(data)
            AwwHaptics.soft()
        }
        scheduleDraftSave()
    }

    private func importFiles(_ result: Result<[URL], any Error>) {
        guard case .success(let urls) = result else { return }

        for url in urls {
            let grantedAccess = url.startAccessingSecurityScopedResource()
            defer {
                if grantedAccess { url.stopAccessingSecurityScopedResource() }
            }

            guard let data = try? Data(contentsOf: url) else { continue }
            let contentType = UTType(filenameExtension: url.pathExtension)?.identifier
                ?? UTType.data.identifier
            let attachment = ImportedAttachment(
                filename: url.lastPathComponent,
                contentType: contentType,
                data: data
            )
            if !fileAttachments.contains(attachment) {
                fileAttachments.append(attachment)
            }
        }
        scheduleDraftSave()
    }

    private func restoreDraftIfNeeded() {
        guard !didRestoreDraft else { return }
        didRestoreDraft = true

        guard let draft = AwwDraftStore.load() else { return }

        let availableIDs = Set(people.map(\.id))
        let restoredIDs = Set(draft.selectedPersonIDs).intersection(availableIDs)

        // A person-specific composer should never restore a draft for another person.
        if people.count == 1, let onlyPerson = people.first,
           !draft.selectedPersonIDs.isEmpty,
           !draft.selectedPersonIDs.contains(onlyPerson.id) {
            return
        }

        title = draft.title
        category = draft.category
        status = draft.status
        imageAttachments = draft.images
        fileAttachments = draft.files
        linkAttachments = draft.links.compactMap(URL.init(string:))

        if !restoredIDs.isEmpty {
            selectedPersonIDs = restoredIDs
        }
    }

    private func scheduleDraftSave() {
        guard didRestoreDraft else { return }

        draftSaveTask?.cancel()
        draftSaveTask = Task {
            try? await Task.sleep(for: .milliseconds(320))
            guard !Task.isCancelled else { return }
            saveDraftNow()
        }
    }

    private func saveDraftNow() {
        guard didRestoreDraft else { return }

        if !hasAnythingToSave {
            AwwDraftStore.clear()
            return
        }

        AwwDraftStore.save(
            AwwComposerDraft(
                title: title,
                category: category,
                status: status,
                selectedPersonIDs: Array(selectedPersonIDs),
                images: imageAttachments,
                files: fileAttachments,
                links: linkAttachments.map(\.absoluteString)
            )
        )
    }

    private func attachmentSymbol(for contentType: String) -> String {
        guard let type = UTType(contentType) else { return "doc" }
        if type.conforms(to: .pdf) { return "doc.richtext" }
        if type.conforms(to: .audio) { return "waveform" }
        if type.conforms(to: .movie) { return "play.rectangle" }
        if type.conforms(to: .archive) { return "archivebox" }
        return "doc"
    }
}


private struct ImportedAttachment: Identifiable, Equatable, Codable {
    let id: UUID
    let filename: String
    let contentType: String
    let data: Data

    init(
        id: UUID = UUID(),
        filename: String,
        contentType: String,
        data: Data
    ) {
        self.id = id
        self.filename = filename
        self.contentType = contentType
        self.data = data
    }
}

private struct AwwComposerDraft: Codable {
    let title: String
    let category: String
    let status: String
    let selectedPersonIDs: [UUID]
    let images: [Data]
    let files: [ImportedAttachment]
    let links: [String]
}

private enum AwwDraftStore {
    private static var fileURL: URL? {
        guard let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        let folder = base.appendingPathComponent(
            "AwwList",
            isDirectory: true
        )

        do {
            try FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )
        } catch {
            return nil
        }

        return folder.appendingPathComponent("composer-draft.json")
    }

    static func save(_ draft: AwwComposerDraft) {
        guard let fileURL else { return }

        do {
            let data = try JSONEncoder().encode(draft)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            UserDefaults.standard.set(
                String(describing: error),
                forKey: "lastDraftSaveError"
            )
        }
    }

    static func load() -> AwwComposerDraft? {
        guard
            let fileURL,
            let data = try? Data(contentsOf: fileURL)
        else {
            return nil
        }

        return try? JSONDecoder().decode(
            AwwComposerDraft.self,
            from: data
        )
    }

    static func clear() {
        guard let fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}



func isHTTPURL(_ url: URL) -> Bool {
    guard
        let scheme = url.scheme?.lowercased()
    else {
        return false
    }

    return scheme == "http"
        || scheme == "https"
}


func detectedHTTPURLs(
    in text: String
) -> [URL] {
    guard
        !text.isEmpty,
        let detector =
            try? NSDataDetector(
                types:
                    NSTextCheckingResult
                        .CheckingType
                        .link
                        .rawValue
            )
    else {
        return []
    }

    let range = NSRange(
        text.startIndex...,
        in: text
    )

    var seen =
        Set<String>()

    return detector
        .matches(
            in: text,
            options: [],
            range: range
        )
        .compactMap(\.url)
        .filter(isHTTPURL)
        .filter {
            seen.insert(
                $0.absoluteString
            ).inserted
        }
}


func currentHashtagQuery(in text: String) -> String? {
    guard let token = text
        .split(whereSeparator: { $0.isWhitespace })
        .last,
          token.hasPrefix("#") else {
        return nil
    }

    return String(token.dropFirst())
        .trimmingCharacters(in: .punctuationCharacters)
}


func lastHashtagCategory(in text: String) -> String? {
    guard let regex = try? NSRegularExpression(
        pattern: #"#([\p{L}\p{N}_-]+)"#
    ) else { return nil }

    let range = NSRange(text.startIndex..., in: text)
    guard let match = regex.matches(in: text, range: range).last,
          let categoryRange = Range(match.range(at: 1), in: text) else {
        return nil
    }

    let value = String(text[categoryRange])
    return value.isEmpty ? nil : value
}


func replacingCurrentHashtag(
    in text: String,
    with category: String
) -> String {
    guard let tokenRange = text.range(
        of: #"#[^\s]*$"#,
        options: .regularExpression
    ) else {
        return text + (text.isEmpty ? "" : " ") + "#\(category) "
    }

    var result = text
    result.replaceSubrange(tokenRange, with: "#\(category) ")
    return result
}


func removingCurrentHashtag(
    in text: String
) -> String {
    guard let tokenRange = text.range(
        of: #"#[^\s]*$"#,
        options: .regularExpression
    ) else {
        return text
    }

    var result = text
    result.removeSubrange(tokenRange)
    return result
}


func uniqueCategoryValues(_ values: [String]) -> [String] {
    var seen = Set<String>()
    var result: [String] = []

    for value in values {
        let cleaned = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)

        guard !cleaned.isEmpty else { continue }

        let key = cleaned.lowercased()
        guard seen.insert(key).inserted else { continue }
        result.append(cleaned)
    }

    return result
}


func categoryValues(from storedValue: String) -> [String] {
    uniqueCategoryValues(
        storedValue
            .split(separator: "|", omittingEmptySubsequences: true)
            .map(String.init)
    )
}


func encodedCategoryValues(_ values: [String]) -> String {
    uniqueCategoryValues(values).joined(separator: "|")
}


func hashtagCategoryValues(in text: String) -> [String] {
    guard let regex = try? NSRegularExpression(
        pattern: #"#([\p{L}\p{N}_-]+)"#
    ) else {
        return []
    }

    let range = NSRange(text.startIndex..., in: text)
    let values = regex.matches(in: text, range: range).compactMap { match -> String? in
        guard let categoryRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[categoryRange])
    }

    return uniqueCategoryValues(values)
}


func displayTextWithoutCategoryHashtags(
    _ text: String
) -> String {
    guard
        let regex = try? NSRegularExpression(
            pattern: #"(?<!\S)#[\p{L}\p{N}_-]+"#
        )
    else {
        return text
    }

    let nsRange = NSRange(
        text.startIndex...,
        in: text
    )

    let cleaned = regex.stringByReplacingMatches(
        in: text,
        options: [],
        range: nsRange,
        withTemplate: ""
    )

    return cleaned
        .replacingOccurrences(
            of: #"[ \t]+\n"#,
            with: "\n",
            options: .regularExpression
        )
        .replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
}


func categoryValue(
    _ storedValue: String,
    contains category: String
) -> Bool {
    categoryValues(from: storedValue).contains {
        $0.localizedCaseInsensitiveCompare(category) == .orderedSame
    }
}


struct LinkAwareTextView: UIViewRepresentable {
    @Binding var text: String
    let focusRequest: Int
    let onFocusChange: (Bool) -> Void
    let onHashtagTap: (String) -> Void
    let font: UIFont
    let minHeight: CGFloat
    let maxHeight: CGFloat

    init(
        text: Binding<String>,
        focusRequest: Int,
        onFocusChange: @escaping (Bool) -> Void,
        onHashtagTap: @escaping (String) -> Void = { _ in },
        font: UIFont,
        minHeight: CGFloat,
        maxHeight: CGFloat
    ) {
        _text = text
        self.focusRequest = focusRequest
        self.onFocusChange = onFocusChange
        self.onHashtagTap = onHashtagTap
        self.font = font
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.adjustsFontForContentSizeCategory = true
        textView.keyboardDismissMode = .interactive
        textView.autocorrectionType = .yes
        textView.smartDashesType = .yes
        textView.smartQuotesType = .yes
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.text = text

        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        applyStyling(to: textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self

        if textView.text != text {
            let selection = textView.selectedRange
            textView.text = text
            applyStyling(to: textView)
            let location = min(selection.location, textView.textStorage.length)
            textView.selectedRange = NSRange(location: location, length: 0)
        } else {
            applyStyling(to: textView)
        }

        let fittingHeight = textView.sizeThatFits(
            CGSize(
                width: max(textView.bounds.width, 1),
                height: .greatestFiniteMagnitude
            )
        ).height
        let shouldScroll = fittingHeight > maxHeight + 1

        if textView.isScrollEnabled != shouldScroll {
            textView.isScrollEnabled = shouldScroll
        }

        if shouldScroll, textView.isFirstResponder {
            textView.scrollRangeToVisible(textView.selectedRange)
        }

        if focusRequest > 0,
           context.coordinator.lastHandledFocusRequest != focusRequest {
            context.coordinator.lastHandledFocusRequest = focusRequest
            DispatchQueue.main.async {
                guard !textView.isFirstResponder else { return }
                textView.becomeFirstResponder()
            }
        }
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UITextView,
        context: Context
    ) -> CGSize? {
        let width = proposal.width ?? 280
        let fitting = uiView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )
        return CGSize(
            width: width,
            height: min(max(fitting.height, minHeight), maxHeight)
        )
    }

    fileprivate func applyStyling(to textView: UITextView) {
        let fullRange = NSRange(location: 0, length: textView.textStorage.length)
        guard fullRange.length >= 0 else { return }

        textView.textStorage.beginEditing()
        textView.textStorage.setAttributes(
            [
                .font: font,
                .foregroundColor: UIColor.label
            ],
            range: fullRange
        )

        if let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) {
            for match in detector.matches(in: textView.text, range: fullRange) {
                guard let url = match.url, isHTTPURL(url) else { continue }
                textView.textStorage.addAttribute(
                    .foregroundColor,
                    value: UIColor.systemRed,
                    range: match.range
                )
            }
        }

        if let hashtagRegex = try? NSRegularExpression(
            pattern: #"#[\p{L}\p{N}_-]+"#
        ) {
            for match in hashtagRegex.matches(in: textView.text, range: fullRange) {
                textView.textStorage.addAttribute(
                    .foregroundColor,
                    value: UIColor.systemRed,
                    range: match.range
                )
            }
        }

        textView.textStorage.endEditing()
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: UIColor.label
        ]
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: LinkAwareTextView
        var lastHandledFocusRequest = 0

        init(parent: LinkAwareTextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocusChange(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onFocusChange(false)
        }

        func textViewDidChange(
            _ textView: UITextView
        ) {
            parent.text = textView.text
            parent.applyStyling(
                to: textView
            )
        }

        @objc
        func handleHashtagTap(
            _ recognizer:
                UITapGestureRecognizer
        ) {
            guard
                recognizer.state == .ended,
                let textView =
                    recognizer.view
                    as? UITextView,
                !textView.text.isEmpty
            else {
                return
            }

            var point =
                recognizer.location(
                    in: textView
                )

            point.x -=
                textView
                    .textContainerInset
                    .left
            point.y -=
                textView
                    .textContainerInset
                    .top

            let glyphIndex =
                textView
                    .layoutManager
                    .glyphIndex(
                        for: point,
                        in:
                            textView
                                .textContainer
                    )

            guard
                glyphIndex
                    < textView
                        .layoutManager
                        .numberOfGlyphs
            else {
                return
            }

            let characterIndex =
                textView
                    .layoutManager
                    .characterIndexForGlyph(
                        at: glyphIndex
                    )

            guard
                let regex =
                    try? NSRegularExpression(
                        pattern:
                            #"#([\p{L}\p{N}_-]+)"#
                    )
            else {
                return
            }

            let fullRange =
                NSRange(
                    location: 0,
                    length:
                        textView
                            .textStorage
                            .length
                )

            guard
                let match =
                    regex
                        .matches(
                            in:
                                textView.text,
                            range:
                                fullRange
                        )
                        .first(
                            where: {
                                NSLocationInRange(
                                    characterIndex,
                                    $0.range
                                )
                            }
                        ),
                let categoryRange =
                    Range(
                        match.range(
                            at: 1
                        ),
                        in:
                            textView.text
                    )
            else {
                return
            }

            let category =
                String(
                    textView
                        .text[
                            categoryRange
                        ]
                )

            guard
                !category.isEmpty
            else {
                return
            }

            parent.onHashtagTap(
                category
            )
        }
    }
}


private final class
    LinkPreviewMetadataCache {
    static let shared =
        NSCache<
            NSURL,
            LPLinkMetadata
        >()
}


struct RichLinkPreview:
    UIViewRepresentable {
    let url: URL
    var compact = false

    func makeCoordinator()
        -> Coordinator {
        Coordinator()
    }

    func makeUIView(
        context: Context
    ) -> LPLinkView {
        let linkView =
            LPLinkView(url: url)

        loadMetadata(
            into: linkView,
            coordinator:
                context.coordinator
        )

        return linkView
    }

    func updateUIView(
        _ linkView: LPLinkView,
        context: Context
    ) {
        guard
            context.coordinator.url
                != url
        else {
            return
        }

        loadMetadata(
            into: linkView,
            coordinator:
                context.coordinator
        )
    }

    static func dismantleUIView(
        _ uiView: LPLinkView,
        coordinator: Coordinator
    ) {
        coordinator.provider?
            .cancel()
    }

    private func loadMetadata(
        into linkView: LPLinkView,
        coordinator: Coordinator
    ) {
        coordinator.provider?
            .cancel()
        coordinator.url = url

        if let cached =
            LinkPreviewMetadataCache
                .shared
                .object(
                    forKey:
                        url as NSURL
                ) {
            linkView.metadata =
                cached
            return
        }

        let provider =
            LPMetadataProvider()

        coordinator.provider =
            provider

        provider
            .startFetchingMetadata(
                for: url
            ) { metadata, _ in
                guard
                    let metadata
                else {
                    return
                }

                LinkPreviewMetadataCache
                    .shared
                    .setObject(
                        metadata,
                        forKey:
                            url as NSURL
                    )

                DispatchQueue.main.async {
                    guard
                        coordinator.url
                            == url
                    else {
                        return
                    }

                    linkView.metadata =
                        metadata
                }
            }
    }

    final class Coordinator {
        var provider:
            LPMetadataProvider?
        var url: URL?
    }
}


struct LinkifiedText: View {
    let text: String
    var font: Font = .body
    var alignment: TextAlignment = .leading

    var body: some View {
        Text(styledText)
            .font(font)
            .multilineTextAlignment(alignment)
    }

    private var styledText: AttributedString {
        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        var highlightRanges: [NSRange] = []

        if let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) {
            highlightRanges.append(
                contentsOf: detector
                    .matches(in: text, options: [], range: fullRange)
                    .compactMap { match in
                        guard let url = match.url, isHTTPURL(url) else {
                            return nil
                        }
                        return match.range
                    }
            )
        }

        if let hashtagRegex = try? NSRegularExpression(
            pattern: #"#[\p{L}\p{N}_-]+"#
        ) {
            highlightRanges.append(
                contentsOf: hashtagRegex
                    .matches(in: text, options: [], range: fullRange)
                    .map(\.range)
            )
        }

        highlightRanges.sort { $0.location < $1.location }

        guard !highlightRanges.isEmpty else {
            return AttributedString(text)
        }

        var result = AttributedString()
        var cursor = 0

        for range in highlightRanges {
            guard range.location >= cursor else {
                continue
            }

            if range.location > cursor {
                let normalRange = NSRange(
                    location: cursor,
                    length: range.location - cursor
                )
                result.append(
                    AttributedString(
                        nsText.substring(with: normalRange)
                    )
                )
            }

            var highlighted = AttributedString(
                nsText.substring(with: range)
            )
            highlighted.foregroundColor = .red
            result.append(highlighted)
            cursor = NSMaxRange(range)
        }

        if cursor < nsText.length {
            result.append(
                AttributedString(
                    nsText.substring(from: cursor)
                )
            )
        }

        return result
    }
}


private struct ShimmeringComposerPrompt: View {
    let text: String

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State private var shimmerOffset: CGFloat = -1.4

    var body: some View {
        Text(text)
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.primary.opacity(0.52))
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        Color.red.opacity(0.30),
                        Color.red,
                        Color.white.opacity(0.95),
                        Color.red,
                        Color.red.opacity(0.30),
                        .clear
                    ],
                    startPoint: UnitPoint(
                        x: shimmerOffset - 0.45,
                        y: 0.5
                    ),
                    endPoint: UnitPoint(
                        x: shimmerOffset + 0.45,
                        y: 0.5
                    )
                )
                .mask {
                    Text(text)
                        .font(.body.weight(.semibold))
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task(id: reduceMotion) {
                guard !reduceMotion else {
                    return
                }

                while !Task.isCancelled {
                    shimmerOffset = -1.4

                    withAnimation(.linear(duration: 2.8)) {
                        shimmerOffset = 1.4
                    }

                    try? await Task.sleep(
                        for: .seconds(5.2)
                    )
                }
            }
    }
}


struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    @Environment(\.dismiss)
    private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(imageData: $imageData, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding private var imageData: Data?
        private let dismiss: DismissAction

        init(imageData: Binding<Data?>, dismiss: DismissAction) {
            _imageData = imageData
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                imageData = image.jpegData(compressionQuality: 0.85)
            }

            dismiss()
        }
    }
}


// MARK: - Feature Card

struct GradientCard: View {
    let title: String
    let subtitle: String
    let detail: String? = nil

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 16
        ) {
            Image(
                systemName:
                    "gift.fill"
            )
            .font(.title2)
            .foregroundStyle(.red)
            .frame(
                width: 48,
                height: 48
            )
            .glassEffect(in: Circle())

            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(
                        .subheadline
                    )
                    .foregroundStyle(
                        .secondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                if let detail {
                    Text(detail)
                        .font(
                            .caption
                                .weight(
                                    .semibold
                                )
                        )
                        .foregroundStyle(
                            .secondary
                        )
                        .padding(
                            .top,
                            4
                        )
                }
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .glassEffect(in: .rect(cornerRadius: 22))
    }
}


struct PersonAvatarPalette {
    let fill: Color
    let ring: Color
}

let defaultAvatarEmojiSuggestions = [
    "🎈", "🎧", "🌼", "📚", "🏕️", "☕️",
    "🫶", "🍒", "🪴", "🧁", "🎨", "🦋"
]

let defaultAvatarAccentSuggestions = [
    "blush", "lavender", "butter",
    "mint", "sky", "peach"
]

func personInitials(from name: String) -> String {
    name
        .split(whereSeparator: { $0.isWhitespace })
        .prefix(2)
        .compactMap(\.first)
        .map(String.init)
        .joined()
}

func isAutomaticAvatarFallback(
    _ value: String,
    forName name: String
) -> Bool {
    let trimmed = value.trimmingCharacters(
        in: .whitespacesAndNewlines
    )

    if trimmed.isEmpty || trimmed == "✨" {
        return true
    }

    let initials = personInitials(from: name)

    if !initials.isEmpty,
       trimmed.localizedCaseInsensitiveCompare(
           initials
       ) == .orderedSame {
        return true
    }

    let lettersOnly = trimmed.unicodeScalars.allSatisfy {
        CharacterSet.letters.contains($0)
    }

    return lettersOnly && trimmed.count <= 2
}

func suggestedAvatarEmoji(
    for name: String,
    relation: String = "",
    offset: Int = 0
) -> String {
    let normalizedName = name
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
    let normalizedRelation = relation
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    let seed = (normalizedName + "|" + normalizedRelation)
        .isEmpty
        ? "person"
        : normalizedName + "|" + normalizedRelation

    let score = seed.unicodeScalars.reduce(0) {
        $0 + Int($1.value)
    }

    let index = (score + (offset * 5)) % defaultAvatarEmojiSuggestions.count
    return defaultAvatarEmojiSuggestions[index]
}

func suggestedAvatarAccent(
    for name: String,
    relation: String = ""
) -> String {
    let normalizedName = name
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
    let normalizedRelation = relation
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    let seed = (normalizedName + "|" + normalizedRelation)
        .isEmpty
        ? "person"
        : normalizedName + "|" + normalizedRelation

    let score = seed.unicodeScalars.reduce(0) {
        $0 + Int($1.value)
    }

    return defaultAvatarAccentSuggestions[
        score % defaultAvatarAccentSuggestions.count
    ]
}

func personAvatarPalette(
    accent: String?,
    name: String = "",
    relation: String = ""
) -> PersonAvatarPalette {
    let rawAccent = accent?
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

    let token: String = {
        switch rawAccent {
        case "coral", "red":
            return suggestedAvatarAccent(
                for: name,
                relation: relation
            )
        case "blue":
            return "sky"
        case "violet":
            return "lavender"
        case "yellow":
            return "butter"
        case "blush", "lavender", "butter", "mint", "sky", "peach":
            return rawAccent ?? suggestedAvatarAccent(
                for: name,
                relation: relation
            )
        default:
            return suggestedAvatarAccent(
                for: name,
                relation: relation
            )
        }
    }()

    switch token {
    case "lavender":
        return PersonAvatarPalette(
            fill: Color(
                red: 0.80,
                green: 0.74,
                blue: 0.96
            ).opacity(0.15),
            ring: Color(
                red: 0.66,
                green: 0.57,
                blue: 0.89
            ).opacity(0.20)
        )

    case "butter":
        return PersonAvatarPalette(
            fill: Color(
                red: 0.99,
                green: 0.90,
                blue: 0.56
            ).opacity(0.16),
            ring: Color(
                red: 0.88,
                green: 0.78,
                blue: 0.38
            ).opacity(0.22)
        )

    case "mint":
        return PersonAvatarPalette(
            fill: Color(
                red: 0.69,
                green: 0.92,
                blue: 0.84
            ).opacity(0.16),
            ring: Color(
                red: 0.44,
                green: 0.78,
                blue: 0.66
            ).opacity(0.20)
        )

    case "sky":
        return PersonAvatarPalette(
            fill: Color(
                red: 0.67,
                green: 0.84,
                blue: 0.98
            ).opacity(0.16),
            ring: Color(
                red: 0.43,
                green: 0.68,
                blue: 0.92
            ).opacity(0.20)
        )

    case "peach":
        return PersonAvatarPalette(
            fill: Color(
                red: 0.99,
                green: 0.80,
                blue: 0.69
            ).opacity(0.16),
            ring: Color(
                red: 0.92,
                green: 0.61,
                blue: 0.49
            ).opacity(0.20)
        )

    default:
        return PersonAvatarPalette(
            fill: Color(
                red: 0.99,
                green: 0.66,
                blue: 0.73
            ).opacity(0.16),
            ring: Color(
                red: 0.92,
                green: 0.38,
                blue: 0.47
            ).opacity(0.22)
        )
    }
}


// MARK: - Person

struct PersonTile: View {
    let person: Person
    var isSaveHighlighted = false

    @State
    private var hasAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            Avatar(
                person: person,
                size: 78
            )

            VStack(spacing: 7) {
                Text(homeDisplayName)
                    .font(
                        .subheadline
                            .weight(
                                .semibold
                            )
                    )
                    .lineLimit(1)

                HomePersonMetadataBadge(
                    giftCount: person.ideas.count,
                    countdown: person.countdown,
                    isSaveHighlighted: isSaveHighlighted
                )
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .vertical,
            14
        )
        .scaleEffect(hasAppeared ? 1 : 0.80)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            guard !hasAppeared else { return }

            withAnimation(
                .spring(
                    response: 0.48,
                    dampingFraction: 0.70,
                    blendDuration: 0.12
                )
            ) {
                hasAppeared = true
            }
        }
    }

    private var homeDisplayName: String {
        person.name
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)
            ?? person.name
    }
}


struct AddFriendPlaceholderTile: View {
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color.secondary.opacity(0.42),
                        style: StrokeStyle(
                            lineWidth: 1.5,
                            dash: [5, 5]
                        )
                    )
                    .frame(width: 78, height: 78)

                Image(systemName: "plus")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 7) {
                Text("Add a friend")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text("in one tap")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 26)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .scaleEffect(hasAppeared ? 1 : 0.80)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            guard !hasAppeared else { return }
            withAnimation(
                .spring(
                    response: 0.48,
                    dampingFraction: 0.70,
                    blendDuration: 0.12
                )
            ) {
                hasAppeared = true
            }
        }
    }
}

struct Avatar: View {
    let person: Person
    let size: CGFloat

    var body: some View {
        Group {
            if let profileImage = person.profileImage,
               let image = AwwImageCache.shared.image(
                    from: profileImage,
                    maxPixelSize: max(size * 3, 180)
               ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(displayEmoji)
                    .font(
                        .system(
                            size: size * 0.66
                        )
                    )
            }
        }
        .frame(
            width: size,
            height: size
        )
        .background(
            palette.fill,
            in: Circle()
        )
        .overlay {
            Circle()
                .stroke(
                    palette.ring,
                    lineWidth: 1
                )
        }
        .clipShape(Circle())
    }

    private var palette: PersonAvatarPalette {
        personAvatarPalette(
            accent: person.accent,
            name: person.name,
            relation: person.relation
        )
    }

    private var displayEmoji: String {
        if isAutomaticAvatarFallback(
            person.emoji,
            forName: person.name
        ) {
            let suggestion = suggestedAvatarEmoji(
                for: person.name,
                relation: person.relation
            )
            return suggestion.isEmpty
                ? personInitials(from: person.name)
                : suggestion
        }

        return person.emoji
    }
}


struct WishCountBadge: View {
    let count: Int
    let avatarSize: CGFloat
    let isProminent: Bool
    let isSaveHighlighted: Bool

    init(
        count: Int,
        avatarSize: CGFloat,
        isProminent: Bool = false,
        isSaveHighlighted: Bool = false
    ) {
        self.count = count
        self.avatarSize = avatarSize
        self.isProminent = isProminent
        self.isSaveHighlighted = isSaveHighlighted
    }

    var body: some View {
        HStack(spacing: isProminent ? 4 : 3) {
            Image(systemName: "heart.fill")
                .font(badgeFont.weight(.semibold))
                .foregroundStyle(isSaveHighlighted ? Color.red : Color.secondary)
                .animation(.easeOut(duration: 1.35), value: isSaveHighlighted)

            Text(count, format: .number)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(count)))
                .foregroundStyle(.secondary)
        }
        .font(badgeFont.weight(.bold))
        .padding(.horizontal, horizontalPadding)
        .frame(minWidth: badgeHeight, minHeight: badgeHeight)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: Capsule()
        )
        .overlay {
            Capsule()
                .stroke(
                    Color(uiColor: .systemBackground),
                    lineWidth: 1.5
                )
        }
        .accessibilityLabel("\(count) wishes")
    }

    private var badgeFont: Font {
        isProminent ? .subheadline : .caption
    }

    private var badgeHeight: CGFloat {
        if isProminent {
            return min(max(avatarSize * 0.38, 28), 34)
        }

        return 24
    }

    private var horizontalPadding: CGFloat {
        badgeHeight * (isProminent ? 0.42 : 0.42)
    }
}


struct HomePersonMetadataBadge: View {
    let giftCount: Int
    let countdown: String
    var isSaveHighlighted = false

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSaveHighlighted ? Color.red : Color.secondary)
                    .animation(.easeOut(duration: 1.35), value: isSaveHighlighted)

                Text(giftCount, format: .number)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(giftCount)))
            }

            if let momentText {
                Text("·")
                    .foregroundStyle(.tertiary)

                HStack(spacing: 3) {
                    Image(systemName: "calendar")
                        .font(.caption2.weight(.semibold))

                    Text(momentText)
                        .lineLimit(1)
                }
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 9)
        .frame(minHeight: 26)
        .background(
            Color.primary.opacity(0.065),
            in: Capsule()
        )
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var momentText: String? {
        let value = countdown.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if value.isEmpty
            || value.localizedCaseInsensitiveCompare(
                "No occasion soon"
            ) == .orderedSame {
            return nil
        }

        if value.localizedCaseInsensitiveContains("today") {
            return "Today"
        }

        if value.localizedCaseInsensitiveContains("tomorrow") {
            return "Tomorrow"
        }

        if let amount = amountBefore("day", in: value) {
            return "In \(amount)d"
        }

        if let amount = amountBefore("week", in: value) {
            return "In \(amount)w"
        }

        if let amount = amountBefore("month", in: value) {
            return "In \(amount)mo"
        }

        if let amount = amountBefore("year", in: value) {
            return "In \(amount)y"
        }

        if let range = value.range(
            of: " in ",
            options: .caseInsensitive
        ) {
            return "In " + value[range.upperBound...]
        }

        return value
    }

    private var accessibilityText: String {
        guard momentText != nil else {
            return "\(giftCount) gift ideas"
        }

        return "\(giftCount) gift ideas, \(countdown)"
    }

    private func amountBefore(
        _ unit: String,
        in value: String
    ) -> String? {
        let lowercased = value.lowercased()
        let pattern = #"(\d+)\s*\#(unit)s?"#

        guard
            let expression = try? NSRegularExpression(
                pattern: pattern
            ),
            let match = expression.firstMatch(
                in: lowercased,
                range: NSRange(
                    lowercased.startIndex...,
                    in: lowercased
                )
            ),
            let numberRange = Range(
                match.range(at: 1),
                in: lowercased
            )
        else {
            return nil
        }

        return String(lowercased[numberRange])
    }
}


// MARK: - Ideas

struct IdeaTile: View {
    let idea: Idea

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Image(
                systemName: "gift.fill"
            )
            .font(.title2)
            .foregroundStyle(.red)
            .frame(
                maxWidth: .infinity
            )
            .frame(height: 126)
            .glassEffect(in: .rect(cornerRadius: 16))

            Text(idea.title)
                .font(.headline)
                .lineLimit(2)

            Text(
                categoryValues(from: idea.category).isEmpty
                ? "Little luxury"
                : categoryValues(from: idea.category)
                    .map { "#\($0)" }
                    .joined(separator: "  ")
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )
        }
        .padding(10)
        .glassEffect(in: .rect(cornerRadius: 20))
    }
}


enum WishBubbleLayout {
    case grid
    case list
}

struct GiftMessageBubble: View {
    let idea: Idea
    var layout: WishBubbleLayout = .list
    var isPinned = false
    var footerPeople: [Person] = []
    var onCategoryTap: (String) -> Void = { _ in }

    @State
    private var hasAppeared = false

    @Environment(\.colorScheme)
    private var colorScheme

    private var cardColor: Color {
        WishCardPalette.color(for: idea, colorScheme: colorScheme)
    }

    private var bodyText: String {
        [idea.title, idea.note]
            .filter {
                !$0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            }
            .joined(separator: "\n")
    }

    private var displayBodyText: String {
        displayTextWithoutCategoryHashtags(
            bodyText
        )
    }

    private var categories: [String] {
        categoryValues(
            from: idea.category
        )
    }

    private var previewImageData: [Data] {
        let dataValues = idea.attachments
            .sorted { $0.created < $1.created }
            .lazy
            .filter { $0.kind == "image" }
            .compactMap(\.data)

        var result = Array(dataValues)

        if let legacy = idea.image,
           !result.contains(legacy) {
            result.insert(legacy, at: 0)
        }

        return result
    }

    private var linkURLs: [URL] {
        let saved = idea.attachments
            .sorted { $0.created < $1.created }
            .filter { $0.kind == "link" }
            .compactMap {
                URL(string: $0.linkURL)
            }

        var seen = Set<String>()

        return (
            saved
            + detectedHTTPURLs(in: bodyText)
        )
        .filter(isHTTPURL)
        .filter {
            seen.insert(
                $0.absoluteString
            ).inserted
        }
    }

    private var firstFile: IdeaAttachment? {
        idea.attachments
            .sorted {
                $0.created < $1.created
            }
            .first(
                where: {
                    $0.kind == "file"
                }
            )
    }

    private var displayStatus: String {
        switch idea.status {
        case "Maybe":
            return "Would love"
        case "Definitely":
            return "Most wanted"
        default:
            return idea.status
        }
    }

    private var hasGridMedia: Bool {
        !previewImageData.isEmpty
            || !linkURLs.isEmpty
            || firstFile != nil
    }

    private var gridTextFontSize: CGFloat {
        let count = displayBodyText.count

        if count <= 24 {
            return 21
        }

        if count <= 55 {
            return 18
        }

        if count <= 100 {
            return 16
        }

        return 14
    }

    var body: some View {
        Group {
            switch layout {
            case .grid:
                gridBubble
            case .list:
                listBubble
            }
        }
        .contentShape(
            .rect(
                cornerRadius: 21
            )
        )
        .scaleEffect(
            hasAppeared ? 1 : 0.88,
            anchor: .bottomLeading
        )
        .opacity(
            hasAppeared ? 1 : 0
        )
        .onAppear {
            guard !hasAppeared else { return }

            withAnimation(
                .spring(
                    response: 0.44,
                    dampingFraction: 0.72,
                    blendDuration: 0.10
                )
            ) {
                hasAppeared = true
            }
        }
        .accessibilityElement(
            children: .contain
        )
    }

    private var listBubble: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            if !displayBodyText.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    LinkifiedText(
                        text: displayBodyText,
                        font: .body,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                    Spacer(minLength: 0)

                    if isPinned {
                        pinnedIcon
                    }
                }
            } else if isPinned {
                HStack {
                    Spacer()
                    pinnedIcon
                }
            }

            if !previewImageData.isEmpty {
                listImagePreview
            }

            ForEach(
                linkURLs,
                id: \.absoluteString
            ) { url in
                RichLinkPreview(
                    url: url,
                    compact: true
                )
                .frame(
                    width: 200,
                    height: 104
                )
                .clipShape(
                    .rect(
                        cornerRadius: 13
                    )
                )
                .allowsHitTesting(false)
            }

            if linkURLs.isEmpty,
               let firstFile {
                listFilePreview(firstFile)
            }

            listCategoryChips
            statusFooter
        }
        .padding(
            .horizontal,
            15
        )
        .padding(
            .vertical,
            13
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background {
            bubbleBackground(
                showsTail: true
            )
        }
        .padding(.bottom, 5)
    }

    private var gridBubble: some View {
        VStack(
            alignment: .leading,
            spacing: 7
        ) {
            HStack(
                alignment: .top,
                spacing: 6
            ) {
                if !displayBodyText.isEmpty {
                    Text(displayBodyText)
                        .font(
                            .system(
                                size: gridTextFontSize,
                                weight:
                                    displayBodyText.count <= 55
                                    ? .semibold
                                    : .regular
                            )
                        )
                        .lineLimit(
                            hasGridMedia ? 3 : 7
                        )
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                        .multilineTextAlignment(.leading)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .topLeading
                        )
                } else {
                    Text("Saved wish")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if isPinned {
                    pinnedIcon
                }
            }
            .frame(
                height:
                    hasGridMedia
                    ? 52
                    : 116,
                alignment: .topLeading
            )
            .clipped()

            if !previewImageData.isEmpty {
                gridImagePreview

                if let url = linkURLs.first {
                    gridLinkChip(url)
                }
            } else if let url = linkURLs.first {
                RichLinkPreview(
                    url: url,
                    compact: true
                )
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 72)
                .clipShape(
                    .rect(
                        cornerRadius: 12
                    )
                )
                .allowsHitTesting(false)
            } else if let firstFile {
                gridFilePreview(firstFile)
            } else {
                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            HStack(
                alignment: .center,
                spacing: 6
            ) {
                if footerPeople.isEmpty {
                    gridCategoryChip
                } else {
                    gridPeopleFooter
                }

                Spacer(minLength: 4)

                Text(displayStatus)
                    .font(
                        .caption2
                            .weight(.semibold)
                    )
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(11)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .frame(
            height: 220,
            alignment: .topLeading
        )
        .background {
            bubbleBackground(
                showsTail: false
            )
        }
        .clipped()
    }

    private var pinnedIcon: some View {
        Image(systemName: "pin.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.red)
            .frame(
                width: 22,
                height: 22
            )
            .background(
                Color.red.opacity(0.10),
                in: Circle()
            )
            .accessibilityLabel("Pinned")
    }

    @ViewBuilder
    private var listCategoryChips: some View {
        if !categories.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(
                        categories,
                        id: \.self
                    ) { category in
                        Button {
                            onCategoryTap(
                                category
                            )
                        } label: {
                            Text("#\(category)")
                                .font(
                                    .caption
                                        .weight(.semibold)
                                )
                                .foregroundStyle(.red)
                                .padding(
                                    .horizontal,
                                    9
                                )
                                .padding(
                                    .vertical,
                                    6
                                )
                                .background(
                                    Color.red.opacity(0.10),
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var gridPeopleFooter: some View {
        HStack(spacing: -8) {
            ForEach(Array(footerPeople.prefix(4))) { person in
                ZStack {
                    // Opaque adaptive base. The normal avatar tint is layered on top,
                    // so the circle never becomes transparent over the wish card.
                    Circle()
                        .fill(Color(uiColor: .secondarySystemBackground))

                    Avatar(person: person, size: 28)
                }
                .frame(width: 28, height: 28)
                .overlay {
                    Circle()
                        .stroke(Color(uiColor: .systemBackground), lineWidth: 2)
                }
            }

            if footerPeople.count > 4 {
                Text("+\(footerPeople.count - 4)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(
                        Color(uiColor: .secondarySystemBackground),
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(Color(uiColor: .systemBackground), lineWidth: 2)
                    }
            }
        }
        // This is a real element in the footer HStack, not an overlay.
        // It permanently reserves width so wish/status text cannot render beneath it.
        .fixedSize(horizontal: true, vertical: true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Saved for " + footerPeople.map(\.name).joined(separator: ", ")
        )
    }

    @ViewBuilder
    private var gridCategoryChip: some View {
        if let firstCategory = categories.first {
            Button {
                onCategoryTap(
                    firstCategory
                )
            } label: {
                HStack(spacing: 3) {
                    Text("#\(firstCategory)")

                    if categories.count > 1 {
                        Text("+\(categories.count - 1)")
                    }
                }
                .font(
                    .caption2
                        .weight(.semibold)
                )
                .foregroundStyle(.red)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(
                    .horizontal,
                    7
                )
                .padding(
                    .vertical,
                    4
                )
                .background(
                    Color.red.opacity(0.10),
                    in: Capsule()
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var statusFooter: some View {
        HStack(spacing: 8) {
            Text(displayStatus)

            if let price = idea.price {
                Text(
                    price,
                    format:
                        .currency(
                            code: AwwLocale.currencyCode
                        )
                )
            }
        }
        .font(
            .caption
                .weight(.semibold)
        )
        .foregroundStyle(
            .secondary
        )
    }

    private func listFilePreview(
        _ attachment: IdeaAttachment
    ) -> some View {
        HStack(spacing: 10) {
            Image(
                systemName: "doc.fill"
            )
            .font(.title3)
            .foregroundStyle(
                .secondary
            )

            Text(
                attachment.filename
            )
            .font(
                .subheadline
                    .weight(.semibold)
            )
            .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: 200)
        .background(
            Color.primary.opacity(
                0.055
            ),
            in: .rect(
                cornerRadius: 12
            )
        )
    }

    private func gridFilePreview(
        _ attachment: IdeaAttachment
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.fill")
                .foregroundStyle(.secondary)

            Text(attachment.filename)
                .font(
                    .caption
                        .weight(.semibold)
                )
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(9)
        .frame(
            maxWidth: .infinity,
            minHeight: 58,
            alignment: .leading
        )
        .background(
            Color.primary.opacity(0.055),
            in: .rect(cornerRadius: 11)
        )
    }

    private func gridLinkChip(
        _ url: URL
    ) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "link")
                .font(.caption2.weight(.semibold))

            Text(
                url.host() ?? url.absoluteString
            )
            .font(
                .caption2
                    .weight(.semibold)
            )
            .lineLimit(1)

            Spacer(minLength: 0)
        }
        .foregroundStyle(.secondary)
        .frame(height: 16)
    }

    @ViewBuilder
    private var listImagePreview: some View {
        let images = Array(
            previewImageData.prefix(3)
        )

        if images.count == 1,
           let data = images.first {
            AwwDataImage(
                data: data,
                maxPixelSize: 520
            )
            .scaledToFill()
            .frame(
                width: 200,
                height: 132
            )
            .clipped()
            .clipShape(
                .rect(
                    cornerRadius: 13
                )
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        } else {
            HStack(spacing: 6) {
                ForEach(
                    Array(
                        images.enumerated()
                    ),
                    id: \.offset
                ) { index, data in
                    ZStack(
                        alignment:
                            .bottomTrailing
                    ) {
                        AwwDataImage(
                            data: data,
                            maxPixelSize: 360
                        )
                        .scaledToFill()
                        .frame(
                            width:
                                images.count == 2
                                ? 97
                                : 62,
                            height:
                                images.count == 2
                                ? 92
                                : 78
                        )
                        .clipped()
                        .clipShape(
                            .rect(
                                cornerRadius:
                                    11
                            )
                        )

                        if index == 2,
                           previewImageData.count > 3 {
                            Text(
                                "+\(previewImageData.count - 3)"
                            )
                            .font(
                                .caption2
                                    .weight(.bold)
                            )
                            .foregroundStyle(.white)
                            .padding(
                                .horizontal,
                                6
                            )
                            .padding(
                                .vertical,
                                4
                            )
                            .background(
                                .black.opacity(0.58),
                                in: .capsule
                            )
                            .padding(5)
                        }
                    }
                }
            }
            .frame(
                width: 200,
                alignment: .leading
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    private var gridImagePreview: some View {
        GeometryReader { proxy in
            let images = Array(
                previewImageData.prefix(2)
            )
            let spacing: CGFloat = 4
            let imageWidth =
                images.count > 1
                ? (proxy.size.width - spacing) / 2
                : proxy.size.width

            HStack(spacing: spacing) {
                ForEach(
                    Array(
                        images.enumerated()
                    ),
                    id: \.offset
                ) { index, data in
                    ZStack(
                        alignment: .bottomTrailing
                    ) {
                        AwwDataImage(
                            data: data,
                            maxPixelSize: 420
                        )
                        .scaledToFill()
                        .frame(
                            width: imageWidth,
                            height: 72
                        )
                        .clipped()
                        .clipShape(
                            .rect(
                                cornerRadius: 11
                            )
                        )

                        if index == 1,
                           previewImageData.count > 2 {
                            Text(
                                "+\(previewImageData.count - 2)"
                            )
                            .font(
                                .caption2
                                    .weight(.bold)
                            )
                            .foregroundStyle(.white)
                            .padding(
                                .horizontal,
                                6
                            )
                            .padding(
                                .vertical,
                                4
                            )
                            .background(
                                .black.opacity(0.58),
                                in: .capsule
                            )
                            .padding(5)
                        }
                    }
                }
            }
        }
        .frame(height: 72)
    }

    private func bubbleBackground(
        showsTail: Bool
    ) -> some View {
        ZStack(
            alignment:
                .bottomLeading
        ) {
            RoundedRectangle(
                cornerRadius: 21,
                style: .continuous
            )
            .fill(cardColor)

            if showsTail {
                Circle()
                    .fill(cardColor)
                    .frame(
                        width: 11,
                        height: 11
                    )
                    .offset(
                        x: 5,
                        y: 5
                    )
            }
        }
    }
}

struct IdeaRow: View {
    @Bindable
    var idea: Idea

    private let statuses = [
        "Would love",
        "Most wanted",
        "Given"
    ]

    var body: some View {
        HStack(spacing: 12) {
            Image(
                systemName: "gift.fill"
            )
            .foregroundStyle(.red)
            .frame(
                width: 52,
                height: 52
            )
            .glassEffect(in: .rect(cornerRadius: 14))

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(idea.title)
                    .font(.headline)

                Label(
                    idea.status,
                    systemImage:
                        "circle.fill"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()

            Menu {
                ForEach(
                    statuses,
                    id: \.self
                ) { state in
                    Button(state) {
                        idea.status =
                            state

                        idea.updated =
                            .now
                    }
                }
            } label: {
                Image(
                    systemName:
                        "ellipsis"
                )
                .frame(
                    width: 40,
                    height: 40
                )
            }
        }
        .padding(10)
        .glassEffect(in: .rect(cornerRadius: 18))
    }
}


// MARK: - Background

struct Backdrop: View {
    var body: some View {
        Color(
            uiColor:
                .systemBackground
        )
        .ignoresSafeArea()
    }
}


// MARK: - Colors

enum WishCardPalette: String, CaseIterable, Identifiable {
    case warmBlush
    case softPeach
    case paleButter
    case mistBlue
    case softLilac
    case sageMist
    case neutralGray

    static let defaultID = Self.warmBlush.rawValue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .warmBlush: "Warm blush"
        case .softPeach: "Soft peach"
        case .paleButter: "Pale butter"
        case .mistBlue: "Mist blue"
        case .softLilac: "Soft lilac"
        case .sageMist: "Sage mist"
        case .neutralGray: "Neutral gray"
        }
    }

    func color(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return switch self {
            case .warmBlush: Color(red: 0.227, green: 0.137, blue: 0.157)
            case .softPeach: Color(red: 0.231, green: 0.165, blue: 0.133)
            case .paleButter: Color(red: 0.220, green: 0.192, blue: 0.122)
            case .mistBlue: Color(red: 0.133, green: 0.180, blue: 0.220)
            case .softLilac: Color(red: 0.176, green: 0.157, blue: 0.227)
            case .sageMist: Color(red: 0.137, green: 0.200, blue: 0.165)
            case .neutralGray: Color(red: 0.165, green: 0.165, blue: 0.180)
            }
        }

        return switch self {
        case .warmBlush: Color(red: 1.0, green: 0.949, blue: 0.953)
        case .softPeach: Color(red: 1.0, green: 0.961, blue: 0.929)
        case .paleButter: Color(red: 1.0, green: 0.976, blue: 0.910)
        case .mistBlue: Color(red: 0.945, green: 0.965, blue: 0.980)
        case .softLilac: Color(red: 0.961, green: 0.949, blue: 0.980)
        case .sageMist: Color(red: 0.945, green: 0.969, blue: 0.949)
        case .neutralGray: Color(red: 0.961, green: 0.961, blue: 0.969)
        }
    }

    static func color(for idea: Idea, colorScheme: ColorScheme = .light) -> Color {
        if let palette = Self(rawValue: idea.cardColor) {
            return palette.color(for: colorScheme)
        }

        let index = idea.id.uuid.0 % UInt8(allCases.count)
        return allCases[Int(index)].color(for: colorScheme)
    }
}

extension Color {
    static let canvas =
        Color(
            uiColor:
                .systemBackground
        )

    static let ink =
        Color.primary

    static let soft =
        Color.secondary

    static let coral =
        Color.red

    static let butter =
        Color(
            uiColor:
                .secondarySystemBackground
        )

    static let peach =
        Color.red

    static let sky =
        Color(
            uiColor:
                .secondarySystemBackground
        )

    static let violet =
        Color.red
}


extension ShapeStyle
where Self == Color {
    static var soft: Color {
        .secondary
    }

    static var coral: Color {
        .red
    }

    static var ink: Color {
        .primary
    }

    static var butter: Color {
        Color(
            uiColor:
                .secondarySystemBackground
        )
    }

    static var sky: Color {
        Color(
            uiColor:
                .secondarySystemBackground
        )
    }

    static var peach: Color {
        .red
    }

    static var violet: Color {
        .red
    }
}


extension Text {
    func heading() -> some View {
        font(
            .title2
                .weight(.bold)
        )
        .foregroundStyle(
            .primary
        )
    }
}
