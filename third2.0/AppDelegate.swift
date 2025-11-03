//
//  AppDelegate.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/11/2025.
//


import UIKit
import BackgroundTasks

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        NotificationManager.shared.registerBackgroundTask()

        NotificationManager.shared.bootstrapOnLaunch(
            coordinates: SettingsStore.shared.lastKnownCoordinate,
            method: .muslimWorldLeague,
            madhab: .shafi
        )

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationManager.shared.bootstrapOnLaunch(
            coordinates: SettingsStore.shared.lastKnownCoordinate,
            method: .muslimWorldLeague,
            madhab: .shafi
        )
    }
}
