import SwiftUI

struct BasicPrayerGuidance: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            PrayerDetailView(prayer: "Fajr")
                .tabItem {
                    Text("Obligatory Prayers")
                }
                .tag(0)
            
            PrayerDetailView(prayer: "Dhuhr")
                .tabItem {
                    Text("Obligatory Prayers")
                }
                .tag(1)
            
            PrayerDetailView(prayer: "Asr")
                .tabItem {
                    Text("Obligatory Prayers")
                }
                .tag(2)
            
            PrayerDetailView(prayer: "Maghrib")
                .tabItem {
                    Text("Obligatory Prayers")
                }
                .tag(3)
            
            PrayerDetailView(prayer: "Isha")
                .tabItem {
                    Text("Obligatory Prayers")
                }
                .tag(4)
            
            PrayerDetailView(prayer: "Voluntary")
                .tabItem {
                    Text("Voluntary Prayer")
                }
                .tag(5)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .navigationTitle(selectedTabIndex == 5 ? "Voluntary Prayer" : "Obligatory Prayers")
    }
}
