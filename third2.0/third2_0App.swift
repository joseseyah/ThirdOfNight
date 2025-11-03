import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import BackgroundTasks
import AVFoundation
import FirebaseFirestore
import Network
import GoogleMobileAds

private enum AppLanguage {
    static let rtlCodes: Set<String> = ["ar", "ur"]
    static func isRTL(_ code: String) -> Bool { rtlCodes.contains(code) }
    static func locale(for code: String) -> Locale { Locale(identifier: code) }
}

@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("appLanguage")
    private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.locale, AppLanguage.locale(for: appLanguage))
                .environment(\.layoutDirection, AppLanguage.isRTL(appLanguage) ? .rightToLeft : .leftToRight)
                .task {
                    if UserDefaults.standard.bool(forKey: "notif_prayer_enabled") {
                        NotificationManager.shared.setPrayerAlertsEnabled(
                            true,
                            coordinates: SettingsStore.shared.lastKnownCoordinate,
                            method: .muslimWorldLeague,
                            madhab: .shafi
                        )
                    }
                }
                .onChange(of: appLanguage) { _, newLang in
                    guard UserDefaults.standard.bool(forKey: "notif_prayer_enabled") else { return }
                    NotificationManager.shared.setPrayerAlertsEnabled(
                        false,
                        coordinates: SettingsStore.shared.lastKnownCoordinate,
                        method: .muslimWorldLeague,
                        madhab: .shafi
                    )
                    NotificationManager.shared.setPrayerAlertsEnabled(
                        true,
                        coordinates: SettingsStore.shared.lastKnownCoordinate,
                        method: .muslimWorldLeague,
                        madhab: .shafi
                    )
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
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
