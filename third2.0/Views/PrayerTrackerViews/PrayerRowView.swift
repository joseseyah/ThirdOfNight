import SwiftUI

extension Color {
    static let appBg        = Color(red: 0.04, green: 0.05, blue: 0.07)
    static let cardBg       = Color(red: 0.08, green: 0.10, blue: 0.13)
    static let stroke       = Color.white.opacity(0.12)
    static let textPrimary  = Color(white: 0.92)
    static let textSecondary = Color(white: 0.70)
    static let accentYellow = Color(red: 1.00, green: 0.83, blue: 0.25)
}

// MARK: - Model

struct PrayerItem: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    var done: Bool = false
}

struct PrayerRowView: View {
    let name: String
    let time: String
    let isDone: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                CheckRing(isOn: isDone)

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }

                Spacer(minLength: 12)

                // Right side time “badge”
                Text(time)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                Capsule().stroke(Color.stroke, lineWidth: 1)
                            )
                    )
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.cardBg, Color.cardBg.opacity(0.85)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isDone ? Color.accentYellow.opacity(0.6) : Color.stroke, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
            .shadow(color: isDone ? Color.accentYellow.opacity(0.25) : .clear, radius: 14, x: 0, y: 6)
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isDone)
        }
    }
}
