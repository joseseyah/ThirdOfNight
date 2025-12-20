//
//  AppDelegate.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/11/2025.
//


import UIKit
import BackgroundTasks
import FirebaseCore
import Rokt_Widget

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        NotificationManager.shared.registerBackgroundTask()

        NotificationManager.shared.bootstrapOnLaunch(
            coordinates: SettingsStore.shared.lastKnownCoordinate,
            method: .muslimWorldLeague,
            madhab: PrefKeys.getAsrMadhab()
        )
        FirebaseApp.configure()
        
//        // Initialize Rokt SDK
//        // Replace "your_rokt_account_id" with your actual Rokt Account ID
//        Rokt.initWith(roktTagId: "your_rokt_account_id")

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationManager.shared.bootstrapOnLaunch(
            coordinates: SettingsStore.shared.lastKnownCoordinate,
            method: .muslimWorldLeague,
            madhab: PrefKeys.getAsrMadhab()
        )
    }
}
