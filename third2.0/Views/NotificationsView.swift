import Foundation
import SwiftUI

// Notifications Settings View
struct NotificationsView: View {
    @Binding var azaanNotifications: Bool
    @Binding var prayerReminderNotifications: Bool

    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text("Notifications")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Toggle(isOn: $azaanNotifications) {
                    Text("Azaan Notifications")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color("BoxBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

                Toggle(isOn: $prayerReminderNotifications) {
                    Text("Prayer Reminders")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color("BoxBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

                Spacer()
            }
            .padding()
        }
    }
}
