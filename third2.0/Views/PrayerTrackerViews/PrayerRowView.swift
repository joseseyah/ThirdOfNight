import SwiftUI

struct PrayerRowView: View {
    let name: String
    let time: String
    let isDone: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                CompactCheckRing(isOn: isDone)

                Text(name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer(minLength: 8)

                // compact time badge
                Text(time)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                            .overlay(Capsule().stroke(Color.stroke, lineWidth: 1))
                    )
            }
            .padding(.vertical, 10)   // smaller height
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.cardBg, Color.cardBg.opacity(0.9)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // keep that nice outline: yellow when done, thin neutral otherwise
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isDone ? Color.accentYellow.opacity(0.65) : Color.stroke, lineWidth: 1)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .animation(.spring(response: 0.22, dampingFraction: 0.9), value: isDone)
        }
        .buttonStyle(CompactPressStyle())
    }
}

// MARK: - Smaller check control with outline animation


// MARK: - Subtle press feedback (scale + highlight outline)
private struct CompactPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(configuration.isPressed ? Color.accentYellow.opacity(0.35) : .clear, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
