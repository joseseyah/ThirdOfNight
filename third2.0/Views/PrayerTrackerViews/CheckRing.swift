import SwiftUI

struct CompactCheckRing: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.04))
            Circle()
                .stroke(Color.stroke, lineWidth: 1.5)

            // animated progress ring
            Circle()
                .trim(from: 0, to: isOn ? 1 : 0)
                .stroke(
                    Color.accentYellow,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.18), value: isOn)

            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.appBg)
                    .padding(5)
                    .background(Circle().fill(Color.accentYellow))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 28, height: 28) // smaller
    }
}
