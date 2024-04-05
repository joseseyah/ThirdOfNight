import SwiftUI
import SwiftData
import UserNotifications

@main
struct thirdApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationAuthorization()
                    scheduleMidnightNotification()
                    scheduleMaghribNotification()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Error requesting notification authorization:", error)
            }
        }
    }

    func scheduleMidnightNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Midnight is Approaching"
        content.body = "It's almost midnight. Make sure you have completed Isha prayer."

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date().addingTimeInterval(10 * 60))
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error)
            }
        }
    }

    func scheduleMaghribNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Break Your Fast"
        content.body = "It's almost Maghrib time. Make Dua and break your fast on time."

        let maghribTimeString = ContentViewModel().maghribTime // Get Maghrib time string from ContentViewModel
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let maghribTime = dateFormatter.date(from: maghribTimeString) else {
            print("Error: Unable to convert Maghrib time string to Date")
            return
        }

        let notificationTime = maghribTime.addingTimeInterval(-10 * 60) // 10 minutes before Maghrib
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification:", error)
            }
        }
    }
}
