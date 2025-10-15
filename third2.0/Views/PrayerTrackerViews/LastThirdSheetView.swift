//
//  LastThirdSheetView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/10/2025.
//


import SwiftUI

struct LastThirdSheetView: View {
    let isha: Date?
    let maghrib: Date?
    let fajr: Date?
    let timezone: TimeZone

    @Environment(\.dismiss) private var dismiss

    private var nightStart: Date? {
        if let isha { return isha }
        return maghrib
    }

    private var computed: (start: Date, end: Date, lastThirdStart: Date, lastThirdEnd: Date)? {
        guard let start = nightStart, var end = fajr else { return nil }

        // Ensure the Fajr anchor is after the start; if not, push to next day.
        if end <= start {
            end = Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
        }

        // Defensive: if start is before now by >24h due to time zone mismatch, pull forward.
        if start.addingTimeInterval(60*60*24) < end.addingTimeInterval(-60) {
            // fine
        }

        let total = end.timeIntervalSince(start)
        guard total > 0 else { return nil }

        let oneThird = total / 3.0
        let lastStart = end.addingTimeInterval(-oneThird)
        return (start, end, lastStart, end)
    }

    private var isNowInLastThird: Bool {
        guard let c = computed else { return false }
        let now = Date()
        return now >= c.lastThirdStart && now <= c.lastThirdEnd
    }

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Last Third of the Night")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                if isNowInLastThird {
                    Text("Now")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.appBg)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.accentYellow)
                        .clipShape(Capsule())
                }
            }

            if let c = computed {
                VStack(spacing: 12) {

                    NightProgressView(
                        nightStart: c.start,
                        fajr: c.end,
                        lastThirdStart: c.lastThirdStart
                    )
                    VStack(spacing: 12) {
                        row(icon: "moon.stars.fill", label: "Night Start", value: timeString(c.start))
                        row(icon: "sun.and.horizon.fill", label: "Fajr", value: timeString(c.end))
                        Divider().background(Color.stroke)
                        row(icon: "clock.badge.checkmark", label: "Last Third Starts", value: timeString(c.lastThirdStart))
                        row(icon: "clock.badge.xmark", label: "Last Third Ends", value: timeString(c.lastThirdEnd))
                    }
                    .padding()
                    .background(Color.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.stroke, lineWidth: 1)
                    )

                    // Progress (now within the night)

                    .padding(.top, 6)
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 10) {
                    Text("Not enough data")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text("We need Isha or Maghrib and Fajr times for today to calculate the last third.")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 10)
        }
        .background(Color.appBg.ignoresSafeArea())
    }

    // MARK: - UI Helpers

    private func row(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.accentYellow)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.textSecondary)
        }
    }

    private func timeString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.timeZone = timezone
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

// MARK: - Night Progress View

private struct NightProgressView: View {
    let nightStart: Date
    let fajr: Date
    let lastThirdStart: Date

    @State private var now: Date = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var total: TimeInterval { fajr.timeIntervalSince(nightStart) }
    private var clampedElapsed: TimeInterval {
        guard total > 0 else { return 0 }
        return max(0, min(Date().timeIntervalSince(nightStart), total))
    }
    private var progressT: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(clampedElapsed / total)
    }
    private var lastThirdT: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(lastThirdStart.timeIntervalSince(nightStart) / total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Night Progress")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.textSecondary)

            GeometryReader { geo in
                let w = geo.size.width
                let h = max(64.0, geo.size.height)
                ZStack {
                    // Base arch (track)
                    ArchTrack(width: w, height: h, lineWidth: 8)
                        .stroke(Color.white.opacity(0.08), lineWidth: 8)

                    // Last third band (shaded segment along the curve)
                    ArchSegment(width: w, height: h, tStart: lastThirdT, tEnd: 1.0, lineWidth: 8)
                        .stroke(Color.accentYellow.opacity(0.18), style: StrokeStyle(lineWidth: 12, lineCap: .round))

                    // Progress stroke
                    ArchSegment(width: w, height: h, tStart: 0.0, tEnd: progressT, lineWidth: 8)
                        .stroke(Color.accentYellow, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .shadow(color: Color.accentYellow.opacity(0.35), radius: 8, x: 0, y: 0)

                    // Moving marker
                    if progressT > 0 {
                        let p = ArchGeometry.pointOnArch(width: w, height: h, t: progressT)
                        Circle()
                            .fill(Color.accentYellow)
                            .frame(width: 14, height: 14)
                            .shadow(color: Color.accentYellow.opacity(0.5), radius: 6)
                            .position(x: p.x, y: p.y)
                            .overlay {
                                Circle().stroke(Color.appBg, lineWidth: 2)
                            }
                            .accessibilityLabel("Current progress along the night")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 90) // tweak the height for more/less curvature
            .animation(.easeInOut(duration: 0.6), value: progressT)
        }
        .onReceive(timer) { _ in now = Date() }
    }
}

/// MARK: - Arch math & shapes

/// Bezier helpers for a pleasant arch:
/// Start at bottom-left, rise to a soft apex, end at bottom-right.
/// t ∈ [0,1] maps monotonically along x so it’s fine to use as "time".
fileprivate enum ArchGeometry {
    static func controlPoints(width: CGFloat, height: CGFloat) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        let start = CGPoint(x: 0, y: height - 8)
        let end   = CGPoint(x: width, y: height - 8)
        // Controls shape how “arched” the curve is; tweak yPeak for more/less arc
        let yPeak = max(12.0, height * 0.18)
        let c1 = CGPoint(x: width * 0.25, y: yPeak)
        let c2 = CGPoint(x: width * 0.75, y: yPeak)
        return (start, c1, c2, end)
    }

    static func pointOnArch(width: CGFloat, height: CGFloat, t: CGFloat) -> CGPoint {
        let clampedT = min(max(t, 0), 1)
        let (p0, p1, p2, p3) = controlPoints(width: width, height: height)
        // Cubic Bezier blending
        let u = 1 - clampedT
        let tt = clampedT * clampedT
        let uu = u * u
        let uuu = uu * u
        let ttt = tt * clampedT

        var p = CGPoint.zero
        p.x = uuu * p0.x + 3 * uu * clampedT * p1.x + 3 * u * tt * p2.x + ttt * p3.x
        p.y = uuu * p0.y + 3 * uu * clampedT * p1.y + 3 * u * tt * p2.y + ttt * p3.y
        return p
    }

    /// Builds a path along the arch from tStart → tEnd by sampling.
    static func archPath(width: CGFloat, height: CGFloat, tStart: CGFloat, tEnd: CGFloat, steps: Int = 80) -> Path {
        var path = Path()
        let s = min(max(tStart, 0), 1)
        let e = min(max(tEnd, 0), 1)
        guard e > s else { return path }

        let n = max(2, steps)
        let dt = (e - s) / CGFloat(n - 1)

        let first = pointOnArch(width: width, height: height, t: s)
        path.move(to: first)

        for i in 1..<n {
            let t = s + CGFloat(i) * dt
            let p = pointOnArch(width: width, height: height, t: t)
            path.addLine(to: p)
        }
        return path
    }
}

/// Full track (0 → 1)
fileprivate struct ArchTrack: Shape {
    let width: CGFloat
    let height: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        ArchGeometry.archPath(width: width, height: height, tStart: 0, tEnd: 1)
    }
}

/// Partial segment along the arch (tStart → tEnd)
fileprivate struct ArchSegment: Shape {
    let width: CGFloat
    let height: CGFloat
    let tStart: CGFloat
    let tEnd: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        ArchGeometry.archPath(width: width, height: height, tStart: tStart, tEnd: tEnd)
    }
}

