import SwiftUI
import SwiftData

struct PrayerHeatmapCard: View {
    // Pull all saved days; we’ll map them by key
    @Query private var allDays: [PrayerDay]

    // Rows (keep your casing; lookup is case-insensitive)
    private let prayers = ["FAJR","DHUHR","ASR","MAGHRIB","ISHA"]

    // Layout knobs
    private let labelWidth: CGFloat = 64
    private let cellSize: CGFloat   = 12
    private let rowSpacing: CGFloat = 8
    private let colSpacing: CGFloat = 5
    private let weekGapSize: CGFloat = 6
    private let showWeekGaps: Bool = true

    // Which month to display (defaults to now)
    private let monthAnchor: Date
    private let calendar: Calendar = .autoupdatingCurrent

    init(month: Date = Date()) {
        self.monthAnchor = month
        _allDays = Query(sort: [])
    }

    // MARK: - Body
    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: 12) {
                // Labels column
                VStack(alignment: .leading, spacing: rowSpacing) {
                    ForEach(0..<prayers.count, id: \.self) { r in
                        Text(prayers[r])
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondary)
                            .frame(width: labelWidth, height: cellSize, alignment: .leading)
                    }
                }

                // Grid (one scroll for all rows)
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: rowSpacing) {
                        ForEach(0..<prayers.count, id: \.self) { r in
                            HStack(spacing: colSpacing) {
                                ForEach(0..<daysInMonth, id: \.self) { c in
                                    let isOn = cellValue(row: r, dayIndex: c)
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(isOn ? Color.accentYellow : Color.white.opacity(0.10))
                                        .frame(width: cellSize, height: cellSize)
                                        .shadow(color: isOn ? Color.accentYellow.opacity(0.25) : .clear,
                                                radius: isOn ? 4 : 0)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                .stroke(isOn ? Color.accentYellow.opacity(0.55) : Color.stroke,
                                                        lineWidth: isOn ? 0.5 : 0.8)
                                        )

                                    // Optional week gap: insert AFTER Sundays (Apple weekday=1)
                                    if showWeekGaps,
                                       isSunday(column: c),
                                       c != daysInMonth - 1 {
                                        Spacer().frame(width: weekGapSize)
                                    }
                                }
                            }
                            .frame(height: cellSize, alignment: .leading)
                        }
                    }
                    .padding(.trailing, 2)
                }
            }
        }
    }

    // MARK: - Month window
    private var startOfMonth: Date {
        let comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        return calendar.date(from: comps) ?? calendar.startOfDay(for: monthAnchor)
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }

    private func dateForColumn(_ c: Int) -> Date {
        calendar.date(byAdding: .day, value: c, to: startOfMonth) ?? startOfMonth
    }

    private func isSunday(column c: Int) -> Bool {
        let d = dateForColumn(c)
        return calendar.component(.weekday, from: d) == 1 // Sun
    }

    // MARK: - Data lookup
    private var dayByKey: [String: PrayerDay] {
        var map: [String: PrayerDay] = [:]
        for d in allDays { map[d.dayKey] = d }
        return map
    }

    private func cellValue(row r: Int, dayIndex c: Int) -> Bool {
        guard r >= 0, r < prayers.count else { return false }
        let dayDate = dateForColumn(c)
        let key = PrayerDay.key(for: dayDate)
        guard let record = dayByKey[key] else { return false }
        return value(for: prayers[r], in: record)
    }

    /// Case-insensitive read of a prayer flag from the record
    private func value(for prayer: String, in day: PrayerDay) -> Bool {
        if let v = day.completed[prayer] { return v }
        if let kv = day.completed.first(where: { $0.key.compare(prayer, options: .caseInsensitive) == .orderedSame }) {
            return kv.value
        }
        return false
    }
}
