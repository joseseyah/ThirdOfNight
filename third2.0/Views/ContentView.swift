import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject var viewModel = CityViewModel() // Shared instance of the view model
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel() // Global audio player state
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false // Track onboarding status

    var body: some View {
        Group {
            if hasSeenOnboarding {
                // Main App Content
                mainContent
            } else {
                // Onboarding View
                OnboardingView()
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            // Main TabView
            TabView(selection: $selectedTab) {
                // Prayer Tab
                PrayerView(viewModel: viewModel)
                    .tabItem {
                        Label("Prayer", systemImage: "moon.stars.fill")
                    }
                    .tag(0)

                // Surah Mulk Tab
                SurahMulkView()
                    .tabItem {
                        Label("Surah Mulk", systemImage: "book.fill")
                    }
                    .tag(1)

                // Tasbih Counter Tab
                TasbihCounterView()
                    .tabItem {
                        Label("Tasbih", systemImage: "circle.grid.3x3.fill")
                    }
                    .tag(2)

                // Quran Tab
                QuranView(audioPlayerViewModel: audioPlayerViewModel) // Pass ViewModel
                    .tabItem {
                        Label("Quran", systemImage: "book.closed.fill")
                    }
                    .tag(3)

                // Settings Tab
                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .accentColor(.orange)

            // Minimized Audio Player Overlay
            if let currentIndex = audioPlayerViewModel.currentTrackIndex {
                VStack {
                    Spacer() // Push the player above the TabView
                    MinimizedAudioPlayerView(
                        surah: surahs[currentIndex],
                        isPlaying: $audioPlayerViewModel.isPlaying,
                        audioPlayer: $audioPlayerViewModel.audioPlayer,
                        showDetailView: $audioPlayerViewModel.showDetailView
                    )
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 48) // Adjust this to avoid overlapping the TabView
            }
        }
        // Proper Binding to handle the sheet presentation for DetailView
        .sheet(isPresented: $audioPlayerViewModel.showDetailView) {
            if let currentIndex = audioPlayerViewModel.currentTrackIndex {
                DetailView(
                    currentTrackIndex: $audioPlayerViewModel.currentTrackIndex,
                    isPlaying: $audioPlayerViewModel.isPlaying,
                    audioPlayer: $audioPlayerViewModel.audioPlayer
                )
            }
        }
    }
}
