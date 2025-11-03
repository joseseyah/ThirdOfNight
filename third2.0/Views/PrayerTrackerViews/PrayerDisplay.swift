//
//  PrayerDisplay.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 29/10/2025.
//  Updated: TravelCombineCard with 3 outlined groups (Fajr, Dhuhr+Asr, Maghrib+Isha)
//           and tickable rows that mirror PrayerRowView visuals.
//

import SwiftUI

// MARK: - Lightweight display model (kept for reuse)
public struct PrayerDisplay: Equatable {
    public let name: String
    public let timeText: String
    public init(name: String, timeText: String) {
        self.name = name
        self.timeText = timeText
    }
}

// MARK: - Travel row input (adds state + action)
public struct TravelRowItem {
    public let display: PrayerDisplay
    public let isDone: Bool
    public let isEnabled: Bool
    public let onTap: () -> Void

    public init(display: PrayerDisplay, isDone: Bool, isEnabled: Bool, onTap: @escaping () -> Void) {
        self.display = display
        self.isDone = isDone
        self.isEnabled = isEnabled
        self.onTap = onTap
    }
}

// MARK: - Card

/// In travel mode we show three outlines:
/// 1) Fajr (single)
/// 2) Dhuhr + Asr (pair)
/// 3) Maghrib + Isha (pair)
/// Each row is tappable (ticks + glow) just like `PrayerRowView`.
public struct TravelCombineCard: View {
    public let fajr: TravelRowItem?
    public let dhuhr: TravelRowItem?
    public let asr: TravelRowItem?
    public let maghrib: TravelRowItem?
    public let isha: TravelRowItem?

    // Layout
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
            // Header
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

            // Groups
            VStack(spacing: groupSpacing) {
                // Fajr (single outlined group)
                if let fajr {
                    CombineGroupOutline {
                        GroupRowButton(item: fajr)
                    }
                    .accessibilityLabel("Fajr \(fajr.display.timeText)")
                }

                // Dhuhr + Asr (paired outlined group)
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

                // Maghrib + Isha (paired outlined group)
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

// MARK: - Subviews

/// Button row that mirrors `PrayerRowView` (check ring, glow, capsule time)
private struct GroupRowButton: View {
    let item: TravelRowItem

    private var nameColor: Color { item.isDone ? .accentYellow : .textPrimary }
    private var timeTextColor: Color { item.isDone ? .appBg : .textPrimary }
    private var timeFill: Color { item.isDone ? .accentYellow : Color.white.opacity(0.05) }
    private var timeStroke: Color { item.isDone ? Color.accentYellow.opacity(0.85) : .stroke }

    var body: some View {
        Button(action: item.onTap) {
            HStack(spacing: 12) {
                ZStack {
                    // Use your existing check ring component for consistency
                    CompactCheckRing(isOn: item.isDone)

                    if item.isDone {
                        Circle()
                            .fill(Color.accentYellow.opacity(0.18))
                            .frame(width: 42, height: 42)
                            .blur(radius: 18)
                            .blendMode(.plusLighter)
                            .allowsHitTesting(false)
                    }
                }

                Text(item.display.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(nameColor)
                    .shadow(color: item.isDone ? Color.accentYellow.opacity(0.25) : .clear,
                            radius: item.isDone ? 6 : 0, x: 0, y: 0)

                Spacer(minLength: 8)

                Text(item.display.timeText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(timeTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            Capsule().fill(timeFill)
                            Capsule().stroke(timeStroke, lineWidth: 1.2)

                            if item.isDone {
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.6)
                                    .blur(radius: 0.6)
                                    .opacity(0.65)
                            }
                            if item.isDone {
                                Capsule()
                                    .fill(Color.accentYellow.opacity(0.22))
                                    .blur(radius: 16)
                                    .blendMode(.plusLighter)
                            }
                        }
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(item.isEnabled ? 1 : 0.55)
            .animation(.spring(response: 0.22, dampingFraction: 0.9), value: item.isDone)
        }
        .buttonStyle(TravelGroupPressStyle())
        .disabled(!item.isEnabled)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.clear) // outline is provided by CombineGroupOutline
        )
    }
}

private struct CombineGroupOutline<Content: View>: View {
    @ViewBuilder var content: Content
    private let corner: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) { content }
            .background(
                RoundedRectangle(cornerRadius: corner)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner)
                    .stroke(Color.stroke, lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: corner))
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .overlay(Rectangle().fill(Color.black.opacity(0.08)).frame(height: 0.5))
            .padding(.horizontal, 12)
    }
}

// Press style to match CompactPressStyle without importing it from another file.
private struct TravelGroupPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.accentYellow.opacity(configuration.isPressed ? 0.35 : 0), lineWidth: 2)
            )
            .shadow(color: Color.accentYellow.opacity(configuration.isPressed ? 0.22 : 0), radius: 14)
            .opacity(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
