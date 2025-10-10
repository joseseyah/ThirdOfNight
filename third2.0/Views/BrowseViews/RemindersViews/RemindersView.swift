import SwiftUI

struct RemindersView: View {
    let category: BrowseCategory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

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
                  GradientHero(
                                          title: "Fajr Reminders",
                                          subtitle: "Curated reminders and talks",
                                          systemImage: "sunrise.fill",
                                          baseHeight: 260// tweak until the icon clears your Back bar
                                      )

                    // Grouped list like Tips
                    VStack(spacing: 0) {
                        ForEach(items.indices, id: \.self) { i in
                            Button {
                                if let url = items[i].url { openURL(url) }
                            } label: {
                                ReminderRow(
                                    title: items[i].title,
                                    subtitle: items[i].subtitle,
                                    tint: category.tint
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if i < items.count - 1 {
                                Divider()
                                    .overlay(Color.stroke)
                                    .padding(.leading, 76)
                            }
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
            .scrollIndicators(.hidden)

            // Custom back button overlay (since we hide the system bar)
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.accentYellow)
                    }
                    Spacer()
                }
                .padding(.top, 6)
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Sample data
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
