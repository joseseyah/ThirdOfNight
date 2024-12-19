//
//  NotificationManager.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 11/12/2024.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func scheduleNotification(title: String, body: String, time: String, identifier: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        guard let date = formatter.date(from: time)?.addingTimeInterval(-10 * 60) else {
            print("Failed to calculate notification time.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier) notification: \(error.localizedDescription)")
            } else {
                print("\(identifier) notification scheduled for \(date).")
            }
        }
    }
}

