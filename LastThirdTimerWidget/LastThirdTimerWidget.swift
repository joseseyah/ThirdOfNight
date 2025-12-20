//
//  LastThirdTimerWidget.swift
//  LastThirdTimerWidget
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import WidgetKit
import SwiftUI
import CoreLocation
import Adhan

// MARK: - Last Third Calculation Helper
struct LastThirdHelper {
    static func calculateLastThird(
        for coordinate: CLLocationCoordinate2D,
        date: Date = Date()
    ) -> (timeUntil: TimeInterval?, isInLastThird: Bool, lastThirdStart: Date?, fajr: Date?)? {
        let coordinates = Coordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var params = CalculationMethod.moonsightingCommittee.params
        let appGroupID = "group.testing.thirdgit"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        let savedMadhab = defaults.string(forKey: "asr.madhab") ?? "shafi"
        params.madhab = savedMadhab == "hanafi" ? .hanafi : .shafi
        params.highLatitudeRule = .middleOfTheNight
        
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .autoupdatingCurrent
        
        // Get today's prayer times
        let compsToday = cal.dateComponents([.year, .month, .day], from: date)
        guard let todayPT = PrayerTimes(coordinates: coordinates, date: compsToday, calculationParameters: params) else {
            return nil
        }
        
        // Get tomorrow's Fajr
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: date) else {
            return nil
        }
        
        let compsTomorrow = cal.dateComponents([.year, .month, .day], from: tomorrow)
        guard let tomorrowPT = PrayerTimes(coordinates: coordinates, date: compsTomorrow, calculationParameters: params) else {
            return nil
        }
        
        // Determine night start (Isha if available, otherwise Maghrib)
        // In Adhan, isha and maghrib are non-optional Date types, so we use isha directly
        let start = todayPT.isha
        let fajr = tomorrowPT.fajr
        
        // Ensure Fajr is after start (handle day boundary)
        var adjustedFajr = fajr
        if adjustedFajr <= start {
            adjustedFajr = cal.date(byAdding: .day, value: 1, to: adjustedFajr) ?? adjustedFajr
        }
        
        let total = adjustedFajr.timeIntervalSince(start)
        guard total > 0 else { return nil }
        
        // Calculate last third start
        let oneThird = total / 3.0
        let lastThirdStart = adjustedFajr.addingTimeInterval(-oneThird)
        
        let now = date
        
        // Check if we're in the last third
        let isInLastThird = now >= lastThirdStart && now <= adjustedFajr
        
        // Calculate time until last third (or time remaining if already in it)
        let timeUntil: TimeInterval?
        if isInLastThird {
            timeUntil = adjustedFajr.timeIntervalSince(now) // Time remaining in last third
        } else if now < lastThirdStart {
            timeUntil = lastThirdStart.timeIntervalSince(now) // Time until last third starts
        } else {
            timeUntil = nil // Past Fajr, night has ended
        }
        
