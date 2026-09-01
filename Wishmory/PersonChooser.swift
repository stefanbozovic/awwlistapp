import SwiftUI

struct PersonChooser: View {
    let people: [Person]

    @Binding
    var recipient: Person?

    @Environment(\.dismiss)
    private var dismiss

    private var sortedPeople: [Person] {
        people.sorted { first, second in
            if first.isOwner != second.isOwner {
                return first.isOwner
            }

            return first.created < second.created
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(
                    "Save this wish for"
                ) {
                    ForEach(
                        sortedPeople
                    ) { person in
                        Button {
                            choose(person)
                        } label: {
                            HStack(
                                spacing: 12
                            ) {
                                Avatar(
                                    person: person,
                                    size: 42
                                )

                                VStack(
                                    alignment:
                                        .leading,
                                    spacing: 2
                                ) {
                                    HStack(spacing: 5) {
                                        Text(
                                            person.name
                                        )
                                        .font(
                                            .body
                                                .weight(
                                                    person.isOwner
                                                    ? .semibold
                                                    : .regular
                                                )
                                        )

                                        WishCountBadge(
                                            count: person.ideas.count,
                                            avatarSize: 48
                                        )
                                    }
                                    .foregroundStyle(
                                        .primary
                                    )

                                    Text(
                                        person.countdown
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                                }

                                Spacer()

                                Image(
                                    systemName:
                                        "chevron.right"
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .tertiary
                                )
                            }
                            .contentShape(
                                Rectangle()
                            )
                        }
                    }
                }
            }
            .navigationTitle(
                "Choose profile"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {
                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func choose(
        _ person: Person
    ) {
        dismiss()

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25
        ) {
            recipient = person
        }
    }
}
