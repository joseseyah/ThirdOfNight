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
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("HighlightColor"))
                    TextField("Search Surah...", text: $searchText)
                        .foregroundColor(Color("HighlightColor"))
                }
                .padding(10)
                .background(Color("PageBackgroundColor"))
                .cornerRadius(8)
                .padding([.horizontal, .top])

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
                        .background(Color("PageBackgroundColor"))
                        .cornerRadius(12)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Quran")
        }
    }

    private func playSurah(_ surah: Surah) {
        if let index = surahs.firstIndex(where: { $0.id == surah.id }) {
            audioPlayerViewModel.currentTrackIndex = index
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

