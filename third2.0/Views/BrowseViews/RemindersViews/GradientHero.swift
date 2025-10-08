//
//  GradientHero.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//


import SwiftUI

struct GradientHero: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // gradient background (dark to warm)
            LinearGradient(
                colors: [
                    Color.appBg.opacity(0.95),
                    Color.accentYellow.opacity(0.28),
                    Color.appBg.opacity(0.95)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.stroke, lineWidth: 1)
            )

            VStack(alignment: .center, spacing: 10) {
                // icon circle
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.appBg)
                    .padding(18)
                    .background(Circle().fill(Color.accentYellow))
                    .shadow(color: Color.accentYellow.opacity(0.35), radius: 16, x: 0, y: 6)

                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}
