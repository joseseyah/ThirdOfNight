//
//  WatchConnectivityManagerWatch.swift
//  Third of the Night Watch App
//
//  WatchConnectivity manager for Watch app
//

import Foundation
import WatchConnectivity
import UserNotifications
import Combine

class WatchConnectivityManagerWatch: NSObject, ObservableObject {
    static let shared = WatchConnectivityManagerWatch()
    
    @MainActor @Published var isPhoneConnected = false
    @MainActor @Published var connectionStatus: ConnectionStatus = .disconnected
    
    enum ConnectionStatus {
        case connected
        case connecting
        case disconnected
    }
    
    private var session: WCSession?
    private var connectionMonitor: Timer?
    private var lastHeartbeat: Date?
    private let heartbeatInterval: TimeInterval = 30.0 // Send heartbeat every 30 seconds
    
    // This is where your trained model would detect prayers
    // Initialize with your actual model implementation
    var prayerDetectionModel: PrayerDetectionModel? = PrayerDetectionModel()
    
    override init() {
        super.init()

        Task { @MainActor in
            setupWatchConnectivity()
        }

        requestNotificationPermissions()
        startConnectionMonitoring()
    }

    
    deinit {
        // Timer.invalidate() is thread-safe, so we can call it directly
        connectionMonitor?.invalidate()
    }
    
    /// Start background prayer detection
    /// This should be called when the app launches to enable continuous detection
    @MainActor func startBackgroundDetection() {
        // Start detection immediately - works in background
        prayerDetectionModel?.startDetection()
        print("Background prayer detection started")
        
        // Ensure session is active
        ensureSessionActive()
    }
    
    /// Stop background prayer detection
    @MainActor func stopBackgroundDetection() {
        prayerDetectionModel?.stopDetection()
        print("Background prayer detection stopped")
    }
    
    @MainActor private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity is not supported on this Watch")
            connectionStatus = .disconnected
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        
        // Activate session - this maintains persistent connection
        if session?.activationState != .activated {
            session?.activate()
            connectionStatus = .connecting
        } else {
            connectionStatus = .connected
            isPhoneConnected = true
        }
    }
    
    /// Ensure session remains active - call this periodically to maintain connection
    @MainActor private func ensureSessionActive() {
        guard let session = session else {
            setupWatchConnectivity()
            return
        }
        
        if session.activationState != .activated {
            print("Session not active, reactivating...")
            session.activate()
            connectionStatus = .connecting
        } else {
            connectionStatus = .connected
            // On watchOS, we only check isReachable (isPaired is not available)
            isPhoneConnected = session.isReachable
        }
    }
    
    /// Start monitoring connection and sending heartbeats
    private func startConnectionMonitoring() {
        // Monitor connection every 10 seconds
        connectionMonitor = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkConnection()
                self?.sendHeartbeatIfNeeded()
            }
        }
    }
    
    /// Stop connection monitoring
    private func stopConnectionMonitoring() {
        connectionMonitor?.invalidate()
        connectionMonitor = nil
    }
    
    /// Check and maintain connection
    private func checkConnection() {
        Task { @MainActor in
            ensureSessionActive()
        }
    }
    
    /// Send heartbeat to maintain persistent connection
    @MainActor private func sendHeartbeatIfNeeded() {
        guard let session = session,
              session.activationState == .activated else {
            return
        }
        
        let now = Date()
        if let lastHeartbeat = lastHeartbeat,
           now.timeIntervalSince(lastHeartbeat) < heartbeatInterval {
            return
        }
        
        // Send heartbeat via application context (works in background)
        let heartbeat: [String: Any] = [
            "type": "heartbeat",
            "timestamp": now.timeIntervalSince1970,
            "source": "watch"
        ]
        
        do {
            try session.updateApplicationContext(heartbeat)
            lastHeartbeat = now
            print("Heartbeat sent to maintain connection")
        } catch {
            print("Error sending heartbeat: \(error.localizedDescription)")
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Call this method when your model detects a prayer
    /// This should be called from your trained model's detection callback
    func onPrayerDetected(prayerName: String) {
        print("Prayer detected: \(prayerName)")
        
        // Send prayer detection to iPhone
        sendPrayerDetectionToPhone(prayerName: prayerName)
    }
    
    private func sendPrayerDetectionToPhone(prayerName: String) {
        guard let session = session else { return }
        
        let message: [String: Any] = [
            "type": "prayerDetected",
            "prayerName": prayerName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: { reply in
                print("Received reply from iPhone: \(reply)")
            }) { error in
                print("Error sending message to iPhone: \(error.localizedDescription)")
                // Fallback to background transfer
                self.sendBackgroundMessage(message)
            }
        } else {
            // Use background transfer if phone is not reachable
            sendBackgroundMessage(message)
        }
    }
    
    private func sendBackgroundMessage(_ message: [String: Any]) {
        guard let session = session else { return }
        do {
            try session.updateApplicationContext(message)
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
    }
    
    /// Public method to ensure connection is maintained (called from App lifecycle)
    @MainActor func ensureConnection() {
        ensureSessionActive()
        sendHeartbeatIfNeeded()
    }
    
    /// Send congratulatory notification to Watch when prayer is completed
    @MainActor func sendPrayerCompletionNotification(prayerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Congrats!"
        content.body = "You have completed \(prayerName)"
        content.sound = .default
        content.categoryIdentifier = "PRAYER_COMPLETED"
        
        // Add custom sound if available (optional)
        // content.sound = UNNotificationSound(named: UNNotificationSoundName("success.wav"))
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate notification
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Successfully sent congratulatory notification for \(prayerName)")
            }
        }
    }
}

