//
//  PrayerHeatmapViewModel.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//


import Foundation

final class PrayerHeatmapViewModel {
    // Public constants used by the View
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

    func isSunday(column c: Int) -> Bool {
        let d = dateForColumn(c)
        return calendar.component(.weekday, from: d) == 1 // Sun
    }

    func buildMatrix(allDays: [PrayerDay]) -> [[Bool]] {
        let map = Self.mapByKey(allDays)
        let cols = daysInMonth
        var matrix = Array(
            repeating: Array(repeating: false, count: cols),
            count: prayers.count
        )

        for r in 0..<prayers.count {
            let prayer = prayers[r]
            for c in 0..<cols {
                let dayDate = dateForColumn(c)
                let key = PrayerDay.key(for: dayDate)
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
