//
//  TrackerView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 06/10/2025.
//

import SwiftUI
import CoreLocation

struct TrackerView: View {
    @StateObject private var vm = TrackerViewModel()

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

            if let _ = vm.coordinate, !vm.prayers.isEmpty {
                VStack(spacing: 25) {
                    VStack(spacing: 6) {
                        LocationHeader(loc: vm.loc)
                        Text(vm.dateString("EEEE d MMMM"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                    }

                    VStack(spacing: 14) {
                        ForEach(vm.prayers.indices, id: \.self) { i in
                            PrayerRowView(
                                name: vm.prayers[i].name,
                                time: vm.prayers[i].time,
                                isDone: vm.prayers[i].done
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    vm.togglePrayer(at: i)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: verticalNudge)
            } else {
                LocationNotOnView(loc: vm.loc)
            }
        }
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
    }
}
