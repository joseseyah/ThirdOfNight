//
//  PrayerHelper.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/01/2025.
//

import Foundation
import FirebaseFirestore

struct PrayerHelper {
    static func sanitizeTime(_ time: String) -> String {
        return time.components(separatedBy: " ").first ?? time
    }

    static func formatTime(_ time: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss" // Input format from Firestore

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        if let date = inputFormatter.date(from: time) {
            return outputFormatter.string(from: date)
        }

        return time // Fallback to original if parsing fails
    }

    static func calculateMidnightTime(maghribTime: String, fajrTime: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm" // Input format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: inputFormatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: inputFormatter)?.addingTimeInterval(24 * 60 * 60) else {
            print("Error calculating Midnight: Invalid Maghrib (\(maghribTime)) or Fajr (\(fajrTime)) time")
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return outputFormatter.string(from: maghribDate.addingTimeInterval(totalDuration / 2))
    }

    static func calculateLastThirdOfNight(maghribTime: String, fajrTime: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm" // Input format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: inputFormatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: inputFormatter)?.addingTimeInterval(24 * 60 * 60) else {
            print("Error calculating Last Third of Night: Invalid Maghrib (\(maghribTime)) or Fajr (\(fajrTime)) time")
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return outputFormatter.string(from: fajrDate.addingTimeInterval(-totalDuration / 3))
    }

    static func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
        let sanitizedTime = time.components(separatedBy: " ").first ?? time
        
        // Try parsing with "HH:mm" format first
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: sanitizedTime) {
            return date
        }
        
        // Fallback to "HH:mm:ss" if "HH:mm" fails
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: sanitizedTime) {
            return date
        }
        
        print("Failed to parse time: \(sanitizedTime)")
        return nil
    }
    

    
    static func mapCheadleMasjidKeys(_ prayerTimesDict: [String: String]) -> [String: String] {
        return [
            "Fajr": PrayerHelper.formatTime(prayerTimesDict["fajr_begins"] ?? "N/A"),
            "Sunrise": PrayerHelper.formatTime(prayerTimesDict["sunrise"] ?? "N/A"),
            "Dhuhr": PrayerHelper.formatTime(prayerTimesDict["zuhr_begins"] ?? "N/A"),
            "Asr": PrayerHelper.formatTime(prayerTimesDict["asr_mithl_1"] ?? "N/A"),
            "Maghrib": PrayerHelper.formatTime(prayerTimesDict["maghrib_begins"] ?? "N/A"),
            "Isha": PrayerHelper.formatTime(prayerTimesDict["isha_begins"] ?? "N/A"),
            "FajrJ": PrayerHelper.formatTime(prayerTimesDict["fajr_jamah"] ?? "N/A"),
            "DhuhrJ": PrayerHelper.formatTime(prayerTimesDict["zuhr_jamah"] ?? "N/A"),
            "AsrJ": PrayerHelper.formatTime(prayerTimesDict["asr_jamah"] ?? "N/A"),
            "MahgribJ": PrayerHelper.formatTime(prayerTimesDict["maghrib_jamah"] ?? "N/A"),
            "IshaJ": PrayerHelper.formatTime(prayerTimesDict["isha_jamah"] ?? "N/A"),
        ]
    }
    
    static func currentReadableDate() -> String {
        DateParser.getCurrentDateToString()
    }
}
