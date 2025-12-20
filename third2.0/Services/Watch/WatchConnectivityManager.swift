//
//  WatchConnectivityManager.swift
//  Night Prayers
//
//  Created for Watch integration
//

import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isWatchConnected = false
    @Published var isReachable = false
    
    private var session: WCSession?
    private var connectionMonitor: Timer?
    var onPrayerDetected: ((String) -> Void)?
    
    override init() {
        super.init()
        setupWatchConnectivity()
        startConnectionMonitoring()
    }
    
    deinit {
        connectionMonitor?.invalidate()
        connectionMonitor = nil
    }

    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity is not supported on this device")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        
        // Activate session to maintain persistent connection
        if session?.activationState != .activated {
            session?.activate()
        }
    }
    
    /// Ensure session remains active - maintains persistent connection
    private func ensureSessionActive() {
        guard let session = session else {
            setupWatchConnectivity()
            return
        }
        
        if session.activationState != .activated {
            print("iPhone: Session not active, reactivating...")
            session.activate()
        }
    }
    
    /// Start monitoring connection to maintain persistent link
    private func startConnectionMonitoring() {
        // Monitor connection every 15 seconds
        connectionMonitor = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.ensureSessionActive()
            }
        }
    }
    
    /// Stop connection monitoring
    private func stopConnectionMonitoring() {
        connectionMonitor?.invalidate()
        connectionMonitor = nil
    }
    
    func sendPrayerCompletionConfirmation(prayerName: String) {
        guard let session = session, session.isReachable else {
            // If watch is not reachable, send via background transfer
            sendBackgroundMessage(prayerName: prayerName)
            return
        }
        
        let message: [String: Any] = [
            "type": "prayerCompleted",
            "prayerName": prayerName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending prayer completion confirmation: \(error.localizedDescription)")
        }
    }
    
    private func sendBackgroundMessage(prayerName: String) {
        guard let session = session else { return }
        
        let message: [String: Any] = [
            "type": "prayerCompleted",
            "prayerName": prayerName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try session.updateApplicationContext(message)
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            switch activationState {
            case .activated:
                self.isWatchConnected = true
                self.isReachable = session.isReachable
                print("✅ iPhone: WatchConnectivity session activated - Connection established")
                
            case .notActivated:
                self.isWatchConnected = false
                self.isReachable = false
                print("⚠️ iPhone: WatchConnectivity session not activated")
                
                // Try to reactivate
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    session.activate()
                }
                
            case .inactive:
                self.isWatchConnected = false
                self.isReachable = false
                print("⚠️ iPhone: WatchConnectivity session inactive - Attempting reactivation")
                
                // Reactivate immediately
                session.activate()
            @unknown default:
                self.isWatchConnected = false
                self.isReachable = false
            }
            
            if let error = error {
                print("❌ iPhone: WatchConnectivity activation error: \(error.localizedDescription)")
                // Retry activation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    session.activate()
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            print("⚠️ iPhone: Session became inactive - Reactivating...")
            self.isWatchConnected = false
            self.isReachable = false
            session.activate()
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            print("⚠️ iPhone: Session deactivated - Reactivating...")
            self.isWatchConnected = false
            self.isReachable = false
            // Reactivate immediately to maintain persistent connection
            session.activate()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            let wasReachable = self.isReachable
            self.isReachable = session.isReachable
            self.isWatchConnected = session.isPaired && (session.activationState == .activated)
            
            if self.isReachable && !wasReachable {
                print("✅ iPhone: Watch became reachable - Connection restored")
            } else if !self.isReachable && wasReachable {
                print("⚠️ iPhone: Watch became unreachable - Will retry")
            }
        }
    }
    
    // Receive messages from Watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleWatchMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            self.handleWatchMessage(message)
            // Send acknowledgment
            replyHandler(["status": "received"])
        }
    }
    
    // Receive application context from Watch
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleWatchMessage(applicationContext)
        }
    }
    
    private func handleWatchMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "prayerDetected":
            if let prayerName = message["prayerName"] as? String {
                onPrayerDetected?(prayerName)
            }
        case "heartbeat":
            // Acknowledge heartbeat to maintain connection
            print("💓 iPhone: Received heartbeat from Watch - Connection alive")
            // Optionally send response
            if let session = session, session.isReachable {
                let response: [String: Any] = [
                    "type": "heartbeatAck",
                    "timestamp": Date().timeIntervalSince1970
                ]
                session.sendMessage(response, replyHandler: nil) { sendError in
                    print("Error sending heartbeat ack: \(sendError.localizedDescription)")
                }


            }
        default:
            break
        }
    }
}

