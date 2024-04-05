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
        
        // Retrieve Maghrib time from ContentViewModel
        let maghribTimeString = ContentViewModel().maghribTime
        
        // Define a date formatter to parse the string representation of time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        // Attempt to parse the Maghrib time string into a Date object
        if let maghribTime = dateFormatter.date(from: maghribTimeString) {
            // Calculate the notification time (10 minutes before Maghrib)
            let notificationTime = Calendar.current.date(byAdding: .minute, value: -10, to: maghribTime)!
            
            // Extract hour and minute components from the notification time
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            
            // Create a trigger for the notification
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create a notification request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // Add the notification request
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling Maghrib notification:", error)
                } else {
                    print("Maghrib notification scheduled successfully")
                }
            }
        } else {
            // Handle the case where parsing the Maghrib time string fails
            print("Error: Unable to parse Maghrib time string '\(maghribTimeString)'")
        }
    }

}
