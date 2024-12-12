import Foundation
import SwiftUI
import AVKit

struct MinimizedAudioPlayerView: View {
    let surah: Surah
    @Binding var isPlaying: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    @Binding var showDetailView: Bool

    var body: some View {
        HStack {
            // Surah Image
            Image(surah.imageFileName)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(8)

            // Surah Name and Status
            VStack(alignment: .leading) {
                Text(surah.name)
                    .font(.headline)
                Text(isPlaying ? "Playing" : "Paused")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Play/Pause Button
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .padding(8)
                    .background(Color("HighlightColor"))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }

            // Expand Button
            Button(action: {
                showDetailView = true
            }) {
                Image(systemName: "chevron.up")
                    .font(.title2)
                    .foregroundColor(Color("HighlightColor"))
            }
        }
        .padding()
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showDetailView = true
        }
    }

    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
}
