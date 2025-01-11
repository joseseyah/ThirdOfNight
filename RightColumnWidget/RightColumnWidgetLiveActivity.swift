//
//  RightColumnWidgetLiveActivity.swift
//  RightColumnWidget
//
//  Created by Joseph Hayes on 10/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RightColumnWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct RightColumnWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RightColumnWidgetAttributes.self) { context in
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

extension RightColumnWidgetAttributes {
    fileprivate static var preview: RightColumnWidgetAttributes {
        RightColumnWidgetAttributes(name: "World")
    }
}

extension RightColumnWidgetAttributes.ContentState {
    fileprivate static var smiley: RightColumnWidgetAttributes.ContentState {
        RightColumnWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: RightColumnWidgetAttributes.ContentState {
         RightColumnWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: RightColumnWidgetAttributes.preview) {
   RightColumnWidgetLiveActivity()
} contentStates: {
    RightColumnWidgetAttributes.ContentState.smiley
    RightColumnWidgetAttributes.ContentState.starEyes
}
