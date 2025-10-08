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

            VStack(spacing: 18) {
                // Header
                VStack(spacing: 6) {
                    Text("Today")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.accentYellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.06)))

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
        }
        .onAppear {
            loc.request()
            if prayers.isEmpty {
                let fallback = CLLocationCoordinate2D(latitude: 53.4808, longitude: -2.2426) // Manchester
                prayers = computePrayerItems(for: fallback, date: Date())
            }
        }
        .onChange(of: loc.coordinate?.latitude) { _ in
            guard let coord = loc.coordinate else { return }
            prayers = computePrayerItems(for: coord, date: Date())
        }


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
