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
            Color.appBg
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Next Prayer: \(entry.nextPrayer)")
                    .font(.headline)
                    .foregroundColor(.accentPurple) // Highlight color

                Text("Time: \(entry.nextPrayerTime)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.textPrimaryLight)

                Text("Countdown: \(entry.countdown)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.accentPurple)
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
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Sleep App Theme - Matching main app
    static let appBg         = Color(hex: "03174C")   // dark night sky blue
    static let cardBg        = Color(hex: "E8F0F8")   // light blue (cloud-like)
    static let cardBgDark    = Color(hex: "D0E0F0")   // darker card variant
    static let stroke        = Color(hex: "B8D0E8")   // light blue separator
    static let strokeLight   = Color(hex: "D0E0F0")   // lighter stroke
    static let textPrimary   = Color(hex: "1A2332")   // dark blue (high contrast)
    static let textPrimaryLight = Color(hex: "FFFFFF") // white (for dark backgrounds)
    static let textSecondary = Color(hex: "4A5A6A")   // medium blue-gray
    static let textSecondaryLight = Color(hex: "E0E8F0") // light blue-gray
    static let accentPurple  = Color(hex: "93A1ED")   // purple/lavender for buttons
    static let accentPurpleDark = Color(hex: "7A8AE0") // darker purple
    static let accentMoon    = Color(hex: "C5C6D0")   // gray moon
    static let accentMoonDark = Color(hex: "B0B1C0") // darker gray
    static let buttonText    = Color(hex: "F6F1FB")   // very light purple/white for button text
}

