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

// MARK: - Wish Search

struct WishSearch: View {
    private struct SearchRecord: Sendable {
        let id: UUID
        let haystack: String
    }

    @Query(sort: \Idea.created, order: .reverse)
    private var ideas: [Idea]

    @State private var query = ""
    @State private var searchIndex: [SearchRecord] = []
    @State private var ideaByID: [UUID: Idea] = [:]
    @State private var resultIDs: [UUID] = []
    @State private var hasCompletedSearch = false
    @State private var searchTask: Task<Void, Never>?

    @Environment(\.dismiss)
    private var dismiss

    private var matchingIdeas: [Idea] {
        resultIDs.compactMap { ideaByID[$0] }
    }

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ContentUnavailableView(
                        "Search saved wishes",
                        systemImage: "magnifyingglass",
                        description: Text("Search by wish, note, category, or person.")
                    )
                } else if hasCompletedSearch && matchingIdeas.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    ForEach(matchingIdeas) { idea in
                        WishSearchResult(idea: idea)
                    }
                }
            }
            .navigationTitle("Search wishes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search every person's wishes")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: rebuildSearchIndex)
            .onChange(of: query) { _, newValue in
                scheduleSearch(for: newValue)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .awwDataDidChange)
            ) { _ in
                rebuildSearchIndex()
                scheduleSearch(for: query)
            }
            .onDisappear {
                searchTask?.cancel()
            }
        }
    }

    private func rebuildSearchIndex() {
        ideaByID = Dictionary(
            uniqueKeysWithValues: ideas.map { ($0.id, $0) }
        )

        searchIndex = ideas.map { idea in
            SearchRecord(
                id: idea.id,
                haystack: [
                    idea.title,
                    idea.note,
                    idea.category,
                    idea.person?.name ?? ""
                ]
                .joined(separator: "\n")
                .folding(
                    options: [.caseInsensitive, .diacriticInsensitive],
                    locale: .current
                )
            )
        }
    }

    private func scheduleSearch(for rawQuery: String) {
        searchTask?.cancel()

        let needle = rawQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive],
                locale: .current
            )

        guard !needle.isEmpty else {
            resultIDs = []
            hasCompletedSearch = false
            return
        }

        let records = searchIndex
        hasCompletedSearch = false

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(160))
            guard !Task.isCancelled else { return }

            let ids = await Task.detached(priority: .userInitiated) {
                Array(
                    records.lazy
                        .filter { $0.haystack.contains(needle) }
                        .prefix(AwwAppLimits.searchResultLimit)
                        .map(\.id)
                )
            }.value

            guard !Task.isCancelled else { return }
            resultIDs = ids
            hasCompletedSearch = true
        }
    }
}


struct WishSearchResult: View {
    let idea: Idea

    var body: some View {
        Group {
            if let person = idea.person {
                NavigationLink {
                    Detail(person: person)
                } label: {
                    row
                }
            } else {
                row
            }
        }
    }

    private var row: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(idea.title)
                .font(.headline)

            Text(idea.person?.name ?? "Unknown person")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !idea.note.isEmpty {
                Text(idea.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

enum WishDisplayStyle: String, CaseIterable, Identifiable {
    case grid
    case list

    var id: Self { self }

    var title: String {
        switch self {
        case .grid:
            return "Grid"
        case .list:
            return "List"
        }
    }

    var symbol: String {
        switch self {
        case .grid:
            return "square.grid.2x2"
        case .list:
            return "list.bullet"
        }
    }
}

struct GiftGridHeader: View {
    let search: () -> Void

    @Binding
    var selectedStatus: IdeaStatus?

    @Binding
    var displayStyle: WishDisplayStyle

    private var isCustomized: Bool {
        selectedStatus != nil || displayStyle != .grid
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("Wishes")
                .font(.title2.weight(.bold))

            Spacer()

            Button(action: search) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Search wishes")

            Menu {
                Menu(
                    "Status",
                    systemImage: "line.3.horizontal.decrease"
                ) {
                    Button {
                        selectedStatus = nil
                    } label: {
                        if selectedStatus == nil {
                            Label("All wishes", systemImage: "checkmark")
                        } else {
                            Text("All wishes")
                        }
                    }

                    Divider()

                    ForEach(IdeaStatus.allCases) { status in
                        Button {
                            selectedStatus = status
                        } label: {
                            if selectedStatus == status {
                                Label(status.title, systemImage: "checkmark")
                            } else {
                                Text(status.title)
                            }
                        }
                    }
                }

                Menu(
                    "View",
                    systemImage: displayStyle.symbol
                ) {
                    ForEach(WishDisplayStyle.allCases) { style in
                        Button {
                            displayStyle = style
                        } label: {
                            if displayStyle == style {
                                Label(style.title, systemImage: "checkmark")
                            } else {
                                Label(style.title, systemImage: style.symbol)
                            }
                        }
                    }
                }

                if isCustomized {
                    Divider()

                    Button("Reset view", systemImage: "arrow.counterclockwise") {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedStatus = nil
                            displayStyle = .grid
                        }
                        AwwHaptics.selection()
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.bold))
                    .foregroundStyle(isCustomized ? Color.red : Color.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        isCustomized
                            ? Color.red.opacity(0.11)
                            : Color.primary.opacity(0.055),
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                isCustomized
                                    ? Color.red.opacity(0.22)
                                    : Color.primary.opacity(0.08),
                                lineWidth: 1
                            )
                    }
                    .animation(.snappy(duration: 0.2), value: isCustomized)
            }
            .accessibilityLabel(
                isCustomized ? "Wish options, customized" : "Wish options"
            )
        }
    }
}
