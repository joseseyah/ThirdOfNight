//
//  RemoteControlHandler.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 19/12/2024.
//

import Foundation
import UIKit
import SwiftUI

class RemoteControlHandler: UIResponder {
    var audioPlayerViewModel: AudioPlayerViewModel

    init(audioPlayerViewModel: AudioPlayerViewModel) {
        self.audioPlayerViewModel = audioPlayerViewModel
        super.init()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }
        if event.type == .remoteControl {
            switch event.subtype {
            case .remoteControlPlay:
                audioPlayerViewModel.resumeAudio()
            case .remoteControlPause:
                audioPlayerViewModel.pauseAudio()
            case .remoteControlTogglePlayPause:
                if audioPlayerViewModel.isPlaying {
                    audioPlayerViewModel.pauseAudio()
                } else {
                    audioPlayerViewModel.resumeAudio()
                }
            default:
                break
            }
        }
    }
}

struct RemoteControlWrapper: UIViewControllerRepresentable {
    var audioPlayerViewModel: AudioPlayerViewModel

    func makeUIViewController(context: Context) -> RemoteControlHostingController {
        // Create a hosting controller with the remote control handler
        let remoteControlHostingController = RemoteControlHostingController()
        remoteControlHostingController.audioPlayerViewModel = audioPlayerViewModel
        return remoteControlHostingController
    }

    func updateUIViewController(_ uiViewController: RemoteControlHostingController, context: Context) {}
}

