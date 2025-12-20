import SwiftUI

public struct PrayerPoint: Identifiable, Equatable {
    public let id = UUID()
    public let name: String
    public let date: Date
    public init(_ name: String, _ date: Date) { self.name = name; self.date = date }
}

public struct CurrentPrayerStatus {
    public let currentLabel: String
    public let nextName: String
    public let minutesUntilNext: Int
    public let progress: Double
}

public struct CurrentPrayerBadge: View {
    public let schedule: [PrayerPoint]
    public var outerPadding: EdgeInsets

    public init(
        schedule: [PrayerPoint],
        outerPadding: EdgeInsets = EdgeInsets(top: 28, leading: 16, bottom: 0, trailing: 18) // good defaults
    ) {
        self.schedule = schedule
        self.outerPadding = outerPadding
    }

    public var body: some View {
        if let s = Self.status(for: schedule, now: Date()) {
            VStack(alignment: .trailing, spacing: 6) {
                Text(s.currentLabel)
                    .font(.system(size: 40, weight: .heavy))
                    .fontWidth(.condensed)
                    .foregroundColor(.textPrimaryLight)

                Text("\(Self.hhmm(fromMinutes: s.minutesUntilNext)) until \(s.nextName)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.buttonText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accentPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.stroke, lineWidth: 1)
                    )
            }
            .overlay(alignment: .topTrailing) {
                Circle()
                    .strokeBorder(Color.accentPurple.opacity(0.4), lineWidth: 4)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: CGFloat(min(max(s.progress, 0), 1)))
                            .rotation(Angle(degrees: -90))
                            .stroke(Color.accentPurple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    )
                    .offset(x: 8, y: -8)
            }
            .padding(outerPadding)   // ← NEW
        }
    }
}

// MARK: - Calculations (unchanged)
public extension CurrentPrayerBadge {
    static func makeStandardSchedule(resolve: (String) -> Date?) -> [PrayerPoint] {
        let order = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
        return order.compactMap { n in resolve(n.lowercased()).map { PrayerPoint(n, $0) } }
    }

    static func status(for rawSchedule: [PrayerPoint], now: Date) -> CurrentPrayerStatus? {
        let schedule = rawSchedule.sorted { $0.date < $1.date }
        guard schedule.count >= 2 else { return nil }
        let nextToday = schedule.first(where: { $0.date > now })
        let next = nextToday ?? PrayerPoint(schedule.first!.name, bumpOneDay(schedule.first!.date))
        let prevToday = schedule.last(where: { $0.date <= now })
        let prevBase = prevToday ?? schedule.last!
        let prev = prevToday != nil ? prevBase : PrayerPoint(prevBase.name, bumpOneDay(prevBase.date, by: -1))
        let total = max(next.date.timeIntervalSince(prev.date), 1)
        let elapsed = now.timeIntervalSince(prev.date)
        let remaining = max(0, next.date.timeIntervalSince(now))
        let currentLabel = label(between: prev.name, and: next.name)
        return CurrentPrayerStatus(
            currentLabel: currentLabel,
            nextName: next.name,
            minutesUntilNext: Int(ceil(remaining / 60)),
            progress: min(max(elapsed / total, 0), 1)
        )
    }

    static func hhmm(fromMinutes m: Int) -> String {
        let h = m / 60, mins = m % 60
        if h == 0 { return "\(mins) mins" }
        if mins == 0 { return "\(h) hrs" }
        return "\(h) hrs \(mins) mins"
    }

    static func label(between prev: String, and next: String) -> String {
        let p = prev.lowercased(), n = next.lowercased()
        if p == "sunrise", n == "dhuhr" { return "Duha" }
        switch p { case "fajr","dhuhr","asr","maghrib","isha": return prev; default: return prev }
    }

    private static func bumpOneDay(_ d: Date, by days: Int = 1) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: d) ?? d
    }
}
