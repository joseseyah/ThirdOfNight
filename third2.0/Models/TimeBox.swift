import Foundation
import SwiftUI

struct TimeBox: View {
    var title: String
    var time: String
    var isDaytime: Bool

    var body: some View {
        VStack(spacing: 4) { // Reduced spacing between title and time
            Text(title)
                .font(.subheadline) // Smaller font size for title
                .foregroundColor(isDaytime ? .black : .white)
                .multilineTextAlignment(.center)

            Text(time)
                .font(.title2) // Reduced font size for time
                .fontWeight(.bold)
                .foregroundColor(Color(isDaytime ? "DayHighlightColor" : "HighlightColor"))
        }
        .padding(8) // Reduced padding
        .frame(maxWidth: .infinity, minHeight: 50) // Set consistent height
        .background(Color(isDaytime ? "DayBoxBackgroundColor" : "BoxBackgroundColor").opacity(0.9))
        .cornerRadius(10) // Slightly smaller corner radius
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow
    }
}

