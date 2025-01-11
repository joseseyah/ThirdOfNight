import WidgetKit
import SwiftUI

import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate)
        
        // Refresh timeline every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}


import SwiftUI
import WidgetKit

struct PrayerTimesWidgetEntryView: View {
    var entry: SimpleEntry

    var body: some View {
        HStack {
            // Left column for Fajr, Sunrise, Dhuhr, and Asr
            VStack(alignment: .leading, spacing: 8) {
                PrayerTimeRow(name: "Fajr", time: "06:20")
                PrayerTimeRow(name: "Sunrise", time: "08:00")
                PrayerTimeRow(name: "Dhuhr", time: "12:10")
                PrayerTimeRow(name: "Asr", time: "13:53")
            }

            Spacer() // Space between columns

            // Right column for Maghrib, Isha, Midnight, and Last Third
            VStack(alignment: .leading, spacing: 8) {
                PrayerTimeRow(name: "Maghrib", time: "16:13")
                PrayerTimeRow(name: "Isha", time: "17:44")
                PrayerTimeRow(name: "Midnight", time: "23:45")
                PrayerTimeRow(name: "Last Third", time: "02:00")
            }
        }
        .padding()
    }
}

struct PrayerTimeRow: View {
    var name: String
    var time: String

    var body: some View {
        HStack {
            Text(name)
                .font(.caption2)
                .foregroundColor(.primary)
            Spacer()
            Text(time)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}

import WidgetKit
import SwiftUI

struct PrayerTimesWidget: Widget {
    let kind: String = "PrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget) // Set the background for Lock Screen
        }
        .configurationDisplayName("Prayer Times")
        .description("Displays today's prayer times.")
        .supportedFamilies([.accessoryRectangular]) // Ensure it's a rectangular Lock Screen widget
    }
}