        return (timeUntil, isInLastThird, lastThirdStart, adjustedFajr)
    }
    
    static func getLastKnownLocation() -> CLLocationCoordinate2D? {
        let appGroupID = "group.testing.thirdgit"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        
        if let lat = defaults.value(forKey: "last_lat") as? CLLocationDegrees,
           let lon = defaults.value(forKey: "last_lon") as? CLLocationDegrees {
            guard abs(lat) <= 90 && abs(lon) <= 180 else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Timeline Provider
struct LastThirdProvider: TimelineProvider {
    func placeholder(in context: Context) -> LastThirdEntry {
        LastThirdEntry(
            date: Date(),
            timeUntil: 3600,
            isInLastThird: false,
            hasValidData: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LastThirdEntry) -> Void) {
        let now = Date()
        if let coordinate = LastThirdHelper.getLastKnownLocation(),
           let result = LastThirdHelper.calculateLastThird(for: coordinate, date: now) {
            let entry = LastThirdEntry(
                date: now,
                timeUntil: result.timeUntil ?? 0,
                isInLastThird: result.isInLastThird,
                hasValidData: true
            )
            completion(entry)
        } else {
            completion(LastThirdEntry(
                date: now,
                timeUntil: nil,
                isInLastThird: false,
                hasValidData: false
            ))
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LastThirdEntry>) -> Void) {
        let now = Date()
        var entries: [LastThirdEntry] = []
        
        guard let coordinate = LastThirdHelper.getLastKnownLocation() else {
            let entry = LastThirdEntry(
                date: now,
                timeUntil: nil,
                isInLastThird: false,
                hasValidData: false
            )
            entries.append(entry)
            // Refresh in 1 hour if no location
            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600)))
            completion(timeline)
            return
        }
        
        guard let result = LastThirdHelper.calculateLastThird(for: coordinate, date: now) else {
            let entry = LastThirdEntry(
                date: now,
                timeUntil: nil,
                isInLastThird: false,
                hasValidData: false
            )
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(now.addingTimeInterval(3600)))
            completion(timeline)
            return
        }
        
        // Create entry for current state
        let currentEntry = LastThirdEntry(
            date: now,
            timeUntil: result.timeUntil ?? 0,
            isInLastThird: result.isInLastThird,
            hasValidData: true
        )
        entries.append(currentEntry)
        
        // If we have a valid time until, create entries for key moments
        if let timeUntil = result.timeUntil, timeUntil > 0 {
            // Create entries every minute for the next hour (for smooth countdown)
            let minutesToShow = min(60, Int(timeUntil / 60) + 1)
            for i in 1...minutesToShow {
                let futureDate = now.addingTimeInterval(TimeInterval(i * 60))
                if let futureResult = LastThirdHelper.calculateLastThird(for: coordinate, date: futureDate) {
                    let entry = LastThirdEntry(
                        date: futureDate,
                        timeUntil: futureResult.timeUntil ?? 0,
                        isInLastThird: futureResult.isInLastThird,
                        hasValidData: true
                    )
                    entries.append(entry)
                }
            }
        }
        
        // Add entry for when last third starts (if not already in it)
        if !result.isInLastThird, let lastThirdStart = result.lastThirdStart, lastThirdStart > now {
            let entry = LastThirdEntry(
                date: lastThirdStart,
                timeUntil: 0,
                isInLastThird: true,
                hasValidData: true
            )
            entries.append(entry)
        }
        
        // Add entry for when Fajr arrives (night ends) - this will trigger recalculation for next night
        if let fajr = result.fajr, fajr > now {
            let entry = LastThirdEntry(
                date: fajr,
                timeUntil: nil,
                isInLastThird: false,
                hasValidData: true
            )
            entries.append(entry)
        }
        
        // Determine next refresh time
        // If we're counting down, refresh every minute
        // If night has ended, refresh in 5 minutes to get next night's data
        let nextUpdate: Date
        if result.timeUntil == nil {
            // Night has ended, check again in 5 minutes for next night
            nextUpdate = now.addingTimeInterval(300)
        } else {
            // Refresh every minute for accurate countdown
            nextUpdate = now.addingTimeInterval(60)
        }
        
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct LastThirdEntry: TimelineEntry {
    let date: Date
    let timeUntil: TimeInterval?
    let isInLastThird: Bool
    let hasValidData: Bool
}

// MARK: - Widget View
struct LastThirdTimerWidgetEntryView: View {
    var entry: LastThirdProvider.Entry
    
    var body: some View {
        MediumWidgetView(entry: entry)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: LastThirdEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // Left side: Moon icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentMoon.opacity(entry.isInLastThird ? 0.3 : 0.15),
                                Color.accentMoon.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                // Moon icon
                Image(systemName: entry.isInLastThird ? "moon.stars.fill" : "moon.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.accentMoon,
                                Color.accentMoon.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.accentMoon.opacity(0.5), radius: 10)
            }
            
            // Right side: Timer and status
            VStack(alignment: .leading, spacing: 8) {
                if entry.hasValidData, let timeUntil = entry.timeUntil {
                    if entry.isInLastThird {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.accentMoon)
                                .frame(width: 8, height: 8)
                                .shadow(color: Color.accentMoon.opacity(0.6), radius: 4)
                            
                            Text("Last Third Active")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.accentMoon)
                        }
                        
                        Text("Time remaining")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                        
                        Text(LastThirdHelper.formatTimeInterval(timeUntil))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimaryLight)
                            .monospacedDigit()
                    } else {
                        Text("Last Third of the Night")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                        
                        Text("Starts in")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                        
                        Text(LastThirdHelper.formatTimeInterval(timeUntil))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.accentPurple)
                            .monospacedDigit()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.textSecondaryLight.opacity(0.6))
                        
                        Text("Location needed")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.textSecondaryLight)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.appBg,
                    Color.appBg.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .containerBackground(Color.appBg, for: .widget)
    }
}

// MARK: - Widget
struct LastThirdTimerWidget: Widget {
    let kind: String = "LastThirdTimerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LastThirdProvider()) { entry in
            LastThirdTimerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Last Third Timer")
        .description("Shows the time remaining until the last third of the night begins, or time remaining if you're already in it.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled() // Disable default margins that might create borders
    }
}
