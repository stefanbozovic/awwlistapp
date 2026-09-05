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

func recentWishContentKey(_ idea: Idea) -> String {
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
    let layout: WishBubbleLayout
    let action: () -> Void

    var body: some View {
        GiftMessageBubble(
            idea: group.idea,
            layout: layout,
            footerPeople: group.people
        )
        .frame(maxWidth: .infinity, alignment: .leading)
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

