import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var today: [PrayerDay]
    @Query private var allDays: [PrayerDay]

    @State private var monthPage: Int = 0

    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14
    private let chipSpacing: CGFloat = 16
    private let chipHeight: CGFloat = 100

    private let heatmapHeight: CGFloat = 220
    private let dotsAllowance: CGFloat = 16

    init() {
        let key = PrayerDay.key(for: Date())
        _today = Query(filter: #Predicate<PrayerDay> { $0.dayKey == key }, sort: [])
        _allDays = Query(sort: [])
    }

    private var monthList: [Date] {
        let cal = Calendar.autoupdatingCurrent
        let todayMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!

        // Earliest month from saved data (or fallback to current)
        let earliest = allDays.map { $0.date }.min() ?? Date()
        var start = cal.date(from: cal.dateComponents([.year, .month], from: earliest)) ?? todayMonth
        if start > todayMonth { start = todayMonth }

        var out: [Date] = []
        var cursor = start
        while cursor <= todayMonth {
            out.append(cursor)
            cursor = cal.date(byAdding: .month, value: 1, to: cursor)!
        }
        return out.isEmpty ? [todayMonth] : out
    }

    private func monthTitle(_ d: Date) -> String {
        let m = DateFormatter(); m.dateFormat = "LLLL"
        let y = DateFormatter(); y.dateFormat = "yy"
        return "\(m.string(from: d)) trends ’\(y.string(from: d))"
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 22)

                    Text("Progress analytics")
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

                    let weekDone = SummaryViewModel.weekDoneForCurrentWeek(allDays: allDays)
                    TrendWeekCard(weekDone: weekDone, highlightIndex: nil)
                        .padding(.horizontal, sidePadding)

                    if !monthList.isEmpty {
                        Text(monthTitle(monthList[min(monthPage, monthList.count - 1)]))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, sidePadding)
                            .padding(.top, 6)

                        TabView(selection: $monthPage) {
                            ForEach(Array(monthList.enumerated()), id: \.offset) { idx, month in
                                PrayerHeatmapCard(month: month)
                                    .tag(idx)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .frame(height: heatmapHeight + dotsAllowance) // keep dots snug under the card
                        .padding(.horizontal, sidePadding)
                        .clipped()
                        .onAppear {
                            monthPage = max(0, monthList.count - 1)
                        }
                    }

                    Spacer(minLength: 24)
                }
            }
        }
    }
}
