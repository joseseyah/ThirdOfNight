import SwiftUI

struct CardContainer<Content: View>: View {
    @ViewBuilder var content: Content
    var corner: CGFloat = 16

    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(LinearGradient(colors: [Color.cardBg, Color.cardBg.opacity(0.95)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(Color.stroke, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 5)
    }
}

struct SectionHeader: View {
    let title: String
    init(_ t: String) { title = t }
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.textSecondary)
            .padding(.top, 2)
    }
}
