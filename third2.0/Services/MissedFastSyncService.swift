//
//  MissedFastSyncService.swift
//  Night Prayers
//
//  Service to sync missed fasts to Firebase Firestore
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class MissedFastSyncService {
    static let shared = MissedFastSyncService()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let missedFastsCollection = "missed_fasts"
    
    private init() {
        // Firestore is already configured in FirebaseHelper with offline persistence
        // Writes are automatically cached and synced when connection is restored
    }
    
    /// Check if a missed fast already exists for a given dayKey
    /// - Parameter dayKey: The day key to check (e.g., "2025-12-19")
    /// - Returns: True if a missed fast exists for this dayKey
    func missedFastExists(dayKey: String) async throws -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            return false
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let missedFastRef = userRef.collection(missedFastsCollection).document(dayKey)
        
        do {
            let document = try await missedFastRef.getDocument()
            return document.exists
        } catch {
            print("❌ Failed to check if missed fast exists: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sync a MissedFast to Firestore
    /// - Parameter missedFast: The MissedFast to sync
    func syncMissedFast(_ missedFast: MissedFast) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No authenticated user, skipping Firestore sync for missed fast")
            return
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        // Use dayKey as the document ID instead of UUID
        let missedFastRef = userRef.collection(missedFastsCollection).document(missedFast.dayKey)
        
        // Convert dates to Firestore Timestamps
        let dateTimestamp = Timestamp(date: missedFast.date)
        let createdAtTimestamp = Timestamp(date: missedFast.createdAt)
        
        let data: [String: Any] = [
            "dayKey": missedFast.dayKey,
            "date": dateTimestamp,
            "createdAt": createdAtTimestamp,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        do {
            // Use merge: true to update existing document or create new one
            try await missedFastRef.setData(data, merge: true)
            print("✅ Synced missed fast for day \(missedFast.dayKey) to Firestore")
        } catch {
            print("❌ Failed to sync missed fast to Firestore: \(error.localizedDescription)")
            // Note: Firestore will automatically retry when connection is restored
            // due to offline persistence being enabled
            throw error
        }
    }
    
    /// Sync multiple MissedFasts to Firestore
    /// - Parameter missedFasts: Array of MissedFasts to sync
    func syncMissedFasts(_ missedFasts: [MissedFast]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No authenticated user, skipping Firestore sync")
            return
        }
        
        let batch = db.batch()
        let userRef = db.collection(usersCollection).document(userId)
        
        for missedFast in missedFasts {
            // Use dayKey as the document ID instead of UUID
            let missedFastRef = userRef.collection(missedFastsCollection).document(missedFast.dayKey)
            
            let dateTimestamp = Timestamp(date: missedFast.date)
            let createdAtTimestamp = Timestamp(date: missedFast.createdAt)
            
            let data: [String: Any] = [
                "dayKey": missedFast.dayKey,
                "date": dateTimestamp,
                "createdAt": createdAtTimestamp,
                "lastUpdated": Timestamp(date: Date())
            ]
            
            batch.setData(data, forDocument: missedFastRef, merge: true)
        }
        
        do {
            try await batch.commit()
            print("✅ Synced \(missedFasts.count) missed fasts to Firestore")
        } catch {
            print("❌ Failed to batch sync missed fasts to Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Load all missed fasts from Firestore
    /// - Returns: Array of MissedFast data dictionaries
    func loadAllMissedFasts() async throws -> [[String: Any]] {
        guard let userId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let missedFastsRef = userRef.collection(missedFastsCollection)
        
        do {
            let snapshot = try await missedFastsRef.getDocuments()
            var missedFasts: [[String: Any]] = []
            
            for document in snapshot.documents {
                guard let data = document.data() as? [String: Any] else { continue }
                missedFasts.append(data)
            }
            
            print("✅ Loaded \(missedFasts.count) missed fasts from Firestore")
            return missedFasts
        } catch {
            print("❌ Failed to load missed fasts from Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Delete a missed fast from Firestore
    /// - Parameter missedFast: The MissedFast to delete
    func deleteMissedFast(_ missedFast: MissedFast) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No authenticated user, skipping Firestore delete")
            return
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        // Use dayKey as the document ID
        let missedFastRef = userRef.collection(missedFastsCollection).document(missedFast.dayKey)
        
        do {
            try await missedFastRef.delete()
            print("✅ Deleted missed fast for day \(missedFast.dayKey) from Firestore")
        } catch {
            print("❌ Failed to delete missed fast from Firestore: \(error.localizedDescription)")
            throw error
        }
    }
}

