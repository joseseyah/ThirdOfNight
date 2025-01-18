//
//  FirebaseHelper.swift
//  Night Prayers
//
//  Created by Waqar on 13/01/2025.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import UserNotifications

class FirebaseHelper {
    static let shared = FirebaseHelper() // Singleton instance
    
    private let db: Firestore
    private let prayerTimesCollection = "prayer_times"
    
    private init() {
        // Configure Firebase
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Setup Firestore with cache settings
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 50 * 1024 * 1024 as NSNumber) // 100 MB cache
        self.db = Firestore.firestore()
        self.db.settings = settings
       
        
        // Request notification permission
        requestNotificationPermission()
    }
    func setupFireBase(){
    }
    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted.")
            } else if let error = error {
                print("❌ Notification permission denied: \(error.localizedDescription)")
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }
    
    // MARK: - Network Management
    /// Enable offline mode (disable network)
    func enableOfflineMode(completion: @escaping (Error?) -> Void) {
        db.disableNetwork { error in
            if let error = error {
                print("❌ Failed to enable offline mode: \(error.localizedDescription)")
            } else {
                print("✅ Offline mode enabled.")
            }
            completion(error)
        }
    }
    
    /// Enable online mode (enable network)
    func enableOnlineMode(completion: @escaping (Error?) -> Void) {
        db.enableNetwork { error in
            if let error = error {
                print("❌ Failed to enable online mode: \(error.localizedDescription)")
            } else {
                print("✅ Online mode enabled.")
            }
            completion(error)
        }
    }
    
    func fetchPrayerTimesWithCity(
        city: String,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        let docRef = db.collection("prayerTimes").document(city)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error)) // Return the error if Firestore fails
                return
            }
            
            guard let document = document, document.exists else {
                let error = NSError(
                    domain: "FirestoreError",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Document for city \(city) does not exist."]
                )
                completion(.failure(error))
                return
            }
            
            guard let fetchedPrayerData = document.data()?["prayerTimes"] as? [[String: Any]] else {
                let error = NSError(
                    domain: "FirestoreError",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid data format for prayer times."]
                )
                completion(.failure(error))
                return
            }
            
            completion(.success(fetchedPrayerData)) // Success: Return fetched data
        }
    }

    /// Listen for changes to prayer times for a specific date
    func listenForPrayerTimeUpdates(for date: String, completion: @escaping ([String: Any], Bool) -> Void) {
        db.collection(prayerTimesCollection)
            .document(date)
            .addSnapshotListener(includeMetadataChanges: true) { snapshot, error in
                if let error = error {
                    print("❌ Error listening for updates: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                    print("⚠️ No data found for updates on \(date).")
                    return
                }
                
                let isFromCache = snapshot.metadata.isFromCache
                print("🔄 Prayer times updated (\(isFromCache ? "cache" : "server")): \(data)")
                completion(data, isFromCache)
            }
    }
    func updatePrayerTimes(completion: @escaping (Result<Void, Error>) -> Void) {
        let useMosqueTimetable = UserDefaults.standard.bool(forKey: "useMosqueTimetable")
        let selectedMosque = UserDefaults.standard.string(forKey: "selectedMosque") ?? ""
        let selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? ""
        
        if useMosqueTimetable {
            fetchPrayerTimes(from: "Mosques", documentID: selectedMosque, dataKey: "data", completion: completion)
        } else {
            fetchPrayerTimes(from: "prayerTimes", documentID: selectedCity, dataKey: "prayerTimes", completion: completion)
        }
    }

    private func fetchPrayerTimes(from collection: String, documentID: String, dataKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = db.collection(collection).document(documentID)
        
        docRef.getDocument { [weak self] document, error in
            if let error = error {
                self?.handleFetchFailure(error: error, completion: completion)
                return
            }
            
            guard let document = document, document.exists else {
                self?.handleFetchFailure(error: NSError(domain: "Document not found", code: 404, userInfo: nil), completion: completion)
                return
            }
            
            guard let prayerTimes = document.data()?[dataKey] as? [[String: Any]] else {
                self?.handleFetchFailure(error: NSError(domain: "Invalid data format", code: 422, userInfo: nil), completion: completion)
                return
            }
            
            self?.handleFetchSuccess(prayerTimes: prayerTimes, completion: completion)
        }
    }

    private func handleFetchSuccess(prayerTimes: [[String: Any]], completion: @escaping (Result<Void, Error>) -> Void) {
        UserDefaults.standard.set(prayerTimes, forKey: "prayerTimes")
        print("✅ Prayer times updated successfully.")
        completion(.success(()))
    }

    private func handleFetchFailure(error: Error, completion: @escaping (Result<Void, Error>) -> Void) {
        print("❌ Failed to update prayer times: \(error.localizedDescription)")
        completion(.failure(error))
    }
}


