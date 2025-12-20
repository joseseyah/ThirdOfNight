//
//  SummaryViewModel.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//


import Foundation

final class SummaryViewModel {

    static func todayCompletedCount(today: [PrayerDay]) -> Int {
        guard let record = today.first else { return 0 }
        return record.completed.values.filter { $0 }.count
    }

    static func onTimeDisplay(allDays: [PrayerDay]) -> String {
        var done = 0
        var decided = 0

        // Exclude frozen days from statistics
        let nonFrozenDays = allDays.filter { !$0.isFrozen }

        for day in nonFrozenDays {
            let trues = day.completed.values.filter { $0 }.count
            let falses = day.completed.values.filter { !$0 }.count

            let dayDecided = trues + falses
            guard dayDecided > 0 else { continue }

            done    += trues
            decided += dayDecided
        }

        guard decided > 0 else { return "--%" }
        let pct = Double(done) / Double(decided) * 100.0
        return "\(Int(round(pct)))%"
    }


    static func streaks(allDays: [PrayerDay]) -> (current: Int, best: Int) {
        let calendar = Calendar.current
        // Exclude frozen days from streak calculations
        let nonFrozenDays = allDays.filter { !$0.isFrozen }
        let sorted = daysSortedByDate(allDays: nonFrozenDays)
        guard !sorted.isEmpty else { return (0, 0) }

        // Map to (date, isPerfect)
        let condensed: [(Date, Bool)] = sorted.compactMap { day in
            guard let date = date(fromKey: day.dayKey) else { return nil }
            let perfect = day.completed.values.filter { $0 }.count == 5
            return (date, perfect)
        }
        guard !condensed.isEmpty else { return (0, 0) }

        var best = 0
        var run = 0
        var prevDate: Date?

        for (date, perfect) in condensed {
            if perfect {
                if let p = prevDate,
                   let gap = calendar.dateComponents([.day], from: p, to: date).day,
                   gap == 1 {
                    run += 1
                } else {
                    run = 1
                }
                best = max(best, run)
            } else {
                run = 0
            }
            prevDate = date
        }

        var current = 0
        var lastDate = condensed.last!.0

        for (date, perfect) in condensed.reversed() {
            let isFirst = (date == lastDate)
            let diff = calendar.dateComponents([.day], from: date, to: lastDate).day ?? Int.max
            let contiguousBack = isFirst || diff == 0 || diff == 1

            if contiguousBack && perfect {
                current += 1
                lastDate = calendar.date(byAdding: .day, value: -1, to: lastDate) ?? lastDate
            } else if contiguousBack && !perfect {
                break
            } else {
                break
            }
        }

        return (current, best)
    }

    private static func lifetimeTotals(allDays: [PrayerDay]) -> (done: Int, possible: Int) {
        guard !allDays.isEmpty else { return (0, 0) }
        let done = allDays.reduce(0) { $0 + $1.completed.values.filter { $0 }.count }
        let possible = allDays.count * 5
        return (done, possible)
    }

    private static func daysSortedByDate(allDays: [PrayerDay]) -> [PrayerDay] {
        allDays.sorted { lhs, rhs in
            let ld = date(fromKey: lhs.dayKey) ?? .distantPast
            let rd = date(fromKey: rhs.dayKey) ?? .distantPast
            return ld < rd
        }
    }

    static func date(fromKey key: String) -> Date? {
        let fmts = ["yyyy-MM-dd", "yyyyMMdd"]
        for f in fmts {
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = f
            if let d = df.date(from: key) { return d }
        }
        return nil
    }

    static func weekDoneForCurrentWeek(allDays: [PrayerDay],
calendar: Calendar = .autoupdatingCurrent) -> [Bool] {
            // Exclude frozen days from weekly statistics
            let nonFrozenDays = allDays.filter { !$0.isFrozen }
            var map: [String: Int] = [:]
            for d in nonFrozenDays {
                map[d.dayKey] = d.completed.values.filter { $0 }.count
            }

            let today = Date()
            let startOfToday = calendar.startOfDay(for: today)

            let weekday = calendar.component(.weekday, from: startOfToday)
            let daysSinceMonday = (weekday + 5) % 7
            guard let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: startOfToday) else {
                return Array(repeating: false, count: 7)
            }

            var result: [Bool] = []
            result.reserveCapacity(7)

            for offset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                    result.append(false)
                    continue
                }
                let key = PrayerDay.key(for: date)      
                let count = map[key] ?? 0
                result.append(count == 5)
            }

            return result
        }
}
