import Foundation
import SwiftUI

struct TimeBox: View {
    var title: String
    var time: String
    var isDaytime: Bool  // Add a property to indicate day or night mode

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(isDaytime ? .black : .white)
            
            Text(time)
                .font(.system(size: 30, weight: .bold))  // Reduced the font size
                .foregroundColor(Color(isDaytime ? "DayHighlightColor" : "HighlightColor"))
        }
        .padding(10)  // Reduced padding
        .frame(maxWidth: .infinity)
        .background(Color(isDaytime ? "DayBoxBackgroundColor" : "BoxBackgroundColor").opacity(0.8))
        .cornerRadius(12)  // Slightly smaller corner radius
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)  // Adjusted shadow
    }
}
