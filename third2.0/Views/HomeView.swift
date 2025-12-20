import SwiftUI
import UIKit

struct HomeView: View {
    enum Tab { case tracker, qibla, summary, browse, settings }
    @State private var selected: Tab = .tracker

    init() {
        let bg = UIColor(Color.tabBg) // Use tabBg for better contrast
        let unselected = UIColor(Color.tabUnselected) // White for clear contrast on blue
        let selected = UIColor(Color.tabSelected) // Purple accent

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
                .tabItem { Label(String(localized: "Tracker"), systemImage: "moon.fill") }
                .tag(Tab.tracker)

            QiblaView()
                .tabItem { Label(String(localized: "Qibla"), systemImage: "mecca") }
                .tag(Tab.qibla)

            SummaryView()
                .tabItem { Label(String(localized: "Summary"), systemImage: "heart.text.clipboard.fill") }
                .tag(Tab.summary)

            SettingsView()
                .tabItem { Label(String(localized: "Settings"), systemImage: "gear") }
                .tag(Tab.settings)
        }
        .tint(.accentPurple)
        .background(Color.appBg.ignoresSafeArea())
    }
}
