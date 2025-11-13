import SwiftUI

struct MetricChip: View {
    let title: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        CardContainer(
            content: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    } else {
                        // keep vertical spacing consistent when there’s no subtitle
                        Text(" ").opacity(0)
                    }

                    Spacer(minLength: 0)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.vertical, 8)
            },
            corner: 14
        )
    }
}
