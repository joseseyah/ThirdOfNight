import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network
import GoogleMobileAds

@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    // If the user already enabled alerts earlier, ensure they’re scheduled.
                    if UserDefaults.standard.bool(forKey: "notif_prayer_enabled") {
                        NotificationManager.shared.setPrayerAlertsEnabled(
                            true,
                            coordinates: SettingsStore.shared.lastKnownCoordinate,
                            method: .muslimWorldLeague,
                            madhab: .shafi
                        )
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                // iOS likes you to schedule BG refresh whenever you background the app.
                NotificationManager.shared.bootstrapOnLaunch(
                    coordinates: SettingsStore.shared.lastKnownCoordinate,
                    method: .muslimWorldLeague,
                    madhab: .shafi
                )
            }
        }
        .modelContainer(for: [PrayerDay.self])
    }
}
