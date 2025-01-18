//
//  islamiccurrentdate.swift
//  islamiccurrentdate
//
//  Created by Joseph Hayes on 18/01/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), day: "6", month: "Jumada II", year: "1446")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let islamicDate = getIslamicDate(from: Date())
        let entry = SimpleEntry(date: Date(), day: islamicDate.day, month: islamicDate.month, year: islamicDate.year)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        let islamicDate = getIslamicDate(from: currentDate)

        // Create an entry for the current date
        let entry = SimpleEntry(date: currentDate, day: islamicDate.day, month: islamicDate.month, year: islamicDate.year)

        // Update timeline daily at midnight
        let nextUpdate = Calendar.current.startOfDay(for: currentDate.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    func getIslamicDate(from date: Date) -> (day: String, month: String, year: String) {
        // Use the Islamic Calendar
        let islamicCalendar = Calendar(identifier: .islamicCivil)
        let components = islamicCalendar.dateComponents([.day, .month, .year], from: date)

        let day = String(components.day ?? 1)
        let month = islamicCalendar.monthSymbols[(components.month ?? 1) - 1]
        let year = String(components.year ?? 1446)

        return (day, month, year)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date // Required by TimelineEntry
    let day: String
    let month: String
    let year: String
}

struct IslamicCurrentDateEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Background Colour
            Color("BackgroundColor")
                .ignoresSafeArea()

            VStack(spacing: -8) { // Minimal negative spacing for tight alignment
                // Month sits just above the Day
                Text(entry.month)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color("DayHighlightColor"))
                    .padding(.bottom, 2) // Slight padding to adjust positioning

                // Big Day Number
                Text(entry.day)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundColor(Color("HighlightColor"))

                // Year sits at the bottom
                Text(entry.year)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("DayBoxBackgroundColor"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure widget fills available space
        .background(Color("BackgroundColor")) // Match container background
        .containerBackground(Color("BackgroundColor"), for: .widget)
    }
}

struct islamiccurrentdate: Widget {
    let kind: String = "IslamicCurrentDate"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            IslamicCurrentDateEntryView(entry: entry)
        }
        .configurationDisplayName("Islamic Date Widget")
        .description("Displays the current Islamic date in a clean and modern format.")
        .supportedFamilies([.systemSmall])
    }
}
