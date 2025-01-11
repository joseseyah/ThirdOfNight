import Foundation
import SwiftUI
struct PrayerTimeRow: View {
    var name: String
    var time: String

    var body: some View {
        HStack {
            Text(name)
                .font(.caption2)
                .foregroundColor(.primary)
            Spacer()
            Text(time)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}
