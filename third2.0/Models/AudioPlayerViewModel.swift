//
//  AudioPlayerViewModel.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/12/2024.
//

import AVFoundation
import MediaPlayer

class AudioPlayerViewModel: ObservableObject {
    @Published var currentTrackIndex: Int? = nil
    @Published var isPlaying: Bool = false
    @Published var audioPlayer: AVAudioPlayer? = nil
    @Published var showDetailView: Bool = false
    @Published var isMinimizedViewVisible: Bool = true

    func playAudio(fileName: String, surahName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            print("Error: Audio file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
            isPlaying = true
            updateNowPlayingInfo(surahName: surahName)
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



