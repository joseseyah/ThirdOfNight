import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject var viewModel = CityViewModel()  // Shared instance of the view model
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Prayer Tab
            PrayerView(viewModel: viewModel)  // Pass the viewModel to PrayerView
                .tabItem {
                    Label("Prayer", systemImage: "moon.stars.fill")
                }
                .tag(0)
            
            // Surah Mulk Tab
            SurahMulkView()  // This does not need the viewModel, so no changes here
                .tabItem {
                    Label("Surah Mulk", systemImage: "book.fill")
                }
                .tag(1)
            
            // Tasbih Counter Tab
            TasbihCounterView()  // Your new TasbihCounterView here
                .tabItem {
                    Label("Tasbih", systemImage: "circle.grid.3x3.fill")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView(viewModel: viewModel)  // Pass the viewModel to SettingsView
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
