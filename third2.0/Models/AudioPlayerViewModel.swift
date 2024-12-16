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
    @Published var currentTrackIndex: Int? = nil
    @Published var isPlaying: Bool = false
    @Published var audioPlayer: AVAudioPlayer? = nil
    @Published var showDetailView: Bool = false
    @Published var isMinimizedViewVisible: Bool = true // Add this property
}



