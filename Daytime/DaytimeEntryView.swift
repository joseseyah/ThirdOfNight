import WidgetKit
import SwiftUI
import Foundation

struct DaytimeEntryView: View {
    var entry: DaytimePrayerTimelineProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("University of Manchester ISoc")
                .font(.headline)
                .foregroundColor(Color(hex: "#FFB347")) // HighlightColor

            ForEach(entry.prayers, id: \.name) { prayer in
                HStack {
                    Text(prayer.name)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                    Text(prayer.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color(hex: "#B5D1E8")) // BoxBackgroundColor
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(hex: "#DCE8F2")) // BackgroundColor
        .cornerRadius(15)
    }
}
