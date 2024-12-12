import SwiftUI
import AVKit
import MediaPlayer

struct DetailView: View {
    @Binding var currentTrackIndex: Int? // Optional binding
    @Binding var isPlaying: Bool
    @Binding var audioPlayer: AVAudioPlayer?

    @State private var currentTime: TimeInterval = 0.0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            if let currentIndex = currentTrackIndex { // Safely unwrap the index
                // Surah Image
                Image(surahs[currentIndex].imageFileName)
                    .resizable()
                    .frame(width: 250, height: 250) // Reduced size
                    .cornerRadius(12)
                    .padding()

                // Surah Name
                Text(surahs[currentIndex].name)
                    .font(.title)
                    .padding()

                // Playback Slider
                if let audioPlayer = audioPlayer {
                    VStack {
                        Slider(value: $currentTime, in: 0...audioPlayer.duration, onEditingChanged: { editing in
                            if !editing {
                                audioPlayer.currentTime = currentTime
                            }
                        })
                        .accentColor(Color("HighlightColor"))
                        .padding()

                        // Current time and duration
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.caption)
                            Spacer()
                            Text(formatTime(audioPlayer.duration))
                                .font(.caption)
                        }
                        .padding([.horizontal, .bottom])

                        // Playback Controls
                        HStack {
                            // Previous Track
                            Button(action: previousTrack) {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                                    .foregroundColor(Color("HighlightColor"))
                                    .padding()
                            }

                            Spacer()

                            // Play/Pause Button
                            Button(action: togglePlayback) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color("HighlightColor"))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            // Next Track
                            Button(action: nextTrack) {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                                    .foregroundColor(Color("HighlightColor"))
                                    .padding()
                            }
                        }
                        .padding([.horizontal, .top])
                    }
                }
            } else {
                Text("No Surah Selected")
                    .font(.headline)
                    .padding()
            }
            Spacer()
        }
        .onAppear {
            updateNowPlayingInfo()
            setupRemoteTransportControls()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .navigationTitle(currentTrackIndex != nil ? surahs[currentTrackIndex!].name : "Quran")
    }

    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    private func previousTrack() {
        guard let currentIndex = currentTrackIndex else { return }
        // Stop the current track before switching
        audioPlayer?.stop()
        isPlaying = false

        // Move to the previous track index (circular behavior)
        currentTrackIndex = (currentIndex - 1 + surahs.count) % surahs.count
        playCurrentTrack()
    }

    private func nextTrack() {
        guard let currentIndex = currentTrackIndex else { return }
        // Stop the current track before switching
        audioPlayer?.stop()
        isPlaying = false

        // Move to the next track index (circular behavior)
        currentTrackIndex = (currentIndex + 1) % surahs.count
        playCurrentTrack()
    }

    private func playCurrentTrack() {
        guard let currentIndex = currentTrackIndex else { return }
        let surah = surahs[currentIndex]
        if let path = Bundle.main.path(forResource: surah.audioFileName, ofType: "mp3") {
            do {
                // Initialize the audio player with the new track
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
                isPlaying = true

                // Update Now Playing info
                updateNowPlayingInfo()
            } catch {
                print("Error: Could not play audio file. \(error.localizedDescription)")
            }
        } else {
            print("Error: Audio file not found.")
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let audioPlayer = audioPlayer {
                currentTime = audioPlayer.currentTime
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func updateNowPlayingInfo() {
        guard let audioPlayer = audioPlayer, let currentIndex = currentTrackIndex else { return }
        let surah = surahs[currentIndex]

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = surah.name
        if let image = UIImage(named: surah.imageFileName) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            if !self.isPlaying {
                self.audioPlayer?.play()
                self.isPlaying = true
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { _ in
            if self.isPlaying {
                self.audioPlayer?.pause()
                self.isPlaying = false
                self.updateNowPlayingInfo()
                return .success
            }
            return .commandFailed
        }

        commandCenter.nextTrackCommand.addTarget { _ in
            self.nextTrack()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            self.previousTrack()
            return .success
        }
    }
}
