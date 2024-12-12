//
//  DaytimePrayerTimelineProvider.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 01/12/2024.
//

import WidgetKit
import SwiftUI

struct DaytimePrayerTimelineProvider: TimelineProvider {
    // Placeholder: Used when the widget is loading
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), prayers: staticPrayerTimes)
    }

    // Snapshot: A quick preview of the widget
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), prayers: staticPrayerTimes)
        completion(entry)
    }

    // Timeline: Defines the timeline of updates for the widget
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Create a single entry with static prayer times
        let entry = SimpleEntry(date: Date(), prayers: staticPrayerTimes)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

