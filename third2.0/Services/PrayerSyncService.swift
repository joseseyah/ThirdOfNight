//
//  PrayerSyncService.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PrayerSyncService {
    static let shared = PrayerSyncService()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let prayersCollection = "prayers"
    
    private init() {
        // Firestore is already configured in FirebaseHelper with offline persistence
        // Writes are automatically cached and synced when connection is restored
    }
    
    /// Sync a PrayerDay to Firestore
    /// - Parameter prayerDay: The PrayerDay to sync
    func syncPrayerDay(_ prayerDay: PrayerDay) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No authenticated user, skipping Firestore sync")
            return
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let prayerRef = userRef.collection(prayersCollection).document(prayerDay.dayKey)
        
        // Convert date to Firestore Timestamp
        let dateTimestamp = Timestamp(date: prayerDay.date)
        
        // Prepare data matching local structure
        // IMPORTANT: This syncs the ENTIRE day's prayer completion status
        // So if Fajr was ticked earlier and now Dhuhr is ticked,
        // this will sync with BOTH Fajr and Dhuhr marked as completed
        let data: [String: Any] = [
            "dayKey": prayerDay.dayKey,
            "date": dateTimestamp,
            "completed": prayerDay.completed, // Full dictionary with all prayers for the day
            "isFrozen": prayerDay.isFrozen, // Freeze mode status (excludes from statistics)
            "lastUpdated": Timestamp(date: Date())
        ]
        
        do {
            // Use merge: true to update existing document or create new one
            // This ensures all prayers for the day are always in sync
            try await prayerRef.setData(data, merge: true)
            print("✅ Synced prayer day \(prayerDay.dayKey) to Firestore - completed: \(prayerDay.completed)")
        } catch {
            print("❌ Failed to sync prayer day to Firestore: \(error.localizedDescription)")
            // Note: Firestore will automatically retry when connection is restored
            // due to offline persistence being enabled
            throw error
        }
    }
    
    /// Sync multiple PrayerDays to Firestore
    /// - Parameter prayerDays: Array of PrayerDays to sync
    func syncPrayerDays(_ prayerDays: [PrayerDay]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No authenticated user, skipping Firestore sync")
            return
        }
        
        let batch = db.batch()
        let userRef = db.collection(usersCollection).document(userId)
        
        for prayerDay in prayerDays {
            let prayerRef = userRef.collection(prayersCollection).document(prayerDay.dayKey)
            
            let dateTimestamp = Timestamp(date: prayerDay.date)
            
            let data: [String: Any] = [
                "dayKey": prayerDay.dayKey,
                "date": dateTimestamp,
                "completed": prayerDay.completed,
                "isFrozen": prayerDay.isFrozen, // Freeze mode status (excludes from statistics)
                "lastUpdated": Timestamp(date: Date())
            ]
            
            batch.setData(data, forDocument: prayerRef, merge: true)
        }
        
        do {
            try await batch.commit()
            print("✅ Synced \(prayerDays.count) prayer days to Firestore")
        } catch {
            print("❌ Failed to batch sync prayer days to Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Load prayer data from Firestore for a specific day
    /// - Parameter dayKey: The day key (e.g., "2025-10-12")
    /// - Returns: PrayerDay if found, nil otherwise
    func loadPrayerDay(dayKey: String) async throws -> PrayerDay? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let prayerRef = userRef.collection(prayersCollection).document(dayKey)
        
        do {
            let document = try await prayerRef.getDocument()
            
            guard document.exists,
                  let data = document.data(),
                  let dayKey = data["dayKey"] as? String,
                  let timestamp = data["date"] as? Timestamp,
                  let completed = data["completed"] as? [String: Bool] else {
                return nil
            }
            
            let date = timestamp.dateValue()
            let isFrozen = data["isFrozen"] as? Bool ?? false
            return PrayerDay(date: date, completed: completed, isFrozen: isFrozen)
        } catch {
            print("❌ Failed to load prayer day from Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Load all prayer days from Firestore
    /// - Parameter limitDays: Optional limit to only load recent days (e.g., 365 for last year). Nil = load all.
    /// - Returns: Array of PrayerDays
    func loadAllPrayerDays(limitDays: Int? = 365) async throws -> [PrayerDay] {
        guard let userId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let prayersRef = userRef.collection(prayersCollection)
        
        do {
            var query: Query = prayersRef
            
            // Limit to recent days to reduce read costs
            // Most users only need recent data, and we can load older data on demand
            if let limit = limitDays {
                // Calculate cutoff date
                let cutoffDate = Calendar.current.date(byAdding: .day, value: -limit, to: Date()) ?? Date()
                let cutoffTimestamp = Timestamp(date: cutoffDate)
                query = query
                    .whereField("date", isGreaterThanOrEqualTo: cutoffTimestamp)
                    .order(by: "date", descending: true)
                    .limit(to: limit) // Additional safety limit
            } else {
                query = query.order(by: "date", descending: true)
            }
            
            let snapshot = try await query.getDocuments()
            
            var prayerDays: [PrayerDay] = []
            
            for document in snapshot.documents {
                let data = document.data()

                guard
                    let dayKey = data["dayKey"] as? String,
                    let timestamp = data["date"] as? Timestamp,
                    let completed = data["completed"] as? [String: Bool]
                else {
                    continue
                }
                
                let date = timestamp.dateValue()
                let isFrozen = data["isFrozen"] as? Bool ?? false
                let prayerDay = PrayerDay(date: date, completed: completed, isFrozen: isFrozen)
                prayerDays.append(prayerDay)
            }
            
            print("✅ Loaded \(prayerDays.count) prayer days from Firestore (limit: \(limitDays?.description ?? "none"))")
            return prayerDays
        } catch {
            print("❌ Failed to load prayer days from Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Load prayer days for a specific date range (more efficient for targeted queries)
    /// - Parameters:
    ///   - startDate: Start of date range
    ///   - endDate: End of date range
    /// - Returns: Array of PrayerDays in the range
    func loadPrayerDaysInRange(startDate: Date, endDate: Date) async throws -> [PrayerDay] {
        guard let userId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let userRef = db.collection(usersCollection).document(userId)
        let prayersRef = userRef.collection(prayersCollection)
        
        let startTimestamp = Timestamp(date: startDate)
        let endTimestamp = Timestamp(date: endDate)
        
        do {
            let query = prayersRef
                .whereField("date", isGreaterThanOrEqualTo: startTimestamp)
                .whereField("date", isLessThanOrEqualTo: endTimestamp)
                .order(by: "date", descending: false)
            
            let snapshot = try await query.getDocuments()
            
            var prayerDays: [PrayerDay] = []
            
            for document in snapshot.documents {
                let data = document.data()

                guard
                    let dayKey = data["dayKey"] as? String,
                    let timestamp = data["date"] as? Timestamp,
                    let completed = data["completed"] as? [String: Bool]
                else {
                    continue
                }
                
                let date = timestamp.dateValue()
                let isFrozen = data["isFrozen"] as? Bool ?? false
                let prayerDay = PrayerDay(date: date, completed: completed, isFrozen: isFrozen)
                prayerDays.append(prayerDay)
            }
            
            print("✅ Loaded \(prayerDays.count) prayer days from Firestore for date range")
            return prayerDays
        } catch {
            print("❌ Failed to load prayer days from Firestore: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Sync all local PrayerDays to Firestore (useful for initial sync or backup)
    /// - Parameter prayerDays: Array of PrayerDays from local storage
    func syncAllLocalPrayerDays(_ prayerDays: [PrayerDay]) async throws {
        guard !prayerDays.isEmpty else { return }
        
        print("🔄 Syncing \(prayerDays.count) local prayer days to Firestore...")
        try await syncPrayerDays(prayerDays)
    }
}

