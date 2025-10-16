import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var today: [PrayerDay]
    @Query private var allDays: [PrayerDay]

    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14
    private let chipSpacing: CGFloat = 16
    private let chipHeight: CGFloat = 100

    init() {
        let key = PrayerDay.key(for: Date())
        _today = Query(filter: #Predicate<PrayerDay> { $0.dayKey == key }, sort: [])
        _allDays = Query(sort: [])
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 22)

                    Text("Summary")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .fontWidth(.condensed)
                        .tracking(-0.2)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, sidePadding)
                        .padding(.bottom, gapBelowHeading)

                    GeometryReader { geo in
                        let columns = 3
                        let width = (geo.size.width - chipSpacing * CGFloat(columns - 1)) / CGFloat(columns)

                        let todayCount = SummaryViewModel.todayCompletedCount(today: today)
                        let (currentStreak, bestStreak) = SummaryViewModel.streaks(allDays: allDays)
                        let onTime = SummaryViewModel.onTimeDisplay(allDays: allDays)

                        HStack(spacing: chipSpacing) {
                            MetricChip(title: "Today Completed", value: "\(todayCount) / 5")
                                .frame(width: width, height: chipHeight)

                            MetricChip(
                                title: "Streak",
                                value: "\(currentStreak) " + (currentStreak == 1 ? "day" : "days"),
                                subtitle: "Best \(bestStreak)"
                            )
                            .frame(width: width, height: chipHeight)

                            MetricChip(title: "On-time %", value: onTime)
                                .frame(width: width, height: chipHeight)
                        }
                    }
                    .frame(height: chipHeight)
                    .padding(.horizontal, sidePadding)

                    SectionHeader("7 Day Trend")
                        .padding(.horizontal, sidePadding)

                    // LIVE Monday→Sunday completion pulled from SwiftData
                    let weekDone = SummaryViewModel.weekDoneForCurrentWeek(allDays: allDays)
                    TrendWeekCard(weekDone: weekDone, highlightIndex: nil)
                        .padding(.horizontal, sidePadding)

                    SectionHeader("Monthly Trends")
                        .padding(.horizontal, sidePadding)

                    PrayerHeatmapCard() 
                        .padding(.horizontal, sidePadding)

                    Spacer(minLength: 24)
                }
            }
        }
    }
}
