import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject var viewModel = CityViewModel()
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var isMinimizedViewVisible = true

    var body: some View {
        Group {
            if hasSeenOnboarding {
                mainContent
            } else {
                OnboardingView()
            }
        }
        .onChange(of: audioPlayerViewModel.currentTrackIndex) { _ in
            if audioPlayerViewModel.currentTrackIndex != nil {
                isMinimizedViewVisible = true
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            // Add a custom background for the TabView
            Color.white.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                PrayerView(viewModel: viewModel)
                    .tabItem {
                        Label("Prayer", systemImage: "moon.stars.fill")
                    }
                    .tag(0)

                SurahMulkView()
                    .tabItem {
                        Label("Surah Mulk", systemImage: "book.fill")
                    }
                    .tag(1)

                TasbihCounterView()
                    .tabItem {
                        Label("Tasbih", systemImage: "circle.grid.3x3.fill")
                    }
                    .tag(2)

                QuranView(audioPlayerViewModel: audioPlayerViewModel)
                    .tabItem {
                        Label("Quran", systemImage: "book.closed.fill")
                    }
                    .tag(3)

                SettingsView(viewModel: viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .accentColor(.orange) // Highlighted tab color
            .background(Color("TabBarBackgroundColor").ignoresSafeArea()) // Custom tab bar background color
            .onAppear {
                UITabBar.appearance().barTintColor = UIColor(named: "TabBarBackgroundColor") // Adjust tab bar background color
                UITabBar.appearance().unselectedItemTintColor = UIColor.gray // Darker gray for inactive tabs
            }

            // Minimized Audio Player Overlay
            if let currentIndex = audioPlayerViewModel.currentTrackIndex, audioPlayerViewModel.isMinimizedViewVisible {
                VStack {
                    Spacer()
                    MinimizedAudioPlayerView(
                        surah: surahs[currentIndex],
                        isPlaying: $audioPlayerViewModel.isPlaying,
                        audioPlayer: $audioPlayerViewModel.audioPlayer,
                        showDetailView: $audioPlayerViewModel.showDetailView,
                        isMinimizedViewVisible: $audioPlayerViewModel.isMinimizedViewVisible
                    )
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 48)
            }
        }
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
