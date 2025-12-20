//
//  MissedFast.swift
//  Night Prayers
//
//  SwiftData model for missed fasts
//

import Foundation
import SwiftData

@Model
final class MissedFast {
    /// Unique identifier for the missed fast (dayKey format: "2025-01-15")
    /// Only one missed fast can exist per day
    /// This is also used as the Firebase document ID
    @Attribute(.unique) var dayKey: String
    
    /// Date when the fast was missed
    var date: Date
    
    /// Date when this record was created
    var createdAt: Date
    
    /// Whether this has been synced to Firebase
    var isSynced: Bool
    
    init(date: Date) {
        let day = Calendar.autoupdatingCurrent.startOfDay(for: date)
        self.date = day
        
        // Generate dayKey (unique per day) - this will be the Firebase document ID
        let c = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: day)
        let y = c.year ?? 0, m = c.month ?? 0, d = c.day ?? 0
        self.dayKey = String(format: "%04d-%02d-%02d", y, m, d)
        
        self.createdAt = Date()
        self.isSynced = false
    }
}

