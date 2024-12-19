import AVFoundation
import MediaPlayer

class AudioPlayerViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentTrackIndex: Int? = nil
    @Published var isPlaying: Bool = false
    @Published var audioPlayer: AVAudioPlayer? = nil
    @Published var showDetailView: Bool = false
    @Published var isMinimizedViewVisible: Bool = true

    func playAudio(surahIndex: Int) {
        guard surahIndex >= 0 && surahIndex < surahs.count else { return }
        currentTrackIndex = surahIndex
        let surah = surahs[surahIndex]

        guard let path = Bundle.main.path(forResource: surah.audioFileName, ofType: "mp3") else {
            print("Error: Audio file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.delegate = self // Set delegate
            audioPlayer?.play()
            isPlaying = true
            updateNowPlayingInfo(surahName: surah.name)
        } catch {
            print("Error: Could not play audio file. \(error.localizedDescription)")
        }
    }

    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfoPlaybackRate()
    }

    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        updateNowPlayingInfoPlaybackRate()
    }

    // Move to the next Surah when the current one finishes
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard let currentIndex = currentTrackIndex else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < surahs.count {
            playAudio(surahIndex: nextIndex)
        } else {
            // End of the playlist
            currentTrackIndex = nil
            isPlaying = false
        }
    }

    private func updateNowPlayingInfo(surahName: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = surahName
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateNowPlayingInfoPlaybackRate() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    }
}
