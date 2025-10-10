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

    private let verticalNudge: CGFloat = 30

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            StarOverlay(count: 25, maxYFraction: 0.70, opacity: 0.28)
          MoonOverlay(
              assetName: "moon",
              size: 88,
              top: -10,
              leading: 30,
              opacity: 0.48,
              glowScale: 0.5,
              glowBlur: 0.15,
              glowOpacity: 0.3
          )


            if let _ = loc.coordinate, !prayers.isEmpty {
                VStack(spacing: 25) {
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
              LocationNotOnView(loc: loc)
            }
        }
        .onAppear {
            loc.request()
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
