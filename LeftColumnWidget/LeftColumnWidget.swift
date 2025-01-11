import WidgetKit
import SwiftUI


struct LeftColumnProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeftColumnEntry {
        LeftColumnEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (LeftColumnEntry) -> Void) {
        let entry = LeftColumnEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeftColumnEntry>) -> Void) {
        let currentDate = Date()
        let entry = LeftColumnEntry(date: currentDate)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct LeftColumnEntry: TimelineEntry {
    let date: Date
}

struct LeftColumnWidgetEntryView: View {
    var entry: LeftColumnEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrayerTimeRow(name: "Fajr", time: "06:20")
            PrayerTimeRow(name: "Sunrise", time: "08:00")
            PrayerTimeRow(name: "Dhuhr", time: "12:10")
            PrayerTimeRow(name: "Asr", time: "13:53")
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct LeftColumnWidget: Widget {
    let kind: String = "LeftColumnWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeftColumnProvider()) { entry in
            LeftColumnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Left Column")
        .description("Displays the first four prayer times.")
        .supportedFamilies([.accessoryRectangular])
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
