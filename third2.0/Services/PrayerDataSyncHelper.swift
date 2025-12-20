//
//  PrayerDataSyncHelper.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import Foundation
import SwiftData
import FirebaseAuth

@MainActor
class PrayerDataSyncHelper {
    static let shared = PrayerDataSyncHelper()
    private let prayerSync = PrayerSyncService.shared
    private let syncKey = "hasSyncedAllPrayerData"
    private let lastSyncKey = "lastCloudSyncTimestamp"
    
    private init() {}
    
    /// Full bidirectional sync: Load from Firestore and merge with local, then sync local to cloud
    /// Call this when user logs in (especially on a new device) to sync data both ways
    func performFullSync(modelContext: ModelContext) async {
        // Check if user is authenticated
        guard Auth.auth().currentUser != nil else {
            print("⚠️ User not authenticated, skipping prayer data sync")
            return
        }
        
        print("🔄 Starting full bidirectional sync...")
        
        // Step 1: Load prayer data from Firestore and merge into local storage
        await loadAndMergeFromFirestore(modelContext: modelContext)
        
        // Step 2: Sync any local-only data back to Firestore
        await syncLocalDataToFirestore(modelContext: modelContext)
        
        // Mark as synced
        UserDefaults.standard.set(true, forKey: syncKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastSyncKey)
        
        print("✅ Full sync completed")
    }
    
    /// Load prayer data from Firestore and merge into local SwiftData
    /// Optimized to only load recent data (last 365 days) to reduce read costs
    private func loadAndMergeFromFirestore(modelContext: ModelContext) async {
        do {
            // Only load last 365 days to reduce read costs
            // Users rarely need older data immediately, and we can load on demand if needed
            let cloudPrayerDays = try await prayerSync.loadAllPrayerDays(limitDays: 365)
            
            guard !cloudPrayerDays.isEmpty else {
                print("ℹ️ No prayer data found in Firestore")
                return
            }
            
            print("📥 Loading \(cloudPrayerDays.count) prayer days from Firestore (last 365 days)...")
            
            // Fetch existing local PrayerDays
            let descriptor = FetchDescriptor<PrayerDay>(sortBy: [SortDescriptor(\.date)])
            let localPrayerDays = (try? modelContext.fetch(descriptor)) ?? []
            let localMap = Dictionary(uniqueKeysWithValues: localPrayerDays.map { ($0.dayKey, $0) })
            
            var updatedCount = 0
            var insertedCount = 0
            
            for cloudDay in cloudPrayerDays {
                if let existingLocal = localMap[cloudDay.dayKey] {
                    // Merge: LOCAL data is source of truth, only add missing prayers from cloud
                    // This ensures local changes are never overwritten by cloud data
                    var mergedCompleted = existingLocal.completed
                    // Only add prayers from cloud that don't exist locally
                    for (prayer, completed) in cloudDay.completed {
                        if mergedCompleted[prayer] == nil {
                            mergedCompleted[prayer] = completed
                        }
                    }
                    existingLocal.completed = mergedCompleted
                    // Don't overwrite date or freeze status - keep local values
                    updatedCount += 1
                } else {
                    // New day from cloud - insert it (only if it doesn't exist locally)
                    modelContext.insert(cloudDay)
                    insertedCount += 1
                }
            }
            
            // Save changes
            try? modelContext.save()
            
            print("✅ Merged Firestore data: \(insertedCount) new days, \(updatedCount) updated days")
        } catch {
            print("❌ Failed to load prayer data from Firestore: \(error.localizedDescription)")
        }
    }
    
    /// Sync all local prayer data to Firestore
    private func syncLocalDataToFirestore(modelContext: ModelContext) async {
        // Fetch all PrayerDays from SwiftData
        let descriptor = FetchDescriptor<PrayerDay>(sortBy: [SortDescriptor(\.date)])
        
        guard let allPrayerDays = try? modelContext.fetch(descriptor) else {
            print("❌ Failed to fetch PrayerDays from SwiftData")
            return
        }
        
        guard !allPrayerDays.isEmpty else {
            print("ℹ️ No local prayer data to sync")
            return
        }
        
        print("📤 Syncing \(allPrayerDays.count) local prayer days to Firestore...")
        
        do {
            try await prayerSync.syncAllLocalPrayerDays(allPrayerDays)
            print("✅ Successfully synced all local prayer data to Firestore")
        } catch {
            print("❌ Failed to sync all prayer data: \(error.localizedDescription)")
        }
    }
    
    /// Sync all existing local prayer data to Firestore (one-time sync)
    /// Call this when user logs in to ensure all local data is backed up
    func syncAllLocalDataIfNeeded(modelContext: ModelContext) async {
        // Check if user is authenticated
        guard Auth.auth().currentUser != nil else {
            print("⚠️ User not authenticated, skipping prayer data sync")
            return
        }
        
        // Check if we've already done a full sync
        if UserDefaults.standard.bool(forKey: syncKey) {
            print("ℹ️ Prayer data already synced, only syncing local data to Firestore (not loading from cloud)")
            // Don't load from Firestore on subsequent syncs - only push local data to cloud
            // This ensures local SwiftData is always the source of truth
            await syncLocalDataToFirestore(modelContext: modelContext)
            return
        }
        
        // First time sync - do full bidirectional sync (only on first login/new device)
        await performFullSync(modelContext: modelContext)
    }
    
    /// Reset sync flag (useful for testing or re-syncing)
    func resetSyncFlag() {
        UserDefaults.standard.removeObject(forKey: syncKey)
        UserDefaults.standard.removeObject(forKey: lastSyncKey)
    }
}

