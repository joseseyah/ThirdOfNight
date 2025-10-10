import SwiftUI

struct ReminderRow: View {
    let title: String
    let subtitle: String
    let tint: Color
    var showDivider: Bool = true     // hide for the last row if you want

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Big rounded thumbnail like Tips
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.18))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "sun.max.fill") // swap if you pass an icon later
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(tint)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle()) // nicer tap target

            if showDivider {
                Divider()
                    .overlay(Color.stroke) // use your app stroke color
                    .padding(.leading, 20 + 60 + 16) // inset under the text, not the thumbnail
            }
        }
        .background(Color.clear) // no card/bg – flat list look
    }
}
