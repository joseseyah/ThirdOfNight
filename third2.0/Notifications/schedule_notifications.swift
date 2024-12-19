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
    content.interruptionLevel = .timeSensitive

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
    content.interruptionLevel = .timeSensitive

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

func scheduleTenMinutesBeforeMidnightNotification(prayerTimes: [String: String]) {
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

    // Calculate Midnight Time
    let totalDuration = fajrDate.timeIntervalSince(maghribDate)
    let midnightTime = maghribDate.addingTimeInterval(totalDuration / 2)

    // Subtract 10 minutes for the notification time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: midnightTime)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 10 Minutes Before Midnight"
    content.body = "Midnight is approaching. Make sure you have done Isha Prayer"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "TenMinutesBeforeMidnightReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 10 Minutes Before Midnight notification: \(error.localizedDescription)")
        } else {
            print("Notification for 10 minutes before Midnight scheduled at \(notificationTime).")
        }
    }
}


func scheduleTenMinutesBeforeIshaNotification(prayerTimes: [String: String]) {
    guard let ishaTime = prayerTimes["Isha"] else {
        print("Missing Isha prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let ishaDate = sanitizeAndParseTime(ishaTime, using: formatter) else {
        print("Invalid Isha prayer time")
        return
    }

    // Subtract 10 minutes from Isha time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: ishaDate)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 10 Minutes Before Isha Prayer"
    content.body = "Make sure you have completed Maghrib prayer"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "TenMinutesBeforeIshaReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 10 Minutes Before Isha notification: \(error.localizedDescription)")
        } else {
            print("Notification for 10 minutes before Isha scheduled at \(notificationTime).")
        }
    }
}

func scheduleTenMinutesBeforeSunriseNotification(prayerTimes: [String: String]) {
    guard let sunriseTime = prayerTimes["Sunrise"] else {
        print("Missing Sunrise time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let sunriseDate = sanitizeAndParseTime(sunriseTime, using: formatter) else {
        print("Invalid Sunrise time")
        return
    }

    // Subtract 10 minutes from Sunrise time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: sunriseDate)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 10 Minutes Before Sunrise"
    content.body = "Sunrise is approaching. Make sure you have prayed Fajr!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "TenMinutesBeforeSunriseReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 10 Minutes Before Sunrise notification: \(error.localizedDescription)")
        } else {
            print("Notification for 10 minutes before Sunrise scheduled at \(notificationTime).")
        }
    }
}

func scheduleTenMinutesBeforeDhuhrNotification(prayerTimes: [String: String]) {
    guard let dhuhrTime = prayerTimes["Dhuhr"] else {
        print("Missing Dhuhr prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let dhuhrDate = sanitizeAndParseTime(dhuhrTime, using: formatter) else {
        print("Invalid Dhuhr prayer time")
        return
    }

    // Subtract 10 minutes from Dhuhr time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: dhuhrDate)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 10 Minutes Before Dhuhr Prayer"
    content.body = "Get ready and make Wudu for Dhuhr prayer."
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "TenMinutesBeforeDhuhrReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 10 Minutes Before Dhuhr notification: \(error.localizedDescription)")
        } else {
            print("Notification for 10 minutes before Dhuhr scheduled at \(notificationTime).")
        }
    }
}

func scheduleDhuhrNotification(prayerTimes: [String: String]) {
    guard let dhuhrTime = prayerTimes["Dhuhr"] else {
        print("Missing Dhuhr prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let dhuhrDate = sanitizeAndParseTime(dhuhrTime, using: formatter) else {
        print("Invalid Dhuhr prayer time")
        return
    }

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Dhuhr Time"
    content.body = "It is now Dhuhr time. Time to pray!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: dhuhrDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "DhuhrTimeReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling Dhuhr notification: \(error.localizedDescription)")
        } else {
            print("Notification for Dhuhr scheduled at \(dhuhrDate).")
        }
    }
}

func scheduleTenMinutesBeforeAsrNotification(prayerTimes: [String: String]) {
    guard let asrTime = prayerTimes["Asr"] else {
        print("Missing Asr prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let asrDate = sanitizeAndParseTime(asrTime, using: formatter) else {
        print("Invalid Asr prayer time")
        return
    }

    // Subtract 10 minutes from Asr time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: asrDate)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 10 Minutes Before Asr"
    content.body = "Don't forget to pray Dhuhr before Asr begins!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "TenMinutesBeforeAsrReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 10 Minutes Before Asr notification: \(error.localizedDescription)")
        } else {
            print("Notification for 10 minutes before Asr scheduled at \(notificationTime).")
        }
    }
}



func scheduleAsrNotification(prayerTimes: [String: String]) {
    guard let asrTime = prayerTimes["Asr"] else {
        print("Missing Asr prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let asrDate = sanitizeAndParseTime(asrTime, using: formatter) else {
        print("Invalid Asr prayer time")
        return
    }

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Asr Time"
    content.body = "It is now Asr time. Time to pray!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: asrDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "AsrTimeReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling Asr notification: \(error.localizedDescription)")
        } else {
            print("Notification for Asr scheduled at \(asrDate).")
        }
    }
}

func scheduleMaghribNotification(prayerTimes: [String: String]) {
    guard let maghribTime = prayerTimes["Maghrib"] else {
        print("Missing Maghrib prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter) else {
        print("Invalid Maghrib prayer time")
        return
    }

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Maghrib Time"
    content.body = "It is now Maghrib time. Time to pray!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: maghribDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "MaghribTimeReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling Maghrib notification: \(error.localizedDescription)")
        } else {
            print("Notification for Maghrib scheduled at \(maghribDate).")
        }
    }
}

func scheduleFortyMinutesBeforeMaghribNotification(prayerTimes: [String: String]) {
    guard let maghribTime = prayerTimes["Maghrib"] else {
        print("Missing Maghrib prayer time")
        return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Assuming prayer times are in 24-hour format

    guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter) else {
        print("Invalid Maghrib prayer time")
        return
    }

    // Subtract 40 minutes from Maghrib time
    let notificationTime = Calendar.current.date(byAdding: .minute, value: -40, to: maghribDate)!

    // Schedule Notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder: 40 Minutes Before Maghrib"
    content.body = "Don't forget to pray Asr before Maghrib approaches!"
    content.sound = .default
    content.interruptionLevel = .timeSensitive

    let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    let identifier = "FortyMinutesBeforeMaghribReminder"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling 40 Minutes Before Maghrib notification: \(error.localizedDescription)")
        } else {
            print("Notification for 40 minutes before Maghrib scheduled at \(notificationTime).")
        }
    }
}







