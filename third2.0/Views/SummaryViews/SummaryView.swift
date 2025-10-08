import SwiftUI

struct SummaryView: View {
    // demo data
    @State private var weekDone: [Bool] = [false, true, true, false, true, false, false]
    @State private var heatmap: [[Bool]] = PrayerHeatmapCard.sampleMatrix(cols: 28)

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // match Browse top breathing room
                    Spacer().frame(height: 22)

                    // Large title (same as Browse)
                    Text("Summary")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 20)

                    // Metric chips (compact) — align with 20pt
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            MetricChip(title: "Today Completed", value: "3 / 5", icon: "checkmark.circle.fill")
                            MetricChip(title: "Streak", value: "7 days", icon: "flame.fill", subtitle: "Best 12")
                            MetricChip(title: "On-time %", value: "68%", icon: "clock.fill")
                        }
                        .padding(.horizontal, 20)
                    }

                    // Section + card (use 20 for header, 16 for card — like Browse)
                    SectionHeader("7 Day Trend")
                    TrendWeekCard(
                        weekDone: weekDone,
                        highlightIndex: Calendar.current.component(.weekday, from: Date()) - 1
                    )
                    .padding(.horizontal, 16)

                    SectionHeader("Prayer Trends")
                    PrayerHeatmapCard(matrix: heatmap)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
