//
//  HomeView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//
import SwiftUI

struct HomeView: View {
    enum Tab { case tracker, browse }
    @State private var selected: Tab = .tracker

    var body: some View {
        TabView(selection: $selected) {
            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "moon.fill")
                }
                .tag(Tab.tracker)

            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2")
                }
                .tag(Tab.browse)
        }
        .tint(.accentYellow) // selected tab color
        .background(Color.appBg.ignoresSafeArea())
    }
}

