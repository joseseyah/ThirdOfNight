//
//  WatchConnectivityManagerWatch.swift
//  Night Prayers Watch App
//
//  WatchConnectivity manager for Watch app
//

import Foundation
import WatchConnectivity
import UserNotifications

@MainActor
class WatchConnectivityManagerWatch: NSObject, ObservableObject {
    static let shared = WatchConnectivityManagerWatch()
    
    @Published var isPhoneConnected = false
    
    private var session: WCSession?
    
    // This is where your trained model would detect prayers
    // Initialize with your actual model implementation
    var prayerDetectionModel: PrayerDetectionModel? = PrayerDetectionModel()
    
    override init() {
        super.init()
        setupWatchConnectivity()
        requestNotificationPermissions()
    }
    
    private func setupWatchConnectivity() {
        guard WCSession.isSupported() else {
            print("WatchConnectivity is not supported on this Watch")
            return
        }
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
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
    
    /// Send notification to Watch when prayer is completed
    func sendPrayerCompletionNotification(prayerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Prayer Completed"
        content.body = "You have completed \(prayerName)"
        content.sound = .default
        content.categoryIdentifier = "PRAYER_COMPLETED"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate notification
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}

extension WatchConnectivityManagerWatch: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isPhoneConnected = (activationState == .activated)
            if let error = error {
                print("WatchConnectivity activation error: \(error.localizedDescription)")
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPhoneConnected = session.isReachable
        }
    }
    
    // Receive messages from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handlePhoneMessage(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            self.handlePhoneMessage(message)
            replyHandler(["status": "received"])
        }
    }
    
    // Receive application context from iPhone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handlePhoneMessage(applicationContext)
        }
    }
    
    private func handlePhoneMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "prayerCompleted":
            if let prayerName = message["prayerName"] as? String {
                // Show notification on Watch
                sendPrayerCompletionNotification(prayerName: prayerName)
            }
        default:
            break
        }
    }
}

// PrayerDetectionModel is defined in PrayerDetectionModelExample.swift
// Replace that file with your actual model integration

