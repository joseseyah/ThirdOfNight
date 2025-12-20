import Foundation
import SwiftData

@Model
final class PrayerDay {

    /// Unique key per calendar day, e.g. "2025-10-12"
    @Attribute(.unique) var dayKey: String

    /// Start-of-day Date in the user's timezone
    var date: Date

    /// Persisted JSON blob for completion state
    @Attribute(.externalStorage) private var completedData: Data

    /// Whether freeze mode was active for this day (excludes from statistics)
    var isFrozen: Bool

    init(date: Date, completed: [String: Bool] = [:], isFrozen: Bool = false) {
        let day = Calendar.autoupdatingCurrent.startOfDay(for: date)
        self.date = day
        self.dayKey = PrayerDay.key(for: day)
        self.isFrozen = isFrozen

        // Encode initial state
        self.completedData = (try? JSONEncoder().encode(completed)) ?? Data()
    }

    /// Read/write dictionary backed by JSON `Data`
    var completed: [String: Bool] {
        get {
            (try? JSONDecoder().decode([String: Bool].self, from: completedData)) ?? [:]
        }
        set {
            completedData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    // MARK: Helpers
    static func key(for date: Date) -> String {
        let day = Calendar.autoupdatingCurrent.startOfDay(for: date)
        let c = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: day)
        let y = c.year ?? 0, m = c.month ?? 0, d = c.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }
}
