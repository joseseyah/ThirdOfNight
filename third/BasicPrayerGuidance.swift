import SwiftUI


struct BasicPrayerGuidance: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        TabView {
            PrayerDetailView(prayer: "Fajr")
                .tabItem {
                    Text("Fajr")
                }
            
            PrayerDetailView(prayer: "Dhuhr")
                .tabItem {
                    Text("Dhuhr")
                }
            
            PrayerDetailView(prayer: "Asr")
                .tabItem {
                    Text("Asr")
                }
            
            PrayerDetailView(prayer: "Maghrib")
                .tabItem {
                    Text("Maghrib")
                }
            
            PrayerDetailView(prayer: "Isha")
                .tabItem {
                    Text("Isha")
                }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .navigationTitle("Obligatory Prayers")
    }
}

