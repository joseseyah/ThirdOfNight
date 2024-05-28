//
//  PrayerTimesCache.swift
//  third
//
//  Created by Joseph Hayes on 28/05/2024.
//

import Foundation

class PrayerTimesCache {
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "prayerTimesCache"
    private let dateKey = "prayerTimesDate"
    private let cacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours

    func saveData(_ data: CalendarResponse, for date: String) {
        if let encodedData = try? JSONEncoder().encode(data) {
            userDefaults.set(encodedData, forKey: cacheKey)
            userDefaults.set(date, forKey: dateKey)
        }
    }

    func loadData(for date: String) -> CalendarResponse? {
        guard let cachedDate = userDefaults.string(forKey: dateKey),
              cachedDate == date,
              let encodedData = userDefaults.data(forKey: cacheKey) else {
            return nil
        }
        return try? JSONDecoder().decode(CalendarResponse.self, from: encodedData)
    }
}

