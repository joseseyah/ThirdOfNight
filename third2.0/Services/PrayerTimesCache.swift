//
//  PrayerTimesCache.swift
//  Night Prayers
//
//  Created for caching prayer times
//

import Foundation
import CoreLocation

struct CachedPrayerTimes: Codable {
    let date: Date
    let coordinate: CachedCoordinate
    let prayers: [CachedPrayer]
    let madhab: String? // Store the madhab used for calculation
    
    struct CachedCoordinate: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    struct CachedPrayer: Codable {
        let name: String
        let timeLabel: String
        let start: Date
        let nextStart: Date
    }
}

final class PrayerTimesCache {
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cachedPrayerTimes"
    private let dateKey = "cachedPrayerTimesDate"
    
    // Location tolerance in degrees (approximately 1km)
    private let locationTolerance: Double = 0.01
    
    /// Check if cached prayer times are valid for the given date and coordinate
    func isValid(for date: Date, coordinate: CLLocationCoordinate2D) -> Bool {
        guard let cached = load() else { return false }
        
        // Check if date is the same day
        let calendar = Calendar.current
        let isSameDay = calendar.isDate(cached.date, inSameDayAs: date)
        
        if !isSameDay {
            return false
        }
        
        // Check if location is similar (within tolerance)
        let latDiff = abs(cached.coordinate.latitude - coordinate.latitude)
        let lonDiff = abs(cached.coordinate.longitude - coordinate.longitude)
        
        if latDiff >= locationTolerance || lonDiff >= locationTolerance {
            return false
        }
        
        // Check if madhab preference matches (if stored in cache)
        let currentMadhab = PrefKeys.getAsrMadhab() == .hanafi ? "hanafi" : "shafi"
        if let cachedMadhab = cached.madhab, cachedMadhab != currentMadhab {
            return false
        }
        
        return true
    }
    
    /// Save prayer times to cache
    func save(prayers: [TrackerPrayer], for date: Date, coordinate: CLLocationCoordinate2D) {
        let cachedPrayers = prayers.map { prayer in
            CachedPrayerTimes.CachedPrayer(
                name: prayer.name,
                timeLabel: prayer.timeLabel,
                start: prayer.start,
                nextStart: prayer.nextStart
            )
        }
        
        // Store the current madhab preference
        let currentMadhab = PrefKeys.getAsrMadhab() == .hanafi ? "hanafi" : "shafi"
        
        let cached = CachedPrayerTimes(
            date: date,
            coordinate: CachedPrayerTimes.CachedCoordinate(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            prayers: cachedPrayers,
            madhab: currentMadhab
        )
        
        if let encoded = try? JSONEncoder().encode(cached) {
            userDefaults.set(encoded, forKey: cacheKey)
            userDefaults.set(date, forKey: dateKey)
        }
    }
    
    /// Load cached prayer times
    func load() -> CachedPrayerTimes? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedPrayerTimes.self, from: data) else {
            return nil
        }
        return cached
    }
    
    /// Convert cached prayer times to TrackerPrayer array
    func toTrackerPrayers(cached: CachedPrayerTimes, completed: [String: Bool]) -> [TrackerPrayer] {
        return cached.prayers.map { cachedPrayer in
            let key = cachedPrayer.name.uppercased()
            let done = completed[key] ?? false
            
            return TrackerPrayer(
                name: cachedPrayer.name,
                timeLabel: cachedPrayer.timeLabel,
                start: cachedPrayer.start,
                nextStart: cachedPrayer.nextStart,
                done: done
            )
        }
    }
    
    /// Clear the cache
    func clear() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: dateKey)
    }
    
    /// Check if cache needs to be invalidated (new day)
    func shouldInvalidate() -> Bool {
        guard let cachedDate = userDefaults.object(forKey: dateKey) as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        return !calendar.isDate(cachedDate, inSameDayAs: Date())
    }
}

