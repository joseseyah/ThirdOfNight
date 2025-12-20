//
//  PrayerDetectionService.swift
//  Night Prayers
//
//  Service to determine which prayer should be ticked based on current time
//

import Foundation
import CoreLocation
import Adhan

class PrayerDetectionService {
    
    /// Determines which prayer should be marked as complete based on the current time
    /// Returns the prayer name that should be ticked, or nil if no valid prayer window is active
    static func determinePrayerToTick(
        coordinate: CLLocationCoordinate2D,
        date: Date = Date()
    ) -> String? {
        let coordinates = Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = PrefKeys.getAsrMadhab()
        params.highLatitudeRule = .middleOfTheNight
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        
        let compsToday = cal.dateComponents([.year, .month, .day], from: date)
        guard let todayPT = PrayerTimes(coordinates: coordinates, date: compsToday, calculationParameters: params) else {
            return nil
        }
        
        // Get tomorrow's Fajr for Isha's end time
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: date) else {
            return nil
        }

        let compsTomorrow = cal.dateComponents([.year, .month, .day], from: tomorrow)

        guard let tomorrowPT = PrayerTimes(
            coordinates: coordinates,
            date: compsTomorrow,
            calculationParameters: params
        ) else {
            return nil
        }

        
        let now = date
        let prayers: [(name: String, start: Date, end: Date)] = [
            ("Fajr", todayPT.fajr, todayPT.dhuhr),
            ("Dhuhr", todayPT.dhuhr, todayPT.asr),
            ("Asr", todayPT.asr, todayPT.maghrib),
            ("Maghrib", todayPT.maghrib, todayPT.isha),
            ("Isha", todayPT.isha, tomorrowPT.fajr)
        ]
        
        // Find the prayer whose time window is currently active
        // This ensures that if Asr has started (and Dhuhr has ended), only Asr will be ticked
        for prayer in prayers {
            if now >= prayer.start && now < prayer.end {
                return prayer.name
            }
        }
        
        // If no prayer window is active, check if we're past Isha but before next Fajr
        // In this case, we might want to allow Isha if it's still the same day
        if now >= todayPT.isha && now < tomorrowPT.fajr {
            // Check if we're still on the same calendar day
            let isSameDay = cal.isDate(now, inSameDayAs: todayPT.isha)
            if isSameDay {
                return "Isha"
            }
        }
        
        return nil
    }
    
    /// Gets all prayer times for a given date and coordinate
    static func getPrayerTimes(
        coordinate: CLLocationCoordinate2D,
        date: Date = Date()
    ) -> (fajr: Date, dhuhr: Date, asr: Date, maghrib: Date, isha: Date)? {
        let coordinates = Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var params = CalculationMethod.moonsightingCommittee.params
        params.madhab = PrefKeys.getAsrMadhab()
        params.highLatitudeRule = .middleOfTheNight
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        guard let pt = PrayerTimes(coordinates: coordinates, date: comps, calculationParameters: params) else {
            return nil
        }
        
        return (pt.fajr, pt.dhuhr, pt.asr, pt.maghrib, pt.isha)
    }
}

