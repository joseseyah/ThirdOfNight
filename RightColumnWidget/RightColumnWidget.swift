import WidgetKit
import SwiftUI

struct RightColumnProvider: TimelineProvider {
    func placeholder(in context: Context) -> RightColumnEntry {
        RightColumnEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (RightColumnEntry) -> Void) {
        let entry = RightColumnEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RightColumnEntry>) -> Void) {
        let currentDate = Date()
        let entry = RightColumnEntry(date: currentDate)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct RightColumnEntry: TimelineEntry {
    let date: Date
}

struct RightColumnWidgetEntryView: View {
    var entry: RightColumnEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrayerTimeRow(name: "Maghrib", time: "16:13")
            PrayerTimeRow(name: "Isha", time: "17:44")
            PrayerTimeRow(name: "Midnight", time: "23:45")
            PrayerTimeRow(name: "Last Third", time: "02:00")
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct RightColumnWidget: Widget {
    let kind: String = "RightColumnWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RightColumnProvider()) { entry in
            RightColumnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Right Column")
        .description("Displays the last four prayer times.")
        .supportedFamilies([.accessoryRectangular])
    }
}
