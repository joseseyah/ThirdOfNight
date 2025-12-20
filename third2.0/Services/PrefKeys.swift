//
//  PrefKeys.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 16/10/2025.
//

import Foundation
import Adhan

enum PrefKeys {
    static let freezeOn = "freeze.isOn"
    static let asrMadhab = "asr.madhab" // "hanafi" or "shafi"
}

extension PrefKeys {
    /// Gets the saved Asr madhab preference, defaulting to Shafi (earlier Asr)
    static func getAsrMadhab() -> Madhab {
        // Try App Group first (for widget access), then fallback to standard UserDefaults
        let appGroupID = "group.testing.thirdgit"
        let appGroupDefaults = UserDefaults(suiteName: appGroupID)
        let defaults = appGroupDefaults ?? UserDefaults.standard
        
        if let saved = defaults.string(forKey: asrMadhab),
           saved == "hanafi" {
            return .hanafi
        }
        return .shafi // Default to earlier Asr
    }
    
    /// Saves the Asr madhab preference to both standard and App Group UserDefaults
    static func setAsrMadhab(_ madhab: Madhab) {
        let value = madhab == .hanafi ? "hanafi" : "shafi"
        
        // Save to standard UserDefaults
        UserDefaults.standard.set(value, forKey: asrMadhab)
        
        // Also save to App Group UserDefaults for widget access
        let appGroupID = "group.testing.thirdgit"
        if let appGroupDefaults = UserDefaults(suiteName: appGroupID) {
            appGroupDefaults.set(value, forKey: asrMadhab)
            appGroupDefaults.synchronize()
        }
    }
}
