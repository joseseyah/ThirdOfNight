//
//  TrackerView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 06/10/2025.
//

import Foundation
import SwiftUI
import CoreLocation

struct TrackerView: View {
    @StateObject private var loc = MiniLocationManager()
    @State private var prayers: [PrayerItem] = []

    private let verticalNudge: CGFloat = -40

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            if let _ = loc.coordinate, !prayers.isEmpty {
                // Main content when we have location + computed times
                VStack(spacing: 18) {
                    // Header
                    VStack(spacing: 6) {
                        LocationHeader(loc: loc)
                        Text(dateString("EEEE d MMMM"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                    }

                    // Rows
                    VStack(spacing: 14) {
                        ForEach(prayers.indices, id: \.self) { i in
                            PrayerRowView(
                                name: prayers[i].name,
                                time: prayers[i].time,
                                isDone: prayers[i].done
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    prayers[i].done.toggle()
                                    simpleHaptic()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: verticalNudge)
            } else {
                // Empty state when we don't have a coordinate yet (or no times)
                ContentUnavailableView {
                    Label("Location Needed", systemImage: "location.slash")
                } description: {
                    Text("Enable location access to calculate local prayer times.")
                } actions: {
                    HStack(spacing: 12) {
                        Button("Try Again") { loc.request() }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentYellow)
                            .foregroundStyle(Color.appBg)

                        Button("Open Settings") { openAppSettings() }
                            .buttonStyle(.bordered)
                            .tint(.accentYellow)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            loc.request()
            // If location is already available (e.g., returning to view), compute immediately.
            if let coord = loc.coordinate {
                prayers = computePrayerItems(for: coord, date: Date())
            }
        }
        // Recompute when location changes
        .onChange(of: CoordKey(lat: loc.coordinate?.latitude, lon: loc.coordinate?.longitude)) { _ in
            guard let coord = loc.coordinate else { return }
            prayers = computePrayerItems(for: coord, date: Date())
        }

    }

    // MARK: - Helpers

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private struct CoordKey: Equatable {
        let lat: Double?
        let lon: Double?
    }

}

// MARK: - Helpers

private func dateString(_ format: String) -> String {
    let f = DateFormatter()
    f.locale = .current
    f.dateFormat = format
    return f.string(from: Date())
}

private func simpleHaptic() {
#if os(iOS)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
#endif
}
