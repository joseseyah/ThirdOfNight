import SwiftUI

struct MetricChip: View {
    let title: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimaryLight.opacity(0.9))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.textPrimaryLight)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.textSecondaryLight.opacity(0.9))
                    .lineLimit(1)
            } else {
                // keep vertical spacing consistent when there's no subtitle
                Text(" ").opacity(0)
            }

            Spacer(minLength: 0)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.accentPurple.opacity(0.2), Color.accentPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
    }
}
