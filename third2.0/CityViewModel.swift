import Foundation
import Combine
import UserNotifications

class CityViewModel: ObservableObject {
    @Published var selectedCity: String {
        didSet {
            UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
            scheduleNotifications(for: prayerTimes) // Reschedule notifications when the city changes
        }
    }

    @Published var selectedCountry: String {
        didSet {
            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
        }
    }

    @Published var prayerTimes: [String: String] = [:] {
        didSet {
            scheduleNotifications(for: prayerTimes) // Schedule notifications whenever prayer times update
        }
    }

    init() {
        self.selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? "Singapore"
        self.selectedCountry = UserDefaults.standard.string(forKey: "selectedCountry") ?? "Unknown Country"
    }

    func scheduleNotifications(for prayerTimes: [String: String]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // Clear existing notifications

        for (prayerName, prayerTime) in prayerTimes {
            if let date = getDateFromPrayerTime(prayerTime) {
                let content = UNMutableNotificationContent()
                content.title = "\(prayerName) Prayer"
                content.body = "It's time for \(prayerName)."
                content.sound = .default

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.hour, .minute], from: date),
                    repeats: false
                )

                let request = UNNotificationRequest(identifier: "\(prayerName)-notification", content: content, trigger: trigger)
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling \(prayerName) notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func getDateFromPrayerTime(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.date(from: time)
    }
}
