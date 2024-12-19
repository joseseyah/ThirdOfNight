//
//  third2_0App.swift
//  third2.0
//
//  Created by Joseph Hayes on 06/10/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import MediaPlayer

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        requestNotificationPermission()
        configureAudioSession()
        return true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured for background playback.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
        
    }
    
}


@main
struct third2_0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel() // Shared ViewModel

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

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            // Main App Content
            if hasSeenOnboarding {
                ContentView()
                    .modelContainer(sharedModelContainer)
                    .environmentObject(audioPlayerViewModel)
                    .overlay(
                        RemoteControlWrapper(audioPlayerViewModel: audioPlayerViewModel)
                            .frame(width: 0, height: 0) // Invisible, just to handle events
                    )
            } else {
                // Onboarding Slides
                OnboardingView()
            }
        }
    }
}


