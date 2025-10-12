import SwiftUI

struct SummaryView: View {
    @State private var weekDone: [Bool] = [false, true, true, false, true, false, false]
    @State private var heatmap: [[Bool]] = PrayerHeatmapCard.sampleMatrix(cols: 28)

    // Layout knobs
    private let sidePadding: CGFloat = 24    
    private let gapBelowHeading: CGFloat = 14
    private let chipSpacing: CGFloat = 16
    private let chipHeight: CGFloat = 100

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 22)

                    Text("Summary")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, sidePadding)
                        .padding(.bottom, gapBelowHeading)

                    // Three equal-width chips with generous side padding
                    GeometryReader { geo in
                        let columns = 3
                        let width = (geo.size.width - chipSpacing * CGFloat(columns - 1)) / CGFloat(columns)

                        HStack(spacing: chipSpacing) {
                            MetricChip(title: "Today Completed", value: "0 / 5")
                                .frame(width: width, height: chipHeight)
                            MetricChip(title: "Streak", value: "7 days", subtitle: "Best 12")
                                .frame(width: width, height: chipHeight)
                            MetricChip(title: "On-time %", value: "68%")
                                .frame(width: width, height: chipHeight)
                        }
                    }
                    .frame(height: chipHeight)
                    .padding(.horizontal, sidePadding)

                    SectionHeader("7 Day Trend")
                        .padding(.horizontal, sidePadding)

                    TrendWeekCard(weekDone: weekDone, highlightIndex: nil)
                        .padding(.horizontal, sidePadding)

                    SectionHeader("Prayer Trends")
                        .padding(.horizontal, sidePadding)

                    PrayerHeatmapCard(matrix: heatmap)
                        .padding(.horizontal, sidePadding)

                    Spacer(minLength: 24)
                }
            }
        }
    }
}
