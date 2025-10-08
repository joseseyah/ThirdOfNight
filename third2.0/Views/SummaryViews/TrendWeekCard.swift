import SwiftUI

struct TrendWeekCard: View {
    let weekDone: [Bool]          // 7 items
    var highlightIndex: Int? = nil
    private let days = ["M","T","W","T","F","S","S"]

    var body: some View {
        CardContainer {
            HStack(spacing: 14) {
                ForEach(days.indices, id: \.self) { i in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().fill(Color.white.opacity(0.06))
                            if weekDone.indices.contains(i), weekDone[i] {
                                Circle().fill(Color.accentYellow)
                            }
                            if i == highlightIndex {
                                Circle().stroke(Color.accentYellow.opacity(0.7), lineWidth: 2)
                            }
                        }
                        .frame(width: 38, height: 38)

                        Text(days[i])
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
