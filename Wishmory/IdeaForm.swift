import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Idea Form

enum IdeaStatus: String, CaseIterable, Identifiable {
    case wouldLove = "Would love"
    case mostWanted = "Most wanted"
    case given = "Given"

    var id: Self { self }

    var title: String { rawValue }
}

struct IdeaForm: View {
    let person: Person
    let idea: Idea?

    @Query
    private var ideas: [Idea]

    @Environment(\.modelContext)
    private var context

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var title: String

    @State
    private var note: String

    @State
    private var price: String

    @State
    private var category: String

    @State
    private var status: String

    @State
    private var duplicate = false

    @State
    private var showingPriceField = false

    @State
    private var showingCategoryMenu = false

    @State private var showDiscardChanges = false
    @State private var didSave = false
    @State private var showSaveError = false

    @FocusState
    private var isComposerFocused: Bool

    init(person: Person, idea: Idea? = nil) {
        self.person = person
        self.idea = idea
        _title = State(initialValue: idea?.title ?? "")
        _note = State(initialValue: idea?.note ?? "")
        _price = State(
            initialValue: idea?.price.map(AwwLocale.decimalString) ?? ""
        )
        _category = State(initialValue: idea?.category ?? "")
        _status = State(initialValue: idea?.status ?? "Would love")
        _showingPriceField = State(initialValue: idea?.price != nil)
    }

    private let statuses = [
        "Would love",
        "Most wanted",
        "Given"
    ]

    private var hasUnsavedChanges: Bool {
        guard !didSave else { return false }
        if let idea {
            return title != idea.title || note != idea.note
                || price != (idea.price.map(AwwLocale.decimalString) ?? "")
                || category != idea.category || status != idea.status
        }
        return !cleanTitle.isEmpty || !note.isEmpty || !price.isEmpty || !category.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                recipientHeader

                Spacer(minLength: 0)

                composer
                    .frame(maxWidth: AwwAppLimits.composerMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .background(Backdrop())
            .navigationTitle(idea == nil ? "New gift" : "Edit gift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasUnsavedChanges {
                            AwwHaptics.warning()
                            showDiscardChanges = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .confirmationDialog("Choose a category", isPresented: $showingCategoryMenu) {
                ForEach(existingCategories, id: \.self) { existingCategory in
                    Button(existingCategory) {
                        category = existingCategory
                    }
                }

                if !category.isEmpty {
                    Button("Remove category", role: .destructive) {
                        category = ""
                    }
                }
            } message: {
                Text("Type # followed by a category in your gift idea to create a new one.")
            }
            .onChange(of: title) { _, newTitle in
                updateCategoryFromHashtag(in: newTitle)
            }
            .interactiveDismissDisabled(hasUnsavedChanges)
            .alert("Discard unsaved changes?", isPresented: $showDiscardChanges) {
                Button("Keep editing", role: .cancel) {}
                Button("Discard", role: .destructive) { dismiss() }
            } message: {
                Text("Your unsaved gift idea will be lost.")
            }
            .alert("Couldn’t save this wish", isPresented: $showSaveError) {
                Button("Try again") { save() }
                Button("Keep editing", role: .cancel) {}
            } message: {
                Text("Your draft is still here. Nothing was intentionally removed.")
            }
            .alert("Looks familiar", isPresented: $duplicate) {
                Button(
                    "Save anyway"
                ) {
                    save()
                }

                Button(
                    "Cancel",
                    role: .cancel
                ) {}
            } message: { Text("This may already be saved on this profile.") }
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField(
                "Add a gift idea… #category",
                text: $title,
                axis: .vertical
            )
            .font(.body)
            .lineLimit(1...4)
            .focused($isComposerFocused)

            if isComposerFocused || !note.isEmpty {
                TextField(
                    "Add a note (optional)",
                    text: $note,
                    axis: .vertical
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1...3)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if showingPriceField {
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            composerControls
        }
        .padding(14)
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.primary.opacity(0.06))
        }
        .animation(.snappy, value: isComposerFocused)
        .animation(.snappy, value: showingPriceField)
    }

    private var recipientHeader: some View {
        HStack(spacing: 12) {
            Avatar(person: person, size: 42)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Adding to \(person.name)’s list")
                        .font(.headline)

                    WishCountBadge(
                        count: person.ideas.count,
                        avatarSize: 48
                    )
                }

                Text("Use # to add a category as you type.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    private var composerControls: some View {
        HStack(spacing: 8) {
            Button {
                showingPriceField.toggle()
            } label: {
                Label(price.isEmpty ? "Price" : price, systemImage: "tag")
            }
            .buttonStyle(.bordered)

            Button {
                showingCategoryMenu = true
            } label: {
                Label(category.isEmpty ? "Category" : "#\(category)", systemImage: "number")
            }
            .buttonStyle(.bordered)

            Menu {
                Picker("Status", selection: $status) {
                    ForEach(statuses, id: \.self) { state in
                        Text(state)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .frame(width: 36, height: 36)
            }

            Spacer(minLength: 0)

            Button(action: checkForDuplicate) {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .frame(width: 42, height: 42)
                    .background(.red, in: Circle())
                    .foregroundStyle(.white)
            }
            .disabled(cleanTitle.isEmpty)
            .accessibilityLabel("Save gift idea")
        }
    }

    private var existingCategories: [String] {
        Array(Set(ideas.map(\.category).filter { !$0.isEmpty })).sorted()
    }

    private var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func updateCategoryFromHashtag(in value: String) {
        guard let hashtag = value.split(whereSeparator: \.isWhitespace).last(where: { $0.hasPrefix("#") && $0.count > 1 }) else {
            return
        }

        category = hashtag.dropFirst().trimmingCharacters(in: .punctuationCharacters)
    }

    private func checkForDuplicate() {
        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let alreadyExists =
            person.ideas.contains {
                $0.title
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                    .localizedCaseInsensitiveCompare(
                        cleanTitle
                    )
                    == .orderedSame
            }

        if alreadyExists {
            duplicate = true
        } else {
            save()
        }
    }

    private func save() {
        let cleanTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if let idea {
            idea.ownerUserID = idea.ownerUserID ?? AwwIdentityCache.userID
            idea.personIDs = idea.personIDs?.isEmpty == false
                ? idea.personIDs
                : [person.id]
            idea.title = cleanTitle
            idea.note = note
            idea.price = AwwLocale.parseDecimal(price)
            idea.status = status
            try? AwwCategoryStore.assign(
                names: categoryValues(from: category),
                to: idea,
                context: context
            )
            idea.updated = .now
        } else {
            let newIdea = Idea(
                cleanTitle,
                note: note,
                price: AwwLocale.parseDecimal(price),
                category: category,
                status: status,
                person: person,
                personIDs: [person.id],
                ownerUserID: AwwIdentityCache.userID
            )

            try? AwwCategoryStore.assign(
                names: categoryValues(from: category),
                to: newIdea,
                context: context
            )
            context.insert(newIdea)
        }

        guard AwwPersistence.save(context) else {
            AwwHaptics.warning()
            showSaveError = true
            return
        }

        didSave = true
        AwwHaptics.success()
        dismiss()
    }
}


