//
//  islamiccurrentdateLiveActivity.swift
//  islamiccurrentdate
//
//  Created by Joseph Hayes on 18/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct islamiccurrentdateAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var emoji: String
    }

    var name: String
}

struct islamiccurrentdateLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: islamiccurrentdateAttributes.self) { context in
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
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

extension islamiccurrentdateAttributes {
    fileprivate static var preview: islamiccurrentdateAttributes {
        islamiccurrentdateAttributes(name: "World")
    }
}

extension islamiccurrentdateAttributes.ContentState {
    fileprivate static var smiley: islamiccurrentdateAttributes.ContentState {
        islamiccurrentdateAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: islamiccurrentdateAttributes.ContentState {
         islamiccurrentdateAttributes.ContentState(emoji: "🤩")
     }
}
