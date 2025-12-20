//
//  RootView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 05/11/2025.
//


import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    // Language / layout
    @AppStorage("appLanguage")
    private var appLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"

    // StoreKit manager provided by App
    @EnvironmentObject private var store: StoreKitManager
    
    // Authentication
    @StateObject private var authManager = AuthenticationManager.shared

    @State private var isReady = false
    @State private var didStartBootstrap = false
    @State private var hasSyncedOnAuth = false

    var body: some View {
        Group {
            if isReady {
                if authManager.isAuthenticated {
                    HomeView()
                        .environment(\.locale, Locale(identifier: appLanguage == "fil" ? "fil-PH" : appLanguage))
                        .environment(\.layoutDirection, ["ar","ur"].contains(appLanguage) ? .rightToLeft : .leftToRight)
                        .background(Color.appBg.ignoresSafeArea())
                        .onChange(of: appLanguage) { _, _ in
                            // Re-arm notifications if language changes
                            guard UserDefaults.standard.bool(forKey: "notif_prayer_enabled") else { return }
                            NotificationManager.shared.setPrayerAlertsEnabled(
                                false,
                                coordinates: SettingsStore.shared.lastKnownCoordinate,
                                method: .muslimWorldLeague,
                                madhab: PrefKeys.getAsrMadhab()
                            )
                            NotificationManager.shared.setPrayerAlertsEnabled(
                                true,
                                coordinates: SettingsStore.shared.lastKnownCoordinate,
                                method: .muslimWorldLeague,
                                madhab: PrefKeys.getAsrMadhab()
                            )
                        }
                        .task {
                            // Sync all local prayer data to Firestore when user becomes authenticated
                            if !hasSyncedOnAuth {
                                hasSyncedOnAuth = true
                                await PrayerDataSyncHelper.shared.syncAllLocalDataIfNeeded(modelContext: modelContext)
                            }
                        }
                        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
                            // Reset sync flag when user logs out, so it syncs again on next login
                            if !newValue {
                                hasSyncedOnAuth = false
                            }
                        }
                } else {
                    LandingView()
                }
            } else {
                SplashView()
                    .task {
                        // ensure we only start once
                        guard !didStartBootstrap else { return }
                        didStartBootstrap = true
                        await bootstrap()
                    }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                NotificationManager.shared.bootstrapOnLaunch(
                    coordinates: SettingsStore.shared.lastKnownCoordinate,
                    method: .muslimWorldLeague,
                    madhab: PrefKeys.getAsrMadhab()
                )
            }
        }
    }

    @Sendable
    private func bootstrap() async {
        // 1) Load products (your existing call)
        await store.loadProducts()

        // 2) Prep notifications if enabled
        if UserDefaults.standard.bool(forKey: "notif_prayer_enabled") {
            NotificationManager.shared.setPrayerAlertsEnabled(
                true,
                coordinates: SettingsStore.shared.lastKnownCoordinate,
                method: .muslimWorldLeague,
                madhab: PrefKeys.getAsrMadhab()
            )
        }

        // Optional: guarantee splash shows briefly (feels smoother)
        try? await Task.sleep(nanoseconds: 700_000_000) // ~0.7s

        await MainActor.run { isReady = true }
    }
}
