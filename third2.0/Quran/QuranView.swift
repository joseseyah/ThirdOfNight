import Foundation
import SwiftUI
import AVKit

struct QuranView: View {
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel // Receive ViewModel
    @State private var searchText = ""

    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        } else {
            return surahs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("HighlightColor"))
                        TextField("Search Surah...", text: $searchText)
                            .foregroundColor(Color("HighlightColor"))
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search Surah...")
                                    .foregroundColor(Color.gray.opacity(0.6))
                            }
                    }
                    .padding(10)
                    .background(Color("BoxBackgroundColor"))
                    .cornerRadius(8)
                    .padding([.horizontal, .top])

                    // Surah List
                    List(filteredSurahs) { surah in
                        Button(action: {
                            playSurah(surah)
                        }) {
                            HStack {
                                Image(surah.imageFileName)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                Text(surah.name)
                                    .font(.headline)
                                    .foregroundColor(Color("HighlightColor"))
                            }
                            .padding()
                            .background(Color("BoxBackgroundColor")) // Box Background
                            .cornerRadius(12)
                        }
                        .listRowBackground(Color.clear) // Transparent row background
                    }
                    .scrollContentBackground(.hidden) // Hide default List background
                    .background(Color("BackgroundColor")) // Ensure consistent background
                }
                .navigationTitle("Quran")
                .foregroundColor(.white)
            }
        }
    }

    private func playSurah(_ surah: Surah) {
        if let index = surahs.firstIndex(where: { $0.id == surah.id }) {
            audioPlayerViewModel.currentTrackIndex = index
            audioPlayerViewModel.isMinimizedViewVisible = true // Ensure minimized view is visible
            
            if let path = Bundle.main.path(forResource: surah.audioFileName, ofType: "mp3") {
                do {
                    audioPlayerViewModel.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayerViewModel.audioPlayer?.play()
                    audioPlayerViewModel.isPlaying = true
                } catch {
                    print("Error: Could not play audio file. \(error.localizedDescription)")
                }
            } else {
                print("Error: Audio file not found.")
            }
        }
    }

}

// Add a placeholder modifier for TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder() }
            self
        }
    }
}
