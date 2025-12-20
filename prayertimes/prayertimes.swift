//
//  prayertimes.swift
//  prayertimes
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import WidgetKit
import SwiftUI
import CoreLocation
import Adhan

// MARK: - Prayer Calculation Helper
struct PrayerTimeHelper {
    static func getNextPrayerTime(for coordinate: CLLocationCoordinate2D, date: Date = Date()) -> (name: String, time: Date, timeString: String)? {
        let coordinates = Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var params = CalculationMethod.moonsightingCommittee.params
        // Get madhab preference from UserDefaults (widget extension can access App Group)
        let appGroupID = "group.testing.thirdgit"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        let savedMadhab = defaults.string(forKey: "asr.madhab") ?? "shafi"
        params.madhab = savedMadhab == "hanafi" ? .hanafi : .shafi
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
        guard let tomorrowPT = PrayerTimes(coordinates: coordinates, date: compsTomorrow, calculationParameters: params) else {
            return nil
        }
        
        let now = date
        let prayers: [(name: String, time: Date)] = [
            ("Fajr", todayPT.fajr),
            ("Dhuhr", todayPT.dhuhr),
            ("Asr", todayPT.asr),
            ("Maghrib", todayPT.maghrib),
            ("Isha", todayPT.isha),
            ("Fajr", tomorrowPT.fajr) // Next day's Fajr
        ]
        
        // Find the next prayer time
        for prayer in prayers {
            if prayer.time > now {
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.timeZone = .autoupdatingCurrent
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: prayer.time)
                return (prayer.name, prayer.time, timeString)
            }
        }
        
        // If no prayer found (shouldn't happen), return tomorrow's Fajr
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: tomorrowPT.fajr)
        return ("Fajr", tomorrowPT.fajr, timeString)
    }
    
    static func getLastKnownLocation() -> CLLocationCoordinate2D? {
        // Use App Group UserDefaults to share data between app and widget
        // Fallback to standard UserDefaults if App Group is not available
        let appGroupID = "group.testing.thirdgit"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        
        if let lat = defaults.value(forKey: "last_lat") as? CLLocationDegrees,
           let lon = defaults.value(forKey: "last_lon") as? CLLocationDegrees {
            // Validate coordinates are reasonable
            guard abs(lat) <= 90 && abs(lon) <= 180 else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}

// MARK: - Timeline Provider
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            nextPrayerName: "Fajr",
            nextPrayerTime: Date().addingTimeInterval(3600),
            nextPrayerTimeString: "05:30"
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let now = Date()
        if let coordinate = PrayerTimeHelper.getLastKnownLocation(),
           let nextPrayer = PrayerTimeHelper.getNextPrayerTime(for: coordinate, date: now) {
            return SimpleEntry(
                date: now,
                configuration: configuration,
                nextPrayerName: nextPrayer.name,
                nextPrayerTime: nextPrayer.time,
                nextPrayerTimeString: nextPrayer.timeString
            )
        }
        
        // Fallback entry
        return SimpleEntry(
            date: now,
            configuration: configuration,
            nextPrayerName: "—",
            nextPrayerTime: now.addingTimeInterval(3600),
            nextPrayerTimeString: "—"
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let now = Date()
        var entries: [SimpleEntry] = []
        
        guard let coordinate = PrayerTimeHelper.getLastKnownLocation() else {
            // No location available
            let entry = SimpleEntry(
                date: now,
                configuration: configuration,
                nextPrayerName: "—",
                nextPrayerTime: now.addingTimeInterval(3600),
                nextPrayerTimeString: "—"
            )
            entries.append(entry)
            return Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600)))
        }
        
        // Get next prayer time
        guard let nextPrayer = PrayerTimeHelper.getNextPrayerTime(for: coordinate, date: now) else {
            let entry = SimpleEntry(
                date: now,
                configuration: configuration,
                nextPrayerName: "—",
                nextPrayerTime: now.addingTimeInterval(3600),
                nextPrayerTimeString: "—"
            )
            entries.append(entry)
            return Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600)))
        }
        
        // Create entry for current state
        let currentEntry = SimpleEntry(
            date: now,
            configuration: configuration,
            nextPrayerName: nextPrayer.name,
            nextPrayerTime: nextPrayer.time,
            nextPrayerTimeString: nextPrayer.timeString
        )
        entries.append(currentEntry)
        
        // Create entry for when the prayer time arrives
        let prayerEntry = SimpleEntry(
            date: nextPrayer.time,
            configuration: configuration,
            nextPrayerName: nextPrayer.name,
            nextPrayerTime: nextPrayer.time,
            nextPrayerTimeString: nextPrayer.timeString
        )
        entries.append(prayerEntry)
        
        // Refresh timeline at the prayer time and then 1 minute after
        let refreshDate = nextPrayer.time.addingTimeInterval(60)
        return Timeline(entries: entries, policy: .after(refreshDate))
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let nextPrayerName: String
    let nextPrayerTime: Date
    let nextPrayerTimeString: String
}

// MARK: - Widget View
struct prayertimesEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var hasValidData: Bool {
        entry.nextPrayerName != "—" && entry.nextPrayerTimeString != "—"
    }
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            // Lock screen circular widget
            if hasValidData {
                VStack(spacing: 2) {
                    Text(entry.nextPrayerName)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.accentMoon)
                    
                    Text(entry.nextPrayerTimeString)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                .containerBackground(.clear, for: .widget)
            } else {
                VStack(spacing: 2) {
                    Text("No")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.textSecondary)
                    Text("Location")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.textSecondary)
                }
                .containerBackground(.clear, for: .widget)
            }
            
        case .accessoryRectangular:
            // Lock screen rectangular widget
            if hasValidData {
                HStack {
                    Text(entry.nextPrayerName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.accentMoon)
                    
                    Spacer()
                    
                    Text(entry.nextPrayerTimeString)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                .containerBackground(.clear, for: .widget)
            } else {
                HStack {
                    Text("No Location")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.textSecondary)
                    Spacer()
                }
                .containerBackground(.clear, for: .widget)
            }
            
        default:
            // Home screen widget - styled like calendar widget
            if hasValidData {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    // Prayer name (like "Wed Dec" in calendar) - bigger and closer to time
                    Text(entry.nextPrayerName)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.accentPurple)
                    
                    // Large time number (like day number "17" in calendar)
                    Text(entry.nextPrayerTimeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .containerBackground(Color.appBg, for: .widget)
            } else {
                VStack(spacing: 4) {
                    Text("Prayer Times")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                    
                    Text("Location needed")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondaryLight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
}

// MARK: - Widget
struct prayertimes: Widget {
    let kind: String = "prayertimes"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            prayertimesEntryView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("Shows the next prayer time")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
        .contentMarginsDisabled() // Disable default margins that might create borders
    }
}

// MARK: - Preview
extension ConfigurationAppIntent {
    fileprivate static var preview: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
}

#Preview(as: .accessoryCircular) {
    prayertimes()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .preview,
        nextPrayerName: "Dhuhr",
        nextPrayerTime: Date().addingTimeInterval(3600),
        nextPrayerTimeString: "12:30"
    )
}

#Preview(as: .systemSmall) {
    prayertimes()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .preview,
        nextPrayerName: "Dhuhr",
        nextPrayerTime: Date().addingTimeInterval(3600),
        nextPrayerTimeString: "12:30"
    )
}
