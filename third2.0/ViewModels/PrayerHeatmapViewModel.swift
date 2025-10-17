//
//  PrayerHeatmapViewModel.swift
//  Night Prayers
//

import Foundation

struct HeatmapPrepared {
    /// rows = prayers, cols = days
    let matrix: [[Bool]]
    /// "1"..."<daysInMonth>"
    let dayLabels: [String]
    /// Whether to insert a visual week gap *after* this column index (0-based).
    let weekGapAfter: [Bool]
    /// Number of days in this month
    let daysInMonth: Int
}

final class PrayerHeatmapViewModel {
    let prayers = ["FAJR","DHUHR","ASR","MAGHRIB","ISHA"]

    // Month & calendar
    let monthAnchor: Date
    let calendar: Calendar

    init(month: Date = Date(), calendar: Calendar = .autoupdatingCurrent) {
        self.monthAnchor = month
        self.calendar = calendar
    }

    var startOfMonth: Date {
        let comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        return calendar.date(from: comps) ?? calendar.startOfDay(for: monthAnchor)
    }

    var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 30
    }

    func dateForColumn(_ c: Int) -> Date {
        calendar.date(byAdding: .day, value: c, to: startOfMonth) ?? startOfMonth
    }

    // MARK: - Public: one-shot data for the view (no logic left in UI)
    func preparedData(allDays: [PrayerDay]) -> HeatmapPrepared {
        let matrix = buildMatrix(allDays: allDays)
        let n = daysInMonth

        let labels = (1...n).map { String($0) }
        // Insert a week gap AFTER columns 6, 13, 20, 27... (0-based)
        let gapsAfter = (0..<n).map { idx in
            let dayNumber = idx + 1
            return (dayNumber % 7 == 0) && (dayNumber < n)
        }

        return HeatmapPrepared(
            matrix: matrix,
            dayLabels: labels,
            weekGapAfter: gapsAfter,
            daysInMonth: n
        )
    }

    // MARK: - Internals
    private func buildMatrix(allDays: [PrayerDay]) -> [[Bool]] {
        let map = Self.mapByKey(allDays)
        let cols = daysInMonth
        var matrix = Array(
            repeating: Array(repeating: false, count: cols),
            count: prayers.count
        )

        for r in 0..<prayers.count {
            let prayer = prayers[r]
            for c in 0..<cols {
                let key = PrayerDay.key(for: dateForColumn(c))
                if let record = map[key] {
                    matrix[r][c] = Self.value(for: prayer, in: record)
                }
            }
        }
        return matrix
    }

    private static func mapByKey(_ days: [PrayerDay]) -> [String: PrayerDay] {
        var m: [String: PrayerDay] = [:]
        for d in days { m[d.dayKey] = d }
        return m
    }

    private static func value(for prayer: String, in day: PrayerDay) -> Bool {
        if let v = day.completed[prayer] { return v }
        if let kv = day.completed.first(where: {
            $0.key.compare(prayer, options: .caseInsensitive) == .orderedSame
        }) {
            return kv.value
        }
        return false
    }
}
