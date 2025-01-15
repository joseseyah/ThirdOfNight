//
//  NetworkMonitor.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/01/2025.
//

import Network
import SwiftUI

class NetworkMonitorSurahs: ObservableObject {
    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue.global()
    @Published var isConnected: Bool = false
    @Published var isExpensive: Bool = true // True if the connection is cellular

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive // isExpensive is true for cellular connections
            }
        }
        monitor?.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
}

