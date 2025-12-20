//
//  prayertimesLiveActivity.swift
//  prayertimes
//
//  Created by Joseph Hanson Villar Hayes on 17/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct prayertimesAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct prayertimesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: prayertimesAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.appBg)
            .activitySystemActionForegroundColor(Color.textPrimaryLight)

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
            .keylineTint(Color.accentPurple)
        }
    }
}

extension prayertimesAttributes {
    fileprivate static var preview: prayertimesAttributes {
        prayertimesAttributes(name: "World")
    }
}

extension prayertimesAttributes.ContentState {
    fileprivate static var smiley: prayertimesAttributes.ContentState {
        prayertimesAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: prayertimesAttributes.ContentState {
         prayertimesAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: prayertimesAttributes.preview) {
   prayertimesLiveActivity()
} contentStates: {
    prayertimesAttributes.ContentState.smiley
    prayertimesAttributes.ContentState.starEyes
}
