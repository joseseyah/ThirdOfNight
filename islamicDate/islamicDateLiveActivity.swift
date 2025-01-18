//
//  islamicDateLiveActivity.swift
//  islamicDate
//
//  Created by Joseph Hayes on 18/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct islamicDateAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct islamicDateLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: islamicDateAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension islamicDateAttributes {
    fileprivate static var preview: islamicDateAttributes {
        islamicDateAttributes(name: "World")
    }
}

extension islamicDateAttributes.ContentState {
    fileprivate static var smiley: islamicDateAttributes.ContentState {
        islamicDateAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: islamicDateAttributes.ContentState {
         islamicDateAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: islamicDateAttributes.preview) {
   islamicDateLiveActivity()
} contentStates: {
    islamicDateAttributes.ContentState.smiley
    islamicDateAttributes.ContentState.starEyes
}
