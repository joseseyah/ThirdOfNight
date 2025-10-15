import SwiftUI
import SwiftData

struct SummaryView: View {
    // SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query private var today: [PrayerDay]   // we expect 0 or 1 because dayKey is unique

    // UI state (demo data you already had)
    @State private var weekDone: [Bool] = [false, true, true, false, true, false, false]
    @State private var heatmap: [[Bool]] = PrayerHeatmapCard.sampleMatrix(cols: 28)

    // Layout knobs
    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14
    private let chipSpacing: CGFloat = 16
    private let chipHeight: CGFloat = 100

    // Init the @Query with today's key
    init() {
        let key = PrayerDay.key(for: Date())
        _today = Query(filter: #Predicate<PrayerDay> { $0.dayKey == key }, sort: [])
    }

    // Derived values
    private var todayCompletedCount: Int {
        // Count how many prayers are marked true in today's record
        guard let record = today.first else { return 0 }
        return record.completed.values.filter { $0 }.count
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 22)

                    Text("Summary")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .fontWidth(.condensed) // iOS 17+
                        .tracking(-0.2)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, sidePadding)
                        .padding(.bottom, gapBelowHeading)


                    // Three equal-width chips with generous side padding
                    GeometryReader { geo in
                        let columns = 3
                        let width = (geo.size.width - chipSpacing * CGFloat(columns - 1)) / CGFloat(columns)

                        HStack(spacing: chipSpacing) {
                            // LIVE value from SwiftData
                            MetricChip(title: "Today Completed", value: "\(todayCompletedCount) / 5")
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
