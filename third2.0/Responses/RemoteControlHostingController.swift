//
//  RemoteControlHostingController.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 19/12/2024.
//

import Foundation
import UIKit

class RemoteControlHostingController: UIViewController {
    var audioPlayerViewModel: AudioPlayerViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event, let viewModel = audioPlayerViewModel else { return }
        if event.type == .remoteControl {
            switch event.subtype {
            case .remoteControlPlay:
                viewModel.resumeAudio()
            case .remoteControlPause:
                viewModel.pauseAudio()
            case .remoteControlTogglePlayPause:
                if viewModel.isPlaying {
                    viewModel.pauseAudio()
                } else {
                    viewModel.resumeAudio()
                }
            default:
                break
            }
        }
    }
}
