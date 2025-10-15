//
//  AdsSheetView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 13/10/2025.
//


import SwiftUI
import GoogleMobileAds

struct AdsSheetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            Text("Thanks for supporting the app")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)

            Text("Viewing this ad helps keep Night Prayers free.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            BannerAdController(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 60) // room for adaptive banner
                .padding(.horizontal, 16)
                .padding(.top, 12)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}
