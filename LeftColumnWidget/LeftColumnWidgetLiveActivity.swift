//
//  LeftColumnWidgetLiveActivity.swift
//  LeftColumnWidget
//
//  Created by Joseph Hayes on 10/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LeftColumnWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LeftColumnWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LeftColumnWidgetAttributes.self) { context in
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

extension LeftColumnWidgetAttributes {
    fileprivate static var preview: LeftColumnWidgetAttributes {
        LeftColumnWidgetAttributes(name: "World")
    }
}

extension LeftColumnWidgetAttributes.ContentState {
    fileprivate static var smiley: LeftColumnWidgetAttributes.ContentState {
        LeftColumnWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LeftColumnWidgetAttributes.ContentState {
         LeftColumnWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LeftColumnWidgetAttributes.preview) {
   LeftColumnWidgetLiveActivity()
} contentStates: {
    LeftColumnWidgetAttributes.ContentState.smiley
    LeftColumnWidgetAttributes.ContentState.starEyes
}
