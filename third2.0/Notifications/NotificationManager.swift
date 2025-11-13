// NotificationManager.swift


import Foundation
import UserNotifications
import CoreLocation
import Adhan
import BackgroundTasks
import UIKit

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // Update with your bundle identifier
    private let refreshTaskId = "com.yourcompany.NightPrayers.prayer.refresh"

    // MARK: Public API

    /// Call when the toggle changes, on app launch, and after settings/method/coords change.
    func setPrayerAlertsEnabled(_ enabled: Bool,
                                coordinates: CLLocationCoordinate2D?,
                                method: CalculationMethod = .muslimWorldLeague,
                                madhab: Madhab = .shafi) {
        if enabled {
            Task {
                let ok = await self.ensureAuth()
                guard ok else { return }
                await self.rescheduleAll(for: coordinates, method: method, madhab: madhab)
                self.scheduleBackgroundRefresh()
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [])
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // nuke all app pending
            cancelBackgroundRefresh()
        }
    }

    /// Call from App/Scene launch to keep things fresh each day.
    func bootstrapOnLaunch(coordinates: CLLocationCoordinate2D?,
                           method: CalculationMethod = .muslimWorldLeague,
                           madhab: Madhab = .shafi) {
        Task {
            let _ = await self.ensureAuth()
            await self.rescheduleAll(for: coordinates, method: method, madhab: madhab)
            self.scheduleBackgroundRefresh()
        }
        observeSystemChanges(coordinates: coordinates, method: method, madhab: madhab)
    }

    // MARK: Scheduling core

    @MainActor
    func rescheduleAll(for coordinates: CLLocationCoordinate2D?,
                       method: CalculationMethod,
                       madhab: Madhab) async {
        guard let coords = coordinates else { return }

        let center = UNUserNotificationCenter.current()
        // Clear only our prayer identifiers (optional: use a prefix)
        await center.removeAllPending()

        // Schedule for the next 14 days
        let daysToSchedule = 14
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let tz = TimeZone.current

        for offset in 0..<daysToSchedule {
            guard let date = cal.date(byAdding: .day, value: offset, to: now) else { continue }
            let comps = cal.dateComponents(in: tz, from: date)

            var params = method.params  // CalculationParameters
            params.madhab = madhab

            let adhanCoords = Coordinates(latitude: coords.latitude, longitude: coords.longitude)
            let dc = DateComponents(year: comps.year, month: comps.month, day: comps.day)
            guard let prayers = PrayerTimes(coordinates: adhanCoords, date: dc, calculationParameters: params) else {
                continue
            }

            // Choose which prayers you want alerts for:
            let scheduleList: [(String, Date?)] = [
                ("Fajr",     prayers.fajr),
                ("Sunrise",  prayers.sunrise), // optional
                ("Dhuhr",    prayers.dhuhr),
                ("Asr",      prayers.asr),
                ("Maghrib",  prayers.maghrib),
                ("Isha",     prayers.isha)
            ]

            for (name, dt) in scheduleList {
                guard let when = dt, when > Date() else { continue }
                await self.schedulePrayerNotification(name: name, when: when, tz: tz)
            }
        }
    }

    private func schedulePrayerNotification(name: String, when: Date, tz: TimeZone) async {
        let content = UNMutableNotificationContent()
        content.title = "\(name) time"
        content.body  = "It’s time for \(name)."
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        let id = "prayer.\(name.lowercased()).\(isoDay(when))"

        let triggerComps = Calendar.current.dateComponents(in: tz, from: when)
        let cmps = DateComponents(
            calendar: Calendar.current,
            timeZone: tz,
            year: triggerComps.year,
            month: triggerComps.month,
            day: triggerComps.day,
            hour: triggerComps.hour,
            minute: triggerComps.minute,
            second: 0
        )

        let trigger = UNCalendarNotificationTrigger(dateMatching: cmps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Notification add failed: \(error)")
        }
    }

    // MARK: Background refresh

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskId, using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleBackgroundRefresh() {
        let req = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        // Aim shortly after midnight to re-compute for the new day
        if let next = Calendar.current.nextDate(after: Date(),
                                                matching: DateComponents(hour: 0, minute: 5),
                                                matchingPolicy: .nextTime) {
            req.earliestBeginDate = next
        }
        do { try BGTaskScheduler.shared.submit(req) } catch {
            print("BG submit failed: \(error)")
        }
    }

    private func cancelBackgroundRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: refreshTaskId)
    }

    private func handleRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh() // schedule the next one immediately

        // Use your persisted settings for coordinates/method/madhab here.
        // For demo: pull from UserDefaults or a small Settings store.
        let coords = SettingsStore.shared.lastKnownCoordinate
        let method = SettingsStore.shared.calculationMethod
        let madhab = SettingsStore.shared.madhab

        let op = Task {
            await self.rescheduleAll(for: coords, method: method, madhab: madhab)
        }

        task.expirationHandler = {
            op.cancel()
        }

        Task {
            await op.value
            task.setTaskCompleted(success: true)
        }
    }

    // MARK: Helpers

    private func ensureAuth() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        case .denied: return false
        case .notDetermined:
            do {
                let ok = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                return ok
            } catch { return false }
        @unknown default: return false
        }
    }

    private func observeSystemChanges(coordinates: CLLocationCoordinate2D?,
                                      method: CalculationMethod,
                                      madhab: Madhab) {
        // Time zone / midnight / DST / significant time change
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { _ in
            Task { await self.rescheduleAll(for: coordinates, method: method, madhab: madhab) }
        }
        NotificationCenter.default.addObserver(forName: UIApplication.significantTimeChangeNotification, object: nil, queue: .main) { _ in
            Task { await self.rescheduleAll(for: coordinates, method: method, madhab: madhab) }
        }
    }

    private func isoDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// Small helper to remove all pending asynchronously
private extension UNUserNotificationCenter {
    func removeAllPending() async {
        let existing = await self.pendingNotificationRequests()
        let ids = existing.map { $0.identifier }
        self.removePendingNotificationRequests(withIdentifiers: ids)
    }
}

// Example settings backing store — replace with your own
final class SettingsStore {
    static let shared = SettingsStore()
    private init() {}
    var lastKnownCoordinate: CLLocationCoordinate2D? {
        if let lat = UserDefaults.standard.value(forKey: "last_lat") as? CLLocationDegrees,
           let lon = UserDefaults.standard.value(forKey: "last_lon") as? CLLocationDegrees {
            return .init(latitude: lat, longitude: lon)
        }
        return nil
    }
    var calculationMethod: CalculationMethod {
        // Load your saved method; default shown for brevity
        .muslimWorldLeague
    }
    var madhab: Madhab {
        .shafi
    }
}
