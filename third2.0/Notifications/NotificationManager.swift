// NotificationManager.swift


import Foundation
import UserNotifications
import CoreLocation
import Adhan
import BackgroundTasks
import UIKit

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {
        setupNotificationCategory()
    }

    // Background task identifier - must match Info.plist
    private let refreshTaskId = "testing.thirdgit.prayer.refresh"
    
    // Notification category identifier
    private let prayerCategoryIdentifier = "PRAYER_TIME_CATEGORY"

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

        // Schedule for the next 365 days to ensure notifications work even if app isn't opened for months
        // iOS allows scheduling up to 1 year in advance, so this ensures continuous notifications
        let daysToSchedule = 365
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
                // Schedule the prayer time notification
                await self.schedulePrayerNotification(name: name, when: when, tz: tz)
                // Schedule 10-minute reminder notification to ensure user has time to prepare
                await self.schedulePrayerReminder(name: name, prayerTime: when, tz: tz)
            }
            
            // Schedule midnight notification (halfway between today's Maghrib and tomorrow's Fajr)
            let maghrib = prayers.maghrib
            
            // Get Fajr for the next day
            guard let nextDay = cal.date(byAdding: .day, value: 1, to: date) else { continue }
            let nextDayComps = cal.dateComponents(in: tz, from: nextDay)
            let nextDayDC = DateComponents(year: nextDayComps.year, month: nextDayComps.month, day: nextDayComps.day)
            
            guard let nextDayPrayers = PrayerTimes(coordinates: adhanCoords, date: nextDayDC, calculationParameters: params) else { continue }
            
            let fajrNext = nextDayPrayers.fajr
            
            // Calculate midnight as halfway between today's Maghrib and tomorrow's Fajr
            let totalDuration = fajrNext.timeIntervalSince(maghrib)
            let midnightTime = maghrib.addingTimeInterval(totalDuration / 2)
            
            // Only schedule if midnight is in the future
            if midnightTime > Date() {
                await self.scheduleMidnightNotification(when: midnightTime, tz: tz)
            }
        }
    }

    private func schedulePrayerNotification(name: String, when: Date, tz: TimeZone) async {
        let content = UNMutableNotificationContent()
        // Get localized prayer time title
        let prayerTimeKey = "\(name) Prayer Time"
        content.title = String(localized: String.LocalizationValue(prayerTimeKey))
        // Use localized body format - prayer names are typically kept in Arabic/English
        let bodyFormat = String(localized: String.LocalizationValue("It's time for %@ prayer."))
        content.body = String(format: bodyFormat, name)
        content.sound = .default
        content.categoryIdentifier = prayerCategoryIdentifier
        // Time-sensitive interruption level ensures notification is delivered even in Do Not Disturb
        content.interruptionLevel = .timeSensitive
        // Set relevance score for notification prioritization
        content.relevanceScore = 1.0
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
    
    private func schedulePrayerReminder(name: String, prayerTime: Date, tz: TimeZone) async {
        // Calculate 10 minutes before prayer time to ensure user has time to prepare
        guard let reminderTime = Calendar.current.date(byAdding: .minute, value: -10, to: prayerTime),
              reminderTime > Date() else {
            // Don't schedule if reminder time is in the past
            return
        }
        
        let content = UNMutableNotificationContent()
        // Get localized reminder title
        let reminderTitleFormat = String(localized: String.LocalizationValue("Reminder: %@ Prayer"))
        content.title = String(format: reminderTitleFormat, name)
        // Get localized reminder body
        let reminderBodyFormat = String(localized: String.LocalizationValue("10 minutes left until %@. Make sure you've completed your previous prayers!"))
        content.body = String(format: reminderBodyFormat, name)
        content.sound = .default
        content.categoryIdentifier = prayerCategoryIdentifier
        // Time-sensitive interruption level ensures notification is delivered even in Do Not Disturb
        // This ensures notifications are delivered even if the app hasn't been opened for a year
        content.interruptionLevel = .timeSensitive
        // Set relevance score for notification prioritization
        content.relevanceScore = 0.9 // Slightly lower than prayer time notification
        let id = "reminder.\(name.lowercased()).\(isoDay(prayerTime))"

        let triggerComps = Calendar.current.dateComponents(in: tz, from: reminderTime)
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
            print("Reminder notification add failed: \(error)")
        }
    }
    
    private func scheduleMidnightNotification(when: Date, tz: TimeZone) async {
        let content = UNMutableNotificationContent()
        // Get localized midnight notification title
        content.title = String(localized: String.LocalizationValue("It is Midnight Now"))
        // Get localized midnight notification body
        content.body = String(localized: String.LocalizationValue("Midnight has begun. Relax and Rest for the last third of the night."))
        content.sound = .default
        content.categoryIdentifier = prayerCategoryIdentifier
        // Time-sensitive interruption level ensures notification is delivered even in Do Not Disturb
        content.interruptionLevel = .timeSensitive
        // Set relevance score for notification prioritization
        content.relevanceScore = 1.0
        let id = "midnight.\(isoDay(when))"

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
            print("Midnight notification add failed: \(error)")
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

    // MARK: Notification Category Setup
    
    private func setupNotificationCategory() {
        let category = UNNotificationCategory(
            identifier: prayerCategoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: Helpers

    private func ensureAuth() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: 
            // User is already authorized - we can schedule notifications
            // Time-sensitive setting is a user preference that we respect
            return true
        case .denied: 
            return false
        case .notDetermined:
            do {
                // Request with time-sensitive permission for prayer time notifications
                // This ensures users can receive notifications even in Do Not Disturb mode
                let ok = try await center.requestAuthorization(options: [.alert, .badge, .sound, .timeSensitive])
                return ok
            } catch { 
                return false 
            }
        @unknown default: 
            return false
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
