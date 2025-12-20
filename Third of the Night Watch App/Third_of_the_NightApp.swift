//
//  Third_of_the_NightApp.swift
//  Third of the Night Watch App
//
//  Created by Joseph Hanson Villar Hayes on 15/12/2025.
//

import SwiftUI

@main
struct Third_of_the_Night_Watch_AppApp: App {
    @StateObject private var watchConnectivity = WatchConnectivityManagerWatch.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Start prayer detection automatically when app launches
        // This runs in the background, so detection works even when app isn't open
        watchConnectivity.startBackgroundDetection()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchConnectivity)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }
    
    /// Handle app lifecycle changes to maintain persistent connection
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // App became active - ensure connection is maintained
            print("App became active - Ensuring connection...")
            watchConnectivity.ensureConnection()
            watchConnectivity.startBackgroundDetection()
            
        case .inactive:
            // App is transitioning - maintain connection
            print("App became inactive - Maintaining connection...")
            
        case .background:
            // App is in background - keep connection alive
            print("App entered background - Keeping connection alive...")
            // Connection monitoring continues automatically
            
        @unknown default:
            break
        }
    }
}
