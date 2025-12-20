//
//  LastThirdTimerWidgetLiveActivity.swift
//  LastThirdTimerWidget
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Helper function for formatting time
private func formatTimeInterval(_ interval: TimeInterval) -> String {
    let hours = Int(interval) / 3600
    let minutes = (Int(interval) % 3600) / 60
    let seconds = Int(interval) % 60
    
    if hours > 0 {
        return String(format: "%dh %02dm", hours, minutes)
    } else if minutes > 0 {
        return String(format: "%dm %02ds", minutes, seconds)
    } else {
        return String(format: "%ds", seconds)
    }
}

struct LastThirdTimerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeUntil: TimeInterval?
        var isInLastThird: Bool
    }
    
    var name: String
}

struct LastThirdTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LastThirdTimerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.accentPurple)
                    Text("Last Third Timer")
                        .font(.headline)
                        .foregroundColor(.textPrimaryLight)
                    Spacer()
                }
                
                if let timeUntil = context.state.timeUntil {
                    Text(formatTimeInterval(timeUntil))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimaryLight)
                        .monospacedDigit()
                }
            }
            .padding()
            .background(Color.appBg)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.accentPurple)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let timeUntil = context.state.timeUntil {
                        Text(formatTimeInterval(timeUntil))
                            .font(.headline)
                            .foregroundColor(.textPrimaryLight)
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Last Third of the Night")
                        .font(.caption)
                        .foregroundColor(.textSecondaryLight)
                }
            } compactLeading: {
                Image(systemName: "moon.fill")
                    .foregroundColor(.accentMoon)
            } compactTrailing: {
                if let timeUntil = context.state.timeUntil {
                    Text(formatTimeInterval(timeUntil))
                        .font(.caption2)
                        .monospacedDigit()
                }
            } minimal: {
                Image(systemName: "moon.fill")
                    .foregroundColor(.accentMoon)
            }
        }
    }
}
