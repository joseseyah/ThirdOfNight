//
//  AudioPlayerViewModel.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 12/12/2024.
//

import Foundation
import AVKit
import SwiftUI

class AudioPlayerViewModel: ObservableObject {
    @Published var currentTrackIndex: Int? = nil // Index of the current Surah
    @Published var isPlaying: Bool = false
    @Published var audioPlayer: AVAudioPlayer? = nil
    @Published var showDetailView: Bool = false
}


