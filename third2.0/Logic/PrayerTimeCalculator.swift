//
//  PrayerTimeCalculator.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/12/2024.
//

import Foundation

struct PrayerTimeCalculator {
    static func calculateMidnightTime(maghribTime: String, fajrTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else { return "Invalid" }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return formatter.string(from: maghribDate.addingTimeInterval(totalDuration / 2))
    }

    static func calculateLastThirdOfNight(maghribTime: String, fajrTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else { return "Invalid" }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return formatter.string(from: fajrDate.addingTimeInterval(-totalDuration / 3))
    }

    private static func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
        let sanitizedTime = time.components(separatedBy: " ").first ?? time
        return formatter.date(from: sanitizedTime)
    }
}

