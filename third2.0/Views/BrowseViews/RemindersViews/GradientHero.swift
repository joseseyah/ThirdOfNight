import SwiftUI

struct GradientHero: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var baseHeight: CGFloat = 260

    var body: some View {
        StretchyHeader(baseHeight: baseHeight) { h in
            // Background
            LinearGradient(
                colors: [
                    Color.accentYellow.opacity(0.35),
                    Color.appBg.opacity(0.0),
                    Color.accentYellow.opacity(0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    colors: [Color.accentYellow.opacity(0.35), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: h * 0.8
                )
            )
            .background(Color.appBg)
        } content: { _, _ in
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.appBg)
                    .padding(18)
                    .background(Circle().fill(Color.accentYellow))
                    .shadow(color: Color.accentYellow.opacity(0.35), radius: 16, x: 0, y: 6)

                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }
}
