import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct PrayerCountdownTimelineProvider: TimelineProvider {
    // Placeholder for the widget
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), nextPrayer: "Fajr", nextPrayerTime: "06:21", countdown: "00:00")
    }

    // Snapshot for the widget
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        let entry = PrayerEntry(date: Date(), nextPrayer: "Fajr", nextPrayerTime: "06:21", countdown: "00:00")
        completion(entry)
    }

    // Timeline with live updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let currentDate = Date()
        var entries: [PrayerEntry] = []

        // Create entries for the next 60 minutes
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = createEntry(for: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    // Create a single entry
    func createEntry(for date: Date) -> PrayerEntry {
        let currentDate = date
        var nextPrayerName = ""
        var nextPrayerTime = ""
        var countdown = ""

        // Determine the next prayer
        for prayer in staticPrayerTimes {
            if let prayerDate = getDateFromTime(prayer.time), prayerDate > currentDate {
                nextPrayerName = prayer.name
                nextPrayerTime = prayer.time
                countdown = getCountdownString(to: prayerDate)
                break
            }
        }

        // Fallback if no future prayers found
        if nextPrayerName.isEmpty {
            nextPrayerName = staticPrayerTimes.first?.name ?? "Fajr"
            nextPrayerTime = staticPrayerTimes.first?.time ?? "06:21"
            countdown = "00:00"
        }

        return PrayerEntry(
            date: date,
            nextPrayer: nextPrayerName,
            nextPrayerTime: nextPrayerTime,
            countdown: countdown
        )
    }
}

// MARK: - Data Models
struct PrayerEntry: TimelineEntry {
    let date: Date
    let nextPrayer: String
    let nextPrayerTime: String
    let countdown: String
}

struct Prayer {
    let name: String
    let time: String
}

// Static prayer times
let staticPrayerTimes: [Prayer] = [
    Prayer(name: "Fajr", time: "06:21"),
    Prayer(name: "Dhuhr", time: "12:03"),
    Prayer(name: "Asr", time: "13:35"),
    Prayer(name: "Maghrib", time: "15:57"),
    Prayer(name: "Isha", time: "17:28")
]

// MARK: - Helpers
func getDateFromTime(_ time: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let calendar = Calendar.current
    guard let prayerTime = formatter.date(from: time) else { return nil }

    return calendar.date(bySettingHour: Calendar.current.component(.hour, from: prayerTime),
                         minute: Calendar.current.component(.minute, from: prayerTime),
                         second: 0,
                         of: Date())
}

func getCountdownString(to date: Date) -> String {
    let interval = Int(date.timeIntervalSinceNow)
    let hours = interval / 3600
    let minutes = (interval % 3600) / 60
    return String(format: "%02d:%02d", hours, minutes)
}

// MARK: - Widget View
struct PrayerCountdownEntryView: View {
    var entry: PrayerEntry

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "#0A1B3D")
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Next Prayer: \(entry.nextPrayer)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#FF9D66")) // Highlight color

                Text("Time: \(entry.nextPrayerTime)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                Text("Countdown: \(entry.countdown)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color(hex: "#FF9D66"))
            }
            .padding()
        }
    }
}

// MARK: - Widget Configuration
struct PrayerCountdownWidget: Widget {
    let kind: String = "PrayerCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerCountdownTimelineProvider()) { entry in
            PrayerCountdownEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Countdown")
        .description("Shows the next prayer time and countdown.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Color Helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

