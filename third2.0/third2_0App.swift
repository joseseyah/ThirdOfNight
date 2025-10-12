import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network
import SwiftData

@main
struct third2_0App: App {
    
    var body: some Scene {
        WindowGroup {
          HomeView()
        }
        .modelContainer(for: [PrayerDay.self])
    }
    

}

