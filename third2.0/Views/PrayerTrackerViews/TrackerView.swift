//
//  TrackerView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 06/10/2025.
//

import SwiftUI
import CoreLocation
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = TrackerViewModel()

    private let verticalNudge: CGFloat = 30
    private let sidePadding: CGFloat = 16
    private let headingGap: CGFloat = 10
    private let rowSpacing: CGFloat = 14
    private let sectionSpacing: CGFloat = 25

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

            if let _ = vm.coordinate, !vm.prayers.isEmpty {
                VStack(spacing: sectionSpacing) {
                    // Location + date
                    VStack(spacing: headingGap) {
                        LocationHeader(loc: vm.locationManager)
                        Text(vm.dateString("EEEE d MMMM"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                    }

                    // Prayer rows
                    VStack(spacing: rowSpacing) {
                        ForEach(vm.prayers.indices, id: \.self) { i in
                            let item = vm.prayers[i]
                            PrayerRowView(
                                name: item.name,
                                time: item.timeLabel,
                                isDone: item.done,
                                isEnabled: item.canMark()
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    vm.togglePrayer(at: i)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: verticalNudge)
            } else {
                // Fallback when location not available or prayers not loaded
                LocationNotOnView(loc: vm.locationManager)
            }
        }
        .onAppear {
            vm.configure(context: modelContext)   // wire SwiftData
            vm.onAppear()
        }
        .onDisappear { vm.onDisappear() }
    }
}
