//
//  TravelInfoSheetView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 03/11/2025.
//

import SwiftUI

// MARK: - Travel Info Sheet (styled like FreezeSheetView)

public struct TravelInfoSheetView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            // Grabber
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            // Title
            Text(String(localized: "Travel Mode"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 20)

            // Icon circle (matches Freeze visual language)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                Circle()
                    .stroke(Color.stroke, lineWidth: 1.2)
                Circle()
                    .stroke(Color.accentPurple.opacity(0.55), lineWidth: 3)
                    .blur(radius: 0.5)
                    .padding(8)

                Image(systemName: "airplane.departure")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentPurple)
                    .shadow(color: Color.accentPurple.opacity(0.28), radius: 10)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 6)

            // Body copy
            VStack(spacing: 10) {
                Text(String(localized: "While travelling, combining prayers is permitted."))
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        Text(String(localized: "**Dhuhr** may be combined with **Asr**."))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.textPrimary)
                    }
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        Text(String(localized: "**Maghrib** may be combined with **Isha**."))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.top, 2)

                Text(String(localized: "Your tracker highlights three groups: **Fajr** (single), **Dhuhr + Asr**, and **Maghrib + Isha** to reflect the allowed combinations."))
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.horizontal, 12)
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cardBg.ignoresSafeArea())
        .presentationDetents([.fraction(0.55), .large])
        .presentationDragIndicator(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "Travel mode information. Dhuhr with Asr, Maghrib with Isha."))
    }
}

// MARK: - Travel Info Circle Button (styled like FreezeCircleButton)

public struct TravelInfoCircleButton: View {
    public var onTap: (() -> Void)? = nil

    public init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
                onTap?()
            }
        } label: {
            ZStack {
                // Always-on look (informational)
                Circle()
                    .fill(Color.accentMoon)

                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appBg)

                // Subtle glow to match Freeze active vibe
                Circle()
                    .fill(Color.accentMoon.opacity(0.18))
                    .frame(width: 42, height: 42)
                    .blur(radius: 18)
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            }
            .frame(width: 38, height: 38)
            .overlay(
                Circle().stroke(Color.accentMoon.opacity(0.65), lineWidth: 1)
            )
            .shadow(color: Color.accentMoon.opacity(0.24), radius: 14, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 6)
            .contentShape(Circle())
        }
        .buttonStyle(CirclePressStyle())
        .accessibilityLabel(String(localized: "Travel information"))
        .accessibilityAddTraits(.isButton)
    }
}
