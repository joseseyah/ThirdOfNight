//
//  schedule_notifications.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/12/2024.
//

import UserNotifications

func scheduleNextPrayerNotification(prayerTimes: [String: String]) {
    guard !prayerTimes.isEmpty else { return }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    let currentTime = Date()
    var nextPrayerTime: Date?
    var nextPrayerName: String?

    for (prayerName, timeString) in prayerTimes {
        if let prayerTime = formatter.date(from: timeString) {
            // Check if the prayer time is in the future
            if prayerTime > currentTime {
                nextPrayerTime = prayerTime
                nextPrayerName = prayerName
                break
            }
        }
    }

    guard let prayerTime = nextPrayerTime, let prayerName = nextPrayerName else {
        print("No future prayer times available.")
        return
    }

    // Schedule notification 15 minutes before the next prayer
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -15, to: prayerTime)!

    let content = UNMutableNotificationContent()
    content.title = "Reminder: \(prayerName) Prayer"
    content.body = "15 minutes left until \(prayerName). Prepare to pray if you haven’t already!"
    content.sound = .default

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "\(prayerName)Reminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling \(prayerName) notification: \(error.localizedDescription)")
        } else {
            print("Notification for \(prayerName) scheduled at \(notificationTime).")
        }
    }
}


func scheduleLastThirdOfNightNotification(prayerTimes: [String: String]) {
    guard let maghribTime = prayerTimes["Maghrib"],
          let fajrTime = prayerTimes["Fajr"] else {
        print("Missing Maghrib or Fajr times")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"

    guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter),
          let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else {
        print("Invalid Maghrib or Fajr times")
        return
    }

    let totalDuration = fajrDate.timeIntervalSince(maghribDate)
    let lastThirdStartTime = fajrDate.addingTimeInterval(-totalDuration / 3)

    // Schedule notification
    let content = UNMutableNotificationContent()
    content.title = "Last Third of the Night has begun"
    content.body = "This is the Last Third of the Night. A great time for supplication and prayer."
    content.sound = .default

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: lastThirdStartTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "LastThirdOfNightReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling Last Third of the Night notification: \(error.localizedDescription)")
        } else {
            print("Last Third of the Night notification scheduled at \(lastThirdStartTime).")
        }
    }
}

func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
    let sanitizedTime = time.components(separatedBy: " ").first ?? time
    return formatter.date(from: sanitizedTime)
}


