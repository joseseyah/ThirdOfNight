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
    @State private var currentTime: Date = Date()
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    // Lock the night period to prevent reset at midnight
    private var lockedNightPeriod: (start: Date, end: Date, lastThirdStart: Date, lastThirdEnd: Date)? {
        guard let start = nightStart, var end = fajr else { return nil }
        
        let calendar = Calendar.current
        let now = currentTime
        
        // Ensure Fajr is after the start (handle day boundary)
        if end <= start {
            end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }
        
        // If we're past midnight but before Fajr, ensure we're using the correct night period
        // The night should be from yesterday's Isha/Maghrib to today's Fajr
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        let nowDay = calendar.startOfDay(for: now)
        
        // If we're on a new day but before Fajr, the night period is still valid
        // If the start was yesterday and we're today, that's correct
        // If start and end are both today but end is before start, push end to tomorrow
        if nowDay > startDay && endDay == startDay {
            // We're past midnight, and Fajr hasn't been adjusted yet
            end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }
        
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return nil }
        
        let oneThird = total / 3.0
        let lastStart = end.addingTimeInterval(-oneThird)
        
        // Only return valid night period if we haven't passed Fajr yet
        if now > end {
            // Night has ended, but we can still show the period for reference
            // or return nil to show a message
        }
        
        return (start, end, lastStart, end)
    }

    private var nightStart: Date? {
        if let isha { return isha }
        return maghrib
    }

    private var isNowInLastThird: Bool {
        guard let period = lockedNightPeriod else { return false }
        return currentTime >= period.lastThirdStart && currentTime <= period.lastThirdEnd
    }
    
    private var timeUntilLastThird: TimeInterval? {
        guard let period = lockedNightPeriod else { return nil }
        if currentTime >= period.lastThirdStart {
            return 0 // Already in last third
        }
        return period.lastThirdStart.timeIntervalSince(currentTime)
    }
    
    private var timeRemainingInLastThird: TimeInterval? {
        guard let period = lockedNightPeriod else { return nil }
        if currentTime < period.lastThirdStart {
            return nil // Not in last third yet
        }
        return period.lastThirdEnd.timeIntervalSince(currentTime)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Drag indicator
                Capsule()
                    .fill(Color.stroke.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .padding(.top, 12)
                
                // Header
                VStack(spacing: 12) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.accentPurple, Color.accentPurple.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Last Third of the Night")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimaryLight)
                        
                        Spacer()
                        
                        if isNowInLastThird {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.accentPurple)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: Color.accentPurple.opacity(0.6), radius: 4)
                                
                                Text("Active")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.accentPurple)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.accentPurple.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.accentPurple.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    if let period = lockedNightPeriod {
                        // Status card
                        VStack(spacing: 16) {
                            if isNowInLastThird {
                                if let remaining = timeRemainingInLastThird {
                                    VStack(spacing: 8) {
                                        Text("You're in the Last Third")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.textPrimaryLight)
                                        
                                        Text("Time remaining: \(formatTimeInterval(remaining))")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.accentPurple)
                                    }
                                }
                            } else if let until = timeUntilLastThird {
                                VStack(spacing: 8) {
                                    Text("Last Third starts in")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.textPrimaryLight)
                                    
                                    Text(formatTimeInterval(until))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentPurple)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    isNowInLastThird
                                        ? LinearGradient(
                                            colors: [
                                                Color.accentPurple.opacity(0.3),
                                                Color.accentPurple.opacity(0.15)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [
                                                Color.accentPurple.opacity(0.15),
                                                Color.accentPurple.opacity(0.08)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    isNowInLastThird
                                        ? Color.accentPurple.opacity(0.6)
                                        : Color.accentPurple.opacity(0.4),
                                    lineWidth: 1.5
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)

                if let period = lockedNightPeriod {
                    // Enhanced Progress View
                    NightProgressView(
                        nightStart: period.start,
                        fajr: period.end,
                        lastThirdStart: period.lastThirdStart,
                        currentTime: currentTime
                    )
                    .padding(.horizontal, 20)
                    
                    // Time details card
                    VStack(spacing: 0) {
                        // Night period
                        TimeDetailRow(
                            icon: "moon.stars.fill",
                            label: "Night Begins",
                            value: timeString(period.start),
                            isHighlighted: false
                        )
                        
                        Divider()
                            .background(Color.stroke.opacity(0.2))
                            .padding(.horizontal, 20)
                        
                        // Last third start
                        TimeDetailRow(
                            icon: "clock.badge.checkmark.fill",
                            label: "Last Third Begins",
                            value: timeString(period.lastThirdStart),
                            isHighlighted: true
                        )
                        
                        Divider()
                            .background(Color.stroke.opacity(0.2))
                            .padding(.horizontal, 20)
                        
                        // Fajr
                        TimeDetailRow(
                            icon: "sun.and.horizon.fill",
                            label: "Fajr (Night Ends)",
                            value: timeString(period.end),
                            isHighlighted: false
                        )
                    }
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.stroke.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentPurple)
                        
                        Text("The last third is the most blessed time for night prayers and supplications.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.textPrimaryLight)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.accentPurple.opacity(0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.accentPurple.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 20)
                    
                } else {
                    // Error state
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.textSecondary.opacity(0.7))
                        
                        Text("Unable to Calculate")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        
                        Text("We need Isha or Maghrib and Fajr times to calculate the last third of the night.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.textPrimary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.stroke.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
            }
        }
        .background(Color.appBg.ignoresSafeArea())
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Helpers
    
    private func timeString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = .current
        fmt.timeZone = timezone
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Time Detail Row

private struct TimeDetailRow: View {
    let icon: String
    let label: String
    let value: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    isHighlighted
                        ? LinearGradient(
                            colors: [Color.accentPurple, Color.accentPurple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.textPrimary.opacity(0.7), Color.textPrimary.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .frame(width: 32)
            
            Text(label)
                .font(.system(size: 15, weight: isHighlighted ? .bold : .semibold, design: .rounded))
                .foregroundColor(isHighlighted ? .textPrimary : .textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: isHighlighted ? .bold : .medium, design: .rounded))
                .foregroundColor(isHighlighted ? .accentPurple : .textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            isHighlighted
                                ? Color.accentPurple.opacity(0.2)
                                : Color.stroke.opacity(0.1)
                        )
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Night Progress View

private struct NightProgressView: View {
    let nightStart: Date
    let fajr: Date
    let lastThirdStart: Date
    let currentTime: Date
    
    private var total: TimeInterval {
        fajr.timeIntervalSince(nightStart)
    }
    
    private var clampedElapsed: TimeInterval {
        guard total > 0 else { return 0 }
        let elapsed = currentTime.timeIntervalSince(nightStart)
        // Clamp between 0 and total, but allow it to go slightly over to show completion
        return max(0, min(elapsed, total * 1.01))
    }
    
    private var progressT: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(clampedElapsed / total)
    }
    
    private var lastThirdT: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(lastThirdStart.timeIntervalSince(nightStart) / total)
    }
    
    private var isInLastThird: Bool {
        currentTime >= lastThirdStart && currentTime <= fajr
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Night Progress")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(Int(progressT * 100))%")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isInLastThird ? .accentPurple : .textSecondary)
            }
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = max(80.0, geo.size.height)
                
                ZStack {
                    // Base track with gradient - enhanced for visibility
                    ArchTrack(width: w, height: h, lineWidth: 12)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.stroke.opacity(0.4),
                                    Color.stroke.opacity(0.25)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                    
                    // Last third highlight band - enhanced for visibility
                    if lastThirdT < 1.0 {
                        ArchSegment(width: w, height: h, tStart: lastThirdT, tEnd: 1.0, lineWidth: 10)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.accentPurple.opacity(0.4),
                                        Color.accentPurple.opacity(0.3)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                    }
                    
                    // Progress stroke with glow
                    if progressT > 0 {
                        ArchSegment(width: w, height: h, tStart: 0.0, tEnd: min(progressT, 1.0), lineWidth: 10)
                            .stroke(
                                LinearGradient(
                                    colors: isInLastThird
                                        ? [
                                            Color.accentPurple,
                                            Color.accentPurple.opacity(0.8)
                                        ]
                                        : [
                                            Color.accentPurple.opacity(0.7),
                                            Color.accentPurple.opacity(0.5)
                                        ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .shadow(
                                color: Color.accentPurple.opacity(isInLastThird ? 0.5 : 0.2),
                                radius: isInLastThird ? 12 : 6,
                                x: 0,
                                y: 0
                            )
                    }
                    
                    // Last third start marker - enhanced for visibility
                    if lastThirdT > 0 && lastThirdT < 1.0 {
                        let p = ArchGeometry.pointOnArch(width: w, height: h, t: lastThirdT)
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.accentPurple)
                                .frame(width: 8, height: 8)
                                .shadow(color: Color.accentPurple.opacity(0.6), radius: 4, x: 0, y: 0)
                            
                            Text("Last Third")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentPurple.opacity(0.25))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.accentPurple.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                        .position(x: p.x, y: p.y - 22)
                    }
                    
                    // Current time marker
                    if progressT > 0 && progressT <= 1.0 {
                        let p = ArchGeometry.pointOnArch(width: w, height: h, t: progressT)
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.accentPurple.opacity(0.4),
                                            Color.accentPurple.opacity(0.0)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 12
                                    )
                                )
                                .frame(width: 24, height: 24)
                            
                            // Main marker
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.accentPurple,
                                            Color.accentPurple.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 16, height: 16)
                                .shadow(color: Color.accentPurple.opacity(0.6), radius: 8)
                            
                            // Inner highlight
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                        .position(x: p.x, y: p.y)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 120)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.cardBg)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentPurple.opacity(0.15),
                                Color.accentPurple.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    isInLastThird
                        ? Color.accentPurple.opacity(0.7)
                        : Color.accentPurple.opacity(0.5),
                    lineWidth: 2.5
                )
        )
    }
}

// MARK: - Arch Geometry

fileprivate enum ArchGeometry {
    static func controlPoints(width: CGFloat, height: CGFloat) -> (CGPoint, CGPoint, CGPoint, CGPoint) {
        let start = CGPoint(x: 0, y: height - 10)
        let end   = CGPoint(x: width, y: height - 10)
        let yPeak = max(16.0, height * 0.22)
        let c1 = CGPoint(x: width * 0.25, y: yPeak)
        let c2 = CGPoint(x: width * 0.75, y: yPeak)
        return (start, c1, c2, end)
    }

    static func pointOnArch(width: CGFloat, height: CGFloat, t: CGFloat) -> CGPoint {
        let clampedT = min(max(t, 0), 1)
        let (p0, p1, p2, p3) = controlPoints(width: width, height: height)
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

    static func archPath(width: CGFloat, height: CGFloat, tStart: CGFloat, tEnd: CGFloat, steps: Int = 100) -> Path {
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

fileprivate struct ArchTrack: Shape {
    let width: CGFloat
    let height: CGFloat
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        ArchGeometry.archPath(width: width, height: height, tStart: 0, tEnd: 1)
    }
}

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
