import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network
import GoogleMobileAds
import StoreKit

@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var store = StoreKitManager.shared

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .background(Color.appBg.ignoresSafeArea())
        }
        .modelContainer(for: [PrayerDay.self, MissedFast.self], isAutosaveEnabled: true)
    }
}
