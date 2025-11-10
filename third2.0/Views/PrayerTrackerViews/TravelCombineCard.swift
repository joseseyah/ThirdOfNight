//
//  PrayerDisplay.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 29/10/2025.
//  Updated: TravelCombineCard with 3 outlined groups (Fajr, Dhuhr+Asr, Maghrib+Isha)
//           and tickable rows that mirror PrayerRowView visuals.
//

import SwiftUI

public struct TravelCombineCard: View {
    public let fajr: TravelRowItem?
    public let dhuhr: TravelRowItem?
    public let asr: TravelRowItem?
    public let maghrib: TravelRowItem?
    public let isha: TravelRowItem?

    private let sidePadding: CGFloat = 16
    private let groupSpacing: CGFloat = 12
    private let rowSpacing: CGFloat = 8

    public init(
        fajr: TravelRowItem?,
        dhuhr: TravelRowItem?,
        asr: TravelRowItem?,
        maghrib: TravelRowItem?,
        isha: TravelRowItem?
    ) {
        self.fajr = fajr
        self.dhuhr = dhuhr
        self.asr = asr
        self.maghrib = maghrib
        self.isha = isha
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appBg)
                    .frame(width: 24, height: 24)
                    .background(Color.accentYellow)
                    .clipShape(Circle())

                Text("Travel mode")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Spacer(minLength: 8)

                Text("Combining allowed")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.textSecondary)
            }

            VStack(spacing: groupSpacing) {
                if let fajr {
                    CombineGroupOutline {
                        GroupRowButton(item: fajr)
                    }
                    .accessibilityLabel("Fajr \(fajr.display.timeText)")
                }

                if let dhuhr, let asr {
                    CombineGroupOutline {
                        VStack(spacing: rowSpacing) {
                            GroupRowButton(item: dhuhr)
                            DividerLine()
                            GroupRowButton(item: asr)
                        }
                    }
                    .accessibilityLabel("Dhuhr \(dhuhr.display.timeText) and Asr \(asr.display.timeText) can be combined.")
                }

                if let maghrib, let isha {
                    CombineGroupOutline {
                        VStack(spacing: rowSpacing) {
                            GroupRowButton(item: maghrib)
                            DividerLine()
                            GroupRowButton(item: isha)
                        }
                    }
                    .accessibilityLabel("Maghrib \(maghrib.display.timeText) and Isha \(isha.display.timeText) can be combined.")
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, sidePadding)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.stroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
        )
        .accessibilityElement(children: .contain)
    }
}
