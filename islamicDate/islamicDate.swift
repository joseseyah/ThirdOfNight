//
//  islamicDate.swift
//  islamicDate
//
//  Created by Joseph Hayes on 18/01/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), islamicDate: "1 Muharram 1445")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), islamicDate: getIslamicDate(from: Date()))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline with a single entry for simplicity
        let currentDate = Date()
        let islamicDate = getIslamicDate(from: currentDate)
        let entry = SimpleEntry(date: currentDate, islamicDate: islamicDate)
        entries.append(entry)

        // Refresh daily
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // Function to get Islamic date (replace this with an actual Islamic calendar logic)
    func getIslamicDate(from date: Date) -> String {
        // Replace this with an actual implementation to calculate Islamic date
        // Placeholder value
        return "6 Jumada II 1446"
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let islamicDate: String
}

struct IslamicDateEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SquareView(color: Color("DayBoxBackgroundColor"), text: "Islamic")
                SquareView(color: Color("DayHighlightColor"), text: "Date")
            }
            HStack(spacing: 10) {
                SquareView(color: Color("HighlightColor"), text: entry.islamicDate)
                SquareView(color: Color("DayPageBackgroundColor"), text: "1446")
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
    }
}

struct SquareView: View {
    let color: Color
    let text: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 70, height: 70)
    }
}

@main
struct IslamicDateWidget: Widget {
    let kind: String = "IslamicDate"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            IslamicDateEntryView(entry: entry)
        }
        .configurationDisplayName("Islamic Date Widget")
        .description("Shows the current Islamic date.")
        .supportedFamilies([.systemSmall])
    }
}
