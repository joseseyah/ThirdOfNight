import SwiftUI

struct MetricChip: View {
    let title: String
    let value: String
    let icon: String
    var subtitle: String? = nil

    var body: some View {
        CardContainer(corner: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.appBg)
                    .padding(8)
                    .background(Circle().fill(Color.accentYellow))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.textSecondary)
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .frame(width: 180)
    }
}
