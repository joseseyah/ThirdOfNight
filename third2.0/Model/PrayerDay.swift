//
//  PrayerDay.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/10/2025.
//


import Foundation
import SwiftData

@Model
final class PrayerDay {
    /// Unique key per calendar day, e.g. "2025-10-12"
    @Attribute(.unique) var dayKey: String
    /// Start-of-day Date in the user’s timezone
    var date: Date
    /// Map of prayer name → completion
    var completed: [String: Bool]

    init(date: Date, completed: [String: Bool] = [:]) {
        let day = Calendar.autoupdatingCurrent.startOfDay(for: date)
        self.date = day
        self.dayKey = PrayerDay.key(for: day)
        self.completed = completed
    }

    // MARK: Helpers
    static func key(for date: Date) -> String {
        let c = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: date)
        let y = c.year ?? 0, m = c.month ?? 0, d = c.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
