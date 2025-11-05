import SwiftUI
import UIKit

struct HomeView: View {
    enum Tab { case tracker, qibla, summary, browse, settings }
    @State private var selected: Tab = .tracker

    init() {
        let bg = UIColor(Color.appBg)
        let unselected = UIColor(Color.textSecondary.opacity(0.85))
        let selected = UIColor(Color.accentYellow)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg

        appearance.stackedLayoutAppearance.normal.iconColor = unselected
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselected
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selected
        ]

        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.unselectedItemTintColor = unselected
        tabBar.barTintColor = bg
        tabBar.backgroundColor = bg
    }

    var body: some View {
        TabView(selection: $selected) {
            TrackerView()
                .tabItem { Label("Tracker", systemImage: "moon.fill") }
                .tag(Tab.tracker)

            QiblaView()
                .tabItem { Label("Qibla", systemImage: "mecca") }
                .tag(Tab.qibla)

            SummaryView()
                .tabItem { Label("Summary", systemImage: "heart.text.clipboard.fill") }
                .tag(Tab.summary)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(Tab.settings)
        }
        .tint(.accentYellow)
        .background(Color.appBg.ignoresSafeArea())
    }
}
