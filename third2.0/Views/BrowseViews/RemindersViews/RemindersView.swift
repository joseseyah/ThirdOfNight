//
//  RemindersView.swift
//  Night Prayers
//

import SwiftUI

struct RemindersView: View {
    let category: BrowseCategory
    @Environment(\.openURL) private var openURL

    // Load items once during init so nothing becomes a Binding by accident
    @State private var items: [ReminderItem]

    init(category: BrowseCategory) {
        self.category = category
        _items = State(initialValue: RemindersView.sample(for: category.title))
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Gradient header (dark -> warm yellow glow)
                    GradientHero(
                        title: category.title,
                        subtitle: "Curated reminders and talks",
                        systemImage: category.systemImage
                    )

                    // Reminder rows
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(items) { item in
                            Button {
                                if let url = item.url { openURL(url) }
                            } label: {
                                ReminderRow(
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    tint: category.tint
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sample data (swap with your real source later)
private extension RemindersView {
    static func sample(for title: String) -> [ReminderItem] {
        switch title {
        case "Fajr Reminders":
            return [
                .init(
                    title: "Sleep early routine",
                    subtitle: "Practical tips to wake for Fajr consistently.",
                    url: URL(string: "https://youtube.com")
                ),
                .init(
                    title: "Fajr motivation",
                    subtitle: "Short reminder to start the day with barakah.",
                    url: URL(string: "https://youtube.com")
                )
            ]

        case "Jummah":
            return [
                .init(
                    title: "Virtues of Friday",
                    subtitle: "Hadith reminders and Sunnah actions.",
                    url: URL(string: "https://youtube.com")
                )
            ]

        default:
            return [
                .init(
                    title: "Recommended series",
                    subtitle: "A playlist you can follow across the week.",
                    url: URL(string: "https://youtube.com")
                )
            ]
        }
    }
}
