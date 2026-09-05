import SwiftUI
import SwiftData

// MARK: - Wish Detail

struct WishDetail: View {
    let person: Person
    let idea: Idea

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var context

    @Query(sort: \Idea.updated, order: .reverse)
    private var allIdeas: [Idea]

    @State private var bodyText: String
    @State private var categories: [String]
    @State private var status: String
    @State private var priceDraft: String
    @State private var showingPriceAlert = false
    @State private var selectedCategoryRoute: CategorySheetRoute?
    @State private var showingPhotoPicker = false
    @State private var showingFileImporter = false
    @State private var showingCamera = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var cameraImageData: Data?
    @State private var textFocusRequest = 0
    @State private var autosaveTask: Task<Void, Never>?

    init(person: Person, idea: Idea) {
        self.person = person
        self.idea = idea

        let combined = [idea.title, idea.note]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n")

        let savedCategories = categoryValues(from: idea.category)
        let categoriesAlreadyInText = hashtagCategoryValues(in: combined)
        let missingCategories = savedCategories.filter { saved in
            !categoriesAlreadyInText.contains {
                $0.localizedCaseInsensitiveCompare(saved) == .orderedSame
            }
        }
        let missingHashtags = missingCategories
            .map { "#\($0)" }
            .joined(separator: " ")
        let initialText: String
        if combined.isEmpty {
            initialText = missingHashtags
        } else if missingHashtags.isEmpty {
            initialText = combined
        } else {
            initialText = combined + "\n\n" + missingHashtags
        }

        _bodyText = State(initialValue: initialText)
        _categories = State(initialValue: uniqueCategoryValues(savedCategories + categoriesAlreadyInText))
        _status = State(initialValue: idea.status)
        _priceDraft = State(
            initialValue: idea.price.map(AwwLocale.decimalString) ?? ""
        )
    }

    private var hashtagQuery: String? {
        currentHashtagQuery(in: bodyText)
    }

    private var existingCategories: [String] {
        uniqueCategoryValues(
            allIdeas.flatMap {
                categoryValues(from: $0.category)
            }
        )
        .sorted()
    }

    private var categorySuggestions: [String] {
        guard let hashtagQuery else { return [] }

        let options = uniqueCategoryValues(
            AwwCategoryPreferences.visibleDefaults + existingCategories
        )

        if hashtagQuery.isEmpty {
            return Array(options.sorted().prefix(6))
        }

        if options.contains(where: {
            $0.localizedCaseInsensitiveCompare(hashtagQuery) == .orderedSame
        }) {
            return []
        }

        return options
            .filter { $0.localizedCaseInsensitiveContains(hashtagQuery) }
            .sorted()
            .prefix(6)
            .map { $0 }
    }

