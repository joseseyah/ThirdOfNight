//
//  NightPrayersWatchApp.swift
//  Night Prayers Watch App
//
//  Watch app entry point
//

import SwiftUI

@main
struct NightPrayersWatchApp: App {
    @StateObject private var watchConnectivity = WatchConnectivityManagerWatch.shared
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(watchConnectivity)
        }
    }
}

