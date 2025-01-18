//
//  islamicDtaeLiveActivity.swift
//  islamicDtae
//
//  Created by Joseph Hayes on 18/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct islamicDtaeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct islamicDtaeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: islamicDtaeAttributes.self) { context in
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

extension islamicDtaeAttributes {
    fileprivate static var preview: islamicDtaeAttributes {
        islamicDtaeAttributes(name: "World")
    }
}

extension islamicDtaeAttributes.ContentState {
    fileprivate static var smiley: islamicDtaeAttributes.ContentState {
        islamicDtaeAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: islamicDtaeAttributes.ContentState {
         islamicDtaeAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: islamicDtaeAttributes.preview) {
   islamicDtaeLiveActivity()
} contentStates: {
    islamicDtaeAttributes.ContentState.smiley
    islamicDtaeAttributes.ContentState.starEyes
}
