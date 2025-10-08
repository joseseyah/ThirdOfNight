import SwiftUI

// MARK: - Model
struct BrowseCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
}

// MARK: - View
struct BrowseView: View {
    private let categories: [BrowseCategory] = [
        .init(title: "Fajr Reminders", systemImage: "sun.and.horizon.fill", tint: .accentYellow),
        .init(title: "Jummah",         systemImage: "mappin.and.ellipse",   tint: .accentYellow.opacity(0.9)),
        .init(title: "Quran Series",   systemImage: "book.closed.fill",      tint: .accentYellow.opacity(0.9)),
        .init(title: "Dhikr & Duas",   systemImage: "hands.sparkles.fill",   tint: .accentYellow.opacity(0.9)),
        .init(title: "Charity",        systemImage: "heart.fill",            tint: .accentYellow.opacity(0.95)),
        .init(title: "Learning",       systemImage: "graduationcap.fill",    tint: .accentYellow.opacity(0.9))
    ]

    @State private var query = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Spacer().frame(height: 22)

                        // Large title
                        Text("Browse")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)

                        // Compact search
                        CompactSearchField(text: $query)
                            .padding(.horizontal, 20)

                        // Section header like iOS Health
                        Text("Categories")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 4)
                            .padding(.horizontal, 20)

                        // GROUPED CARD
                        CategoryGroup {
                            let list = filtered(categories)
                            ForEach(list.indices, id: \.self) { i in
                                NavigationLink(value: list[i]) {
                                    CategoryRow(item: filtered(categories)[i])

                                }
                                if i < list.count - 1 {
                                    GroupSeparator()
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 24)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(for: BrowseCategory.self) { cat in
                RemindersView(category: cat)
            }
            .toolbar(.hidden)
        }
    }

    private func filtered(_ items: [BrowseCategory]) -> [BrowseCategory] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }
}
