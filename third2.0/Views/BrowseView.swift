import SwiftUI

// MARK: - Model
struct BrowseCategory: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let tint: Color
}

// MARK: - View
struct BrowseView: View {
    private let categories: [BrowseCategory] = [
        .init(title: "Fajr Reminders", systemImage: "sun.and.horizon.fill", tint: .accentYellow),
        .init(title: "Jummah",         systemImage: "mappin.and.ellipse",   tint: .accentYellow.opacity(0.9)), // swap to custom mosque later
        .init(title: "Quran Series",   systemImage: "book.closed.fill",      tint: .accentYellow.opacity(0.9)),
        .init(title: "Dhikr & Duas",   systemImage: "hands.sparkles.fill",   tint: .accentYellow.opacity(0.9)),
        .init(title: "Charity",        systemImage: "heart.fill",            tint: .accentYellow.opacity(0.95)),
        .init(title: "Learning",       systemImage: "graduationcap.fill",    tint: .accentYellow.opacity(0.9))
    ]

    @State private var query = ""

    var body: some View {
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
                        ForEach(filtered(categories).indices, id: \.self) { i in
                            CategoryRow(item: filtered(categories)[i]) {
                                // TODO: navigate
                            }
                            if i < filtered(categories).count - 1 {
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
    }

    private func filtered(_ items: [BrowseCategory]) -> [BrowseCategory] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(q) }
    }
}

// MARK: - Components

/// A rounded container that groups rows together (like iOS Health)
private struct CategoryGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}

/// Thin insets divider
private struct GroupSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color.stroke)
            .frame(height: 1)
            .padding(.leading, 72)   // aligns under text, not under icon
            .padding(.trailing, 12)
    }
}

private struct CategoryRow: View {
    let item: BrowseCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon chip (small)
                ZStack {
                    Circle().fill(Color.white.opacity(0.06))
                    Image(systemName: item.systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appBg)
                        .padding(8)
                        .background(Circle().fill(item.tint))
                }
                .frame(width: 44, height: 44)

                Text(item.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical, 12)     // tighter row height
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct CompactSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            TextField("Search", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    BrowseView()
        .preferredColorScheme(.dark)
        .background(Color.appBg)
}