extension WatchConnectivityManagerWatch: WCSessionDelegate {
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Required for protocol conformance on some SDKs
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Required for protocol conformance on some SDKs
    }

    
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            switch activationState {
            case .activated:
                self.connectionStatus = .connected
                // On watchOS, we only check isReachable (isPaired is not available)
                self.isPhoneConnected = session.isReachable
                print("✅ WatchConnectivity session activated - Connection established")
                
                // Send initial heartbeat
                sendHeartbeatIfNeeded()
                
                // Ensure detection is running
                if prayerDetectionModel != nil {
                    startBackgroundDetection()
                }
                
            case .notActivated:
                self.connectionStatus = .disconnected
                self.isPhoneConnected = false
                print("⚠️ WatchConnectivity session not activated")
                
                // Try to reactivate
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    session.activate()
                }
                
            case .inactive:
                self.connectionStatus = .disconnected
                self.isPhoneConnected = false
                print("⚠️ WatchConnectivity session inactive - Attempting reactivation")
                
                // Reactivate immediately
                session.activate()
            @unknown default:
                self.connectionStatus = .disconnected
                self.isPhoneConnected = false
            }
            
            if let error = error {
                print("❌ WatchConnectivity activation error: \(error.localizedDescription)")
                // Retry activation after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    session.activate()
                }
            }
        }
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            let wasConnected = self.isPhoneConnected
            // On watchOS, we only check isReachable (isPaired is not available)
            self.isPhoneConnected = session.isReachable
            
            if self.isPhoneConnected && !wasConnected {
                print("✅ Phone became reachable - Connection restored")
                self.connectionStatus = .connected
                // Send heartbeat to confirm connection
                sendHeartbeatIfNeeded()
            } else if !self.isPhoneConnected && wasConnected {
                print("⚠️ Phone became unreachable - Will retry")
                self.connectionStatus = .connecting
            }
        }
    }
    
    // Note: sessionDidBecomeInactive and sessionDidDeactivate are not available on watchOS
    // Session lifecycle is handled through activationDidComplete and connection monitoring
    
    // Receive messages from iPhone
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task { @MainActor in
            self.handlePhoneMessage(message)
        }
    }
    
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            self.handlePhoneMessage(message)
            replyHandler(["status": "received"])
        }
    }
    
    // Receive application context from iPhone
    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Task { @MainActor in
            self.handlePhoneMessage(applicationContext)
        }
    }
    
    @MainActor private func handlePhoneMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "prayerCompleted":
            if let prayerName = message["prayerName"] as? String {
                // Show notification on Watch
                sendPrayerCompletionNotification(prayerName: prayerName)
            }
        case "heartbeatAck":
            // Acknowledge heartbeat received from iPhone
            print("💓 Watch: Received heartbeat acknowledgment - Connection confirmed")
            connectionStatus = .connected
            isPhoneConnected = true
        default:
            break
        }
    }
}

// PrayerDetectionModel is defined in PrayerDetectionModel.swift
// Replace that file with your actual model integration