    private var personDisplayName: String {
        person.name
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)
            ?? person.name
    }

    private var orderedAttachments: [IdeaAttachment] {
        idea.attachments.sorted {
            if $0.created == $1.created {
                return $0.id.uuidString < $1.id.uuidString
            }
            return $0.created < $1.created
        }
    }

    var body: some View {
        wishLifecycleView
    }

    private var wishLifecycleView: some View {
        wishImportView
            .onChange(of: selectedPhotos) { _, photos in
                Task {
                    await importPhotos(photos)
                }
            }
            .onChange(of: cameraImageData) { _, data in
                guard let data else {
                    return
                }
                insertImage(data)
                cameraImageData = nil
            }
            .onChange(of: bodyText) { _, newText in
                handleBodyTextChange(newText)
            }
            .onChange(of: status) { _, newStatus in
                idea.status = newStatus
                idea.updated = .now
                scheduleAutosave()
            }
            .onAppear {
                migrateLegacyImageIfNeeded()
                ensureLinkAttachments(for: bodyText)
            }
            .onDisappear {
                autosaveTask?.cancel()
                saveNow()
            }
    }

    private var wishImportView: some View {
        wishPresentationView
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
                CameraPicker(imageData: $cameraImageData)
                    .ignoresSafeArea()
            }
    }

    private var wishPresentationView: some View {
        wishNavigationView
            .alert("Price", isPresented: $showingPriceAlert) {
                TextField("0.00", text: $priceDraft)
                    .keyboardType(.decimalPad)

                if idea.price != nil {
                    Button("Remove price", role: .destructive) {
                        priceDraft = ""
                        idea.price = nil
                        idea.updated = .now
                    }
                }

                Button("Save") {
                    savePrice()
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a price using your device’s number format.")
            }
            .sheet(item: $selectedCategoryRoute) { route in
                if let categoryID = route.categoryID {
                    CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
                } else if let legacyName = route.legacyName {
                    CategoryWishesSheet(category: legacyName)
                }
            }
    }

    private var wishNavigationView: some View {
        NavigationStack {
            wishEditorScrollView
                .background(Backdrop())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 7) {
                            Avatar(person: person, size: 28)

                            Text("\(personDisplayName)’s wish", comment: "Navigation title for a person's wish detail.")
                                .font(.headline)
                        }
                        .accessibilityElement(children: .combine)
                    }

                    ToolbarItem(
                        placement:
                            .cancellationAction
                    ) {
                        noteAddMenu
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            saveNow()
                            AwwHaptics.success()
                            dismiss()
                        }
                    }
                }
        }
    }

    private var wishEditorScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                metadataChips
                noteTextEditor

                if !categories.isEmpty {
                    categoryChips
                }

                if !categorySuggestions.isEmpty {
                    categorySuggestionBar
                }

                attachmentsCanvas
                wishTimestamps
            }
            .frame(maxWidth: AwwAppLimits.detailMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var wishTimestamps: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Added: \(idea.created.formatted(date: .abbreviated, time: .shortened))")
            Text("Edited: \(idea.updated.formatted(date: .abbreviated, time: .shortened))")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
    }

    private func handleBodyTextChange(_ newText: String) {
        let hashtagsInText = hashtagCategoryValues(in: newText)
        categories = categories.filter { category in
            hashtagsInText.contains {
                $0.localizedCaseInsensitiveCompare(category) == .orderedSame
            }
        }
        ensureLinkAttachments(for: newText)
        saveText()
        scheduleAutosave()
    }

    private var metadataChips: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(IdeaStatus.allCases) { option in
                    Button {
                        status = option.title
                    } label: {
                        if status == option.title {
                            Label(option.title, systemImage: "checkmark")
                        } else {
                            Text(option.title)
                        }
                    }
                }
            } label: {
                Label(status, systemImage: "gift.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)

            Button {
                priceDraft = idea.price.map(AwwLocale.decimalString) ?? ""
                showingPriceAlert = true
            } label: {
                Label(priceChipText, systemImage: "dollarsign")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)

            Menu {
                ForEach(WishCardPalette.allCases) { palette in
                    Button {
                        idea.cardColor = palette.id
                        idea.updated = .now
                        scheduleAutosave()
                        AwwHaptics.selection()
                    } label: {
                        if idea.cardColor == palette.id {
                            Label(palette.title, systemImage: "checkmark")
                        } else {
                            Text(palette.title)
                        }
                    }
                }
            } label: {
                Circle()
                    .fill(WishCardPalette.color(for: idea))
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle().stroke(.primary.opacity(0.12))
                    }
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
            .accessibilityLabel("Card color")

            Spacer(minLength: 0)
        }
    }

    private var priceChipText: String {
        if let price = idea.price {
            return AwwLocale.decimalString(price)
        }
        return "Price"
    }

    private var noteTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if bodyText.isEmpty {
                Text("Start typing…")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
                    .allowsHitTesting(false)
            }

            LinkAwareTextView(
                text: $bodyText,
                focusRequest: textFocusRequest,
                onFocusChange: { _ in },
                highlightedHashtags: categories,
                font: .preferredFont(forTextStyle: .body),
                minHeight: 150,
                maxHeight: 520
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(
                    categories,
                    id: \.self
                ) { category in
                    Button {
                        selectedCategoryRoute = CategorySheetRoute(legacyName: category)
                    } label: {
                        Text("#\(category)")
                            .font(
                                .subheadline
                                    .weight(
                                        .semibold
                                    )
                            )
                            .foregroundStyle(
                                .red
                            )
                            .padding(
                                .horizontal,
                                11
                            )
                            .padding(
                                .vertical,
                                7
                            )
                            .background(
                                Color.red
                                    .opacity(
                                        0.10
                                    ),
                                in:
                                    Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }


    private var categorySuggestionBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                if let hashtagQuery, !hashtagQuery.isEmpty,
                   !existingCategories.contains(where: {
                       $0.localizedCaseInsensitiveCompare(hashtagQuery) == .orderedSame
                   }) {
                    Button("Add #\(hashtagQuery)") {
                        applyCategory(hashtagQuery)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)
                }

                ForEach(categorySuggestions, id: \.self) { suggestion in
                    Button("#\(suggestion)") {
                        applyCategory(suggestion)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .controlSize(.small)
                }
            }
        }
        .scrollIndicators(.hidden)
    }



    @ViewBuilder
    private var attachmentsCanvas: some View {
        if !orderedAttachments.isEmpty {
            VStack(spacing: 12) {
                ForEach(orderedAttachments) { attachment in
                    noteAttachmentBlock(attachment)
                        .draggable(attachment.id.uuidString)
                        .dropDestination(for: String.self) { values, _ in
                            guard let raw = values.first,
                                  let sourceID = UUID(uuidString: raw) else {
                                return false
                            }
                            moveAttachment(sourceID, before: attachment.id)
                            return true
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func noteAttachmentBlock(_ attachment: IdeaAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                switch attachment.kind {
                case "image":
                    if let data = attachment.data {
                        AwwDataImage(
                            data: data,
                            maxPixelSize: 1400
                        )
                        .scaledToFit()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 160,
                            maxHeight: 420
                        )
                        .background(Color.primary.opacity(0.035))
                        .clipShape(.rect(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.primary.opacity(0.045))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .overlay {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.title2)
                                    Text("Image unavailable")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(.secondary)
                            }
                    }

                case "link":
                    if let url = URL(string: attachment.linkURL) {
                        VStack(alignment: .leading, spacing: 7) {
                            Link(destination: url) {
                                RichLinkPreview(url: url)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 150)
                                    .clipShape(.rect(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)

                            Text(url.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .lineLimit(2)
                        }
                    }

                default:
                    HStack(spacing: 14) {
                        Image(systemName: fileSymbol(for: attachment.contentType))
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 46, height: 46)
                            .background(Color.primary.opacity(0.055), in: .rect(cornerRadius: 11))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(attachment.filename)
                                .font(.headline)
                                .lineLimit(2)
                            Text(fileKindLabel(for: attachment.contentType))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(Color.primary.opacity(0.045), in: .rect(cornerRadius: 16))
                }
            }

            attachmentDeleteButton(attachment)
                .padding(7)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }

    private func attachmentDeleteButton(_ attachment: IdeaAttachment) -> some View {
        Button {
            context.delete(attachment)
            idea.updated = .now
            _ = AwwPersistence.save(context)
        } label: {
            Image(systemName: "xmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Remove attachment")
    }

    private var noteAddMenu: some View {
        Menu {
            if UIImagePickerController
                .isSourceTypeAvailable(
                    .camera
                ) {
                Button(
                    "Take Photo",
                    systemImage: "camera"
                ) {
                    showingCamera = true
                }
            }

            Button(
                "Choose Photo",
                systemImage:
                    "photo.on.rectangle"
            ) {
                showingPhotoPicker = true
            }

            Button(
                "Choose Files",
                systemImage: "folder"
            ) {
                showingFileImporter = true
            }

            Button(
                "Paste from Clipboard",
                systemImage:
                    "doc.on.clipboard"
            ) {
                pasteIntoNote()
            }
        } label: {
            Image(systemName: "plus")
                .font(
                    .headline.weight(
                        .semibold
                    )
                )
        }
        .accessibilityLabel(
            "Add content"
        )
    }


    private func applyCategory(_ newCategory: String) {
        let cleaned = newCategory
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: .punctuationCharacters)
        guard !cleaned.isEmpty else { return }

        let textWithoutCurrentHashtag =
            removingCurrentHashtag(in: bodyText)

        let alreadyExists =
            hashtagCategoryValues(in: textWithoutCurrentHashtag)
                .contains {
                    $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame
                }

        if alreadyExists {
            bodyText = textWithoutCurrentHashtag
        } else {
            bodyText = replacingCurrentHashtag(
                in: bodyText,
                with: cleaned
            )
        }

        categories = uniqueCategoryValues(categories + [cleaned])
        try? AwwCategoryStore.assign(
            names: categories,
            to: idea,
            context: context
        )
        idea.updated = .now
        textFocusRequest &+= 1
        AwwHaptics.light()
        scheduleAutosave()
    }

    private func saveText() {
        let newTitle = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newCategories = categories
        let newCategoryValue = encodedCategoryValues(newCategories)
        let categoryChanged = idea.category != newCategoryValue

        let didChange =
            idea.title != newTitle
            || !idea.note.isEmpty
            || categoryChanged

        idea.ownerUserID = idea.ownerUserID ?? AwwIdentityCache.userID
        idea.personIDs = idea.personIDs?.isEmpty == false
            ? idea.personIDs
            : [person.id]
        idea.title = newTitle
        idea.note = ""
        categories = newCategories

        if categoryChanged {
            try? AwwCategoryStore.assign(
                names: newCategories,
                to: idea,
                context: context
            )
        }

        if didChange {
            idea.updated = .now
        }
    }

    private func savePrice() {
        let newPrice = AwwLocale.parseDecimal(priceDraft)

        if idea.price != newPrice {
            idea.price = newPrice
            idea.updated = .now
            scheduleAutosave()
        }
    }

    private func scheduleAutosave() {
        autosaveTask?.cancel()
        autosaveTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            _ = AwwPersistence.save(context)
        }
    }

    private func saveNow() {
        saveText()
        savePrice()

        if idea.status != status {
            idea.status = status
            idea.updated = .now
        }

        _ = AwwPersistence.save(context)
    }

    private func migrateLegacyImageIfNeeded() {
        guard let legacy = idea.image else { return }
        let alreadySaved = idea.attachments.contains {
            $0.kind == "image" && $0.data == legacy
        }

        if !alreadySaved {
            let attachment = IdeaAttachment(
                filename: "Photo",
                contentType: UTType.image.identifier,
                kind: "image",
                data: legacy,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }

        idea.image = nil
        _ = AwwPersistence.save(context)
    }

    private func ensureLinkAttachments(for text: String) {
        for url in detectedHTTPURLs(in: text) where isHTTPURL(url) {
            let exists = idea.attachments.contains {
                $0.kind == "link" && $0.linkURL == url.absoluteString
            }
            guard !exists else { continue }

            let attachment = IdeaAttachment(
                filename: url.host() ?? url.absoluteString,
                contentType: UTType.url.identifier,
                kind: "link",
                linkURL: url.absoluteString,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }
    }

    private func nextAttachmentDate() -> Date {
        let latest = idea.attachments.map(\.created).max() ?? .now
        return latest.addingTimeInterval(0.01)
    }

    private func insertImage(_ data: Data) {
        let attachment = IdeaAttachment(
            filename: "Photo",
            contentType: UTType.image.identifier,
            kind: "image",
            data: data,
            idea: idea
        )
        attachment.created = nextAttachmentDate()
        context.insert(attachment)
        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func importPhotos(_ photos: [PhotosPickerItem]) async {
        for photo in photos {
            guard let data = try? await photo.loadTransferable(type: Data.self) else { continue }
            await MainActor.run { insertImage(data) }
        }
        await MainActor.run { selectedPhotos.removeAll() }
    }

    private func importFiles(_ result: Result<[URL], any Error>) {
        guard case .success(let urls) = result else { return }

        for url in urls {
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else { continue }

            let type = UTType(filenameExtension: url.pathExtension)?.identifier
                ?? UTType.data.identifier
            let attachment = IdeaAttachment(
                filename: url.lastPathComponent,
                contentType: type,
                kind: "file",
                data: data,
                idea: idea
            )
            attachment.created = nextAttachmentDate()
            context.insert(attachment)
        }

        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func pasteIntoNote() {
        let pasteboard = UIPasteboard.general

        if let url = pasteboard.url, isHTTPURL(url) {
            appendURLToText(url)
            return
        }

        if let string = pasteboard.string {
            let urls = detectedHTTPURLs(in: string)
            if !urls.isEmpty {
                bodyText += bodyText.isEmpty ? string : "\n\(string)"
                ensureLinkAttachments(for: string)
                textFocusRequest &+= 1
                return
            }
        }

        if let image = pasteboard.image,
           let data = image.jpegData(compressionQuality: 0.9) {
            insertImage(data)
        }
    }

    private func appendURLToText(_ url: URL) {
        guard isHTTPURL(url) else { return }
        if !bodyText.contains(url.absoluteString) {
            bodyText += bodyText.isEmpty ? url.absoluteString : "\n\(url.absoluteString)"
        }
        ensureLinkAttachments(for: url.absoluteString)
        textFocusRequest &+= 1
    }

    private func moveAttachment(_ sourceID: UUID, before targetID: UUID) {
        guard sourceID != targetID else { return }
        var items = orderedAttachments
        guard let from = items.firstIndex(where: { $0.id == sourceID }),
              let to = items.firstIndex(where: { $0.id == targetID }) else {
            return
        }

        let item = items.remove(at: from)
        let insertion = from < to ? max(0, to - 1) : to
        items.insert(item, at: insertion)

        let base = items.map(\.created).min() ?? .now
        for (index, attachment) in items.enumerated() {
            attachment.created = base.addingTimeInterval(Double(index) * 0.01)
        }
        idea.updated = .now
        _ = AwwPersistence.save(context)
    }

    private func fileSymbol(for contentType: String) -> String {
        guard let type = UTType(contentType) else { return "doc.fill" }
        if type.conforms(to: .pdf) { return "doc.richtext.fill" }
        if type.conforms(to: .image) { return "photo.fill" }
        if type.conforms(to: .audio) { return "waveform" }
        if type.conforms(to: .movie) { return "play.rectangle.fill" }
        if type.conforms(to: .archive) { return "archivebox.fill" }
        return "doc.fill"
    }

    private func fileKindLabel(for contentType: String) -> String {
        guard let type = UTType(contentType) else { return "File" }
        return type.localizedDescription ?? "File"
    }
}


struct RecentWishGroup: Identifiable {
    let id: UUID
    let idea: Idea
    var people: [Person]

    init(idea: Idea, people: [Person]) {
        id = idea.id
        self.idea = idea
        self.people = people
    }
}

private func recentWishContentKey(_ idea: Idea) -> String {
    [idea.title, idea.note, idea.category, idea.status]
        .map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
        }
        .joined(separator: "|")
}

struct WishCategorySummary: Identifiable {
    let id: UUID
    let name: String
    let count: Int
}

func wishCategorySummaries(
    from ideas: [Idea],
    categories: [Category]
) -> [WishCategorySummary] {
    let ownerID = AwwIdentityCache.userID
    let active = categories.filter {
        $0.deletedAt == nil
        && (ownerID == nil || $0.ownerUserID == ownerID)
    }

    let ideasByCategoryID = ideas.reduce(into: [UUID: Int]()) { counts, idea in
        guard idea.deletedAt == nil else { return }

        if let ids = idea.categoryIDs, !ids.isEmpty {
            for id in ids {
                counts[id, default: 0] += 1
            }
        } else {
            // One-time migration fallback for a legacy row that has not yet been
            // attached to Category UUIDs.
            for name in categoryValues(from: idea.category) {
                if let match = active.first(where: {
                    $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
                }) {
                    counts[match.id, default: 0] += 1
                }
            }
        }
    }

    return active.map { category in
        WishCategorySummary(
            id: category.id,
            name: category.name,
            count: ideasByCategoryID[category.id, default: 0]
        )
    }
    .sorted { first, second in
        if first.count == second.count {
            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
        return first.count > second.count
    }
}

struct RecentWishBubbleCard: View {
    let group: RecentWishGroup
    let action: () -> Void

    var body: some View {
        GiftMessageBubble(
            idea: group.idea,
            layout: .grid,
            footerPeople: group.people
        )
        .contentShape(.rect(cornerRadius: 21))
        .onTapGesture(perform: action)
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                action()
            }

            Menu("Move to status") {
                ForEach(IdeaStatus.allCases) { status in
                    Button(status.title) {
                        group.idea.status = status.title
                        group.idea.updated = .now
                        AwwHaptics.selection()
                    }
                }
            }

            Button("Copy app link", systemImage: "link") {
                AwwDeepLink.copy(AwwDeepLink.wish(group.idea.id))
            }

            Button("Copy text", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = textToCopy
                AwwHaptics.success()
            }
        }
        .accessibilityLabel("Recently added wish")
        .accessibilityHint("Opens the saved wish. Long press for options.")
    }

    private var textToCopy: String {
        if !group.idea.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return group.idea.note
        }

        return displayTextWithoutCategoryHashtags(group.idea.title)
    }
}

struct CategoriesView: View {
    @Environment(\.modelContext)
    private var context

    @Query(sort: \Idea.updated, order: .reverse)
    private var ideas: [Idea]

    @Query(sort: \Category.createdAt)
    private var categoryRecords: [Category]

    @State private var selectedCategoryRoute: CategorySheetRoute?
    @State private var summariesCache: [WishCategorySummary] = []
    @State private var categoryToRenameID: UUID?
    @State private var renameText = ""
    @State private var categoryToDeleteID: UUID?
    @State private var categoryError = ""

    private var summaries: [WishCategorySummary] {
        summariesCache
    }

    var body: some View {
        Group {
            if summaries.isEmpty {
                ContentUnavailableView(
                    "No categories yet",
                    systemImage: "number",
                    description: Text("Add #categories to wishes and they’ll appear here.")
                )
            } else {
                List {
                    ForEach(summaries) { summary in
                        categoryRow(summary)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    categoryToDeleteID = summary.id
                                    AwwHaptics.warning()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    beginRename(summary)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Backdrop())
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedCategoryRoute) { route in
            if let categoryID = route.categoryID {
                CategoryWishesSheet(categoryID: categoryID, fallbackName: route.fallbackName)
            } else if let legacyName = route.legacyName {
                CategoryWishesSheet(category: legacyName)
            }
        }
        .alert(
            "Rename category",
            isPresented: Binding(
                get: { categoryToRenameID != nil },
                set: { if !$0 { categoryToRenameID = nil } }
            )
        ) {
            TextField("Category name", text: $renameText)

            Button("Cancel", role: .cancel) {
                categoryToRenameID = nil
            }

            Button("Rename") {
                renameSelectedCategory()
            }
            .disabled(
                renameText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        } message: {
            Text("The category keeps the same ID. Wishes do not move or get recreated.")
        }
        .confirmationDialog(
            "Delete category?",
            isPresented: Binding(
                get: { categoryToDeleteID != nil },
                set: { if !$0 { categoryToDeleteID = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete category", role: .destructive) {
                deleteSelectedCategory()
            }

            Button("Cancel", role: .cancel) {
                categoryToDeleteID = nil
            }
        } message: {
            Text("Only the category relationship is removed. Wishes, notes, photos, and links stay exactly where they are.")
        }
        .alert(
            "Couldn’t update category",
            isPresented: Binding(
                get: { !categoryError.isEmpty },
                set: { if !$0 { categoryError = "" } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(categoryError)
        }
        .onAppear(perform: refreshSummaries)
        .onReceive(
            NotificationCenter.default.publisher(for: .awwDataDidChange)
        ) { _ in
            refreshSummaries()
        }
        .onChange(of: categoryRecords.count) { _, _ in
            refreshSummaries()
        }
    }

    private func categoryRow(_ summary: WishCategorySummary) -> some View {
        Button {
            selectedCategoryRoute = CategorySheetRoute(categoryID: summary.id, name: summary.name)
            AwwHaptics.selection()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "number")
                    .foregroundStyle(.red)

                Text(summary.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(summary.count, format: .number)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Rename", systemImage: "pencil") {
                beginRename(summary)
            }

            Button("Copy app link", systemImage: "link") {
                AwwDeepLink.copy(AwwDeepLink.category(summary.id))
            }

            Button("Delete category", systemImage: "trash", role: .destructive) {
                categoryToDeleteID = summary.id
                AwwHaptics.warning()
            }
        }
    }

    private func beginRename(_ summary: WishCategorySummary) {
        categoryToRenameID = summary.id
        renameText = summary.name
        AwwHaptics.selection()
    }

    private func renameSelectedCategory() {
        guard let categoryID = categoryToRenameID else { return }
        let newName = renameText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#|"))
        guard !newName.isEmpty else { return }

        do {
            try AwwCategoryStore.rename(
                categoryID: categoryID,
                to: newName,
                context: context
            )
            try context.save()
            categoryToRenameID = nil
            renameText = ""
            AwwHaptics.success()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            refreshSummaries()
        } catch {
            categoryError = error.localizedDescription
        }
    }

    private func deleteSelectedCategory() {
        guard let categoryID = categoryToDeleteID else { return }

        do {
            try AwwCategoryStore.delete(
                categoryID: categoryID,
                context: context
            )
            try context.save()
            categoryToDeleteID = nil
            AwwHaptics.deleted()
            NotificationCenter.default.post(name: .awwDataDidChange, object: nil)
            refreshSummaries()
        } catch {
            categoryError = error.localizedDescription
        }
    }

    private func refreshSummaries() {
        summariesCache = wishCategorySummaries(
            from: ideas,
            categories: categoryRecords
        )
    }
}

struct CategoryWishesSheet: View {
    private let categoryID: UUID?
    private let fallbackCategoryName: String?
    private let legacyCategoryName: String?

    @Environment(\.dismiss)
    private var dismiss

    @Query(sort: \Idea.updated, order: .reverse)
    private var ideas: [Idea]

    @Query(sort: \Category.updatedAt, order: .reverse)
    private var categoryRecords: [Category]

    @State private var editingIdea: Idea?
    @State private var matchingIdeasCache: [Idea] = []

    init(categoryID: UUID, fallbackName: String? = nil) {
        self.categoryID = categoryID
        self.fallbackCategoryName = fallbackName
        self.legacyCategoryName = nil
    }

    // Compatibility initializer for older navigation call sites. The sheet resolves
    // the string to a stable Category UUID as soon as the migrated row exists.
    init(category: String) {
        if let id = UUID(uuidString: category) {
            self.categoryID = id
            self.fallbackCategoryName = nil
            self.legacyCategoryName = nil
        } else {
            self.categoryID = nil
            self.fallbackCategoryName = category
            self.legacyCategoryName = category
        }
    }

    private var resolvedCategory: Category? {
        if let categoryID {
            return categoryRecords.first {
                $0.id == categoryID && $0.deletedAt == nil
            }
        }

        guard let legacyCategoryName else { return nil }
        return categoryRecords.first {
            $0.deletedAt == nil
            && $0.name.localizedCaseInsensitiveCompare(legacyCategoryName) == .orderedSame
        }
    }

    private var displayName: String {
        resolvedCategory?.name
            ?? fallbackCategoryName
            ?? legacyCategoryName
            ?? "Category"
    }

    private var matchingIdeas: [Idea] {
        matchingIdeasCache
    }

    var body: some View {
        NavigationStack {
            categoryList
                .background(Backdrop())
                .navigationTitle("#\(displayName)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .sheet(item: $editingIdea) { idea in
                    categoryEditor(for: idea)
                }
                .onAppear(perform: refreshMatchingIdeas)
                .onReceive(
                    NotificationCenter.default.publisher(for: .awwDataDidChange)
                ) { _ in
                    refreshMatchingIdeas()
                }
                .onChange(of: categoryRecords.count) { _, _ in
                    refreshMatchingIdeas()
                }
        }
    }

    private var categoryList: some View {
        ScrollView {
            if matchingIdeas.isEmpty {
                ContentUnavailableView(
                    "Nothing in #\(displayName) yet",
                    systemImage: "number",
                    description: Text("Add #\(displayName) to a wish and it will appear here.")
                )
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(matchingIdeas) { idea in
                        categoryWishRow(idea)
                    }
                }
                .padding(20)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func refreshMatchingIdeas() {
        if let id = resolvedCategory?.id {
            matchingIdeasCache = ideas.filter { idea in
                guard idea.deletedAt == nil else { return false }

                if idea.categoryIDs?.contains(id) == true {
                    return true
                }

                // Legacy local rows can still have only the old category string
                // until their ID relationships are migrated. Never show a blank
                // category sheet just because that migration has not run yet.
                if idea.categoryIDs?.isEmpty != false {
                    return categoryValue(idea.category, contains: displayName)
                }

                return false
            }
        } else {
            matchingIdeasCache = ideas.filter {
                $0.deletedAt == nil
                && categoryValue($0.category, contains: displayName)
            }
        }
    }

    @ViewBuilder
    private func categoryWishRow(_ idea: Idea) -> some View {
        if let person = idea.person {
            Button {
                editingIdea = idea
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(person.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    GiftMessageBubble(idea: idea)
                }
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func categoryEditor(for idea: Idea) -> some View {
        if let person = idea.person {
            WishDetail(person: person, idea: idea)
        }
    }
}


