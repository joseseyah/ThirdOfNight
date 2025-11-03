import SwiftUI

/// Lightweight model for displaying a prayer name + time.
public struct PrayerDisplay: Equatable {
    public let name: String
    public let timeText: String    // e.g. "11:49"
    public init(name: String, timeText: String) {
        self.name = name
        self.timeText = timeText
    }
}

/// Show pairing hints for combining prayers while travelling.
public struct TravelCombineCard: View {
    public let dhuhr: PrayerDisplay?
    public let asr: PrayerDisplay?
    public let maghrib: PrayerDisplay?
    public let isha: PrayerDisplay?

    // Layout
    private let sidePadding: CGFloat = 16
    private let rowSpacing: CGFloat = 12

    public init(
        dhuhr: PrayerDisplay?,
        asr: PrayerDisplay?,
        maghrib: PrayerDisplay?,
        isha: PrayerDisplay?
    ) {
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

                Text("You can combine")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.textSecondary)
            }

            if let dhuhr, let asr {
                CombinePairRow(left: dhuhr, right: asr)
            }

            if let maghrib, let isha {
                CombinePairRow(left: maghrib, right: isha)
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
        .accessibilityLabel("Travel mode. You can combine Dhuhr with Asr, and Maghrib with Isha.")
    }
}

// MARK: - Subviews

private struct CombinePairRow: View {
    let left: PrayerDisplay
    let right: PrayerDisplay

    var body: some View {
        HStack(spacing: 10) {
            PairPill(display: left)
            HStack(spacing: 6) {
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 12, weight: .semibold))
                Text("or")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.textSecondary)
            PairPill(display: right)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(left.name) \(left.timeText) or \(right.name) \(right.timeText)")
    }
}

private struct PairPill: View {
    let display: PrayerDisplay

    var body: some View {
        HStack(spacing: 10) {
            // Small circular marker to match your rows
            Circle()
                .stroke(Color.stroke, lineWidth: 1)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 22, height: 22)
                )

            Text(display.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)

            Spacer(minLength: 8)

            Text(display.timeText)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            Capsule()
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}
