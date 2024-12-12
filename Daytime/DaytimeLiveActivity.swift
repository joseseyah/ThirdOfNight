//
//  DaytimeLiveActivity.swift
//  Daytime
//
//  Created by Joseph Hayes on 01/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DaytimeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DaytimeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DaytimeAttributes.self) { context in
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

extension DaytimeAttributes {
    fileprivate static var preview: DaytimeAttributes {
        DaytimeAttributes(name: "World")
    }
}

extension DaytimeAttributes.ContentState {
    fileprivate static var smiley: DaytimeAttributes.ContentState {
        DaytimeAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DaytimeAttributes.ContentState {
         DaytimeAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DaytimeAttributes.preview) {
   DaytimeLiveActivity()
} contentStates: {
    DaytimeAttributes.ContentState.smiley
    DaytimeAttributes.ContentState.starEyes
}
