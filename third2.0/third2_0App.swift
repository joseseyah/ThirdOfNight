import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network
import SwiftData
import GoogleMobileAds

@main
struct third2_0App: App {
    init() {
      MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
          HomeView()
        }
        .modelContainer(for: [PrayerDay.self])
    }
    

}

