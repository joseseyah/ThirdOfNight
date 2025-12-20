//
//  PrayerSettingsRow.swift
//  Night Prayers
//
//  Created for Asr madhab selection in settings
//

import SwiftUI
import Adhan
import Combine

struct PrayerSettingsRow: View {
    @State private var currentMadhab: Madhab = PrefKeys.getAsrMadhab()
    @Binding var showAsrTimeSheet: Bool
    
    private var displayText: String {
        currentMadhab == .hanafi ? "Later Asr (Hanafi)" : "Earlier Asr (Shafi)"
    }
    
    var body: some View {
        Row(icon: "clock", title: "Asr Time", trailing: {
            Text(displayText)
                .foregroundStyle(Color.textSecondary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
        })
        .onTapGesture {
            showAsrTimeSheet = true
        }
        .onAppear {
            // Sync with saved value on appear
            currentMadhab = PrefKeys.getAsrMadhab()
        }
        .onChange(of: showAsrTimeSheet) { _, newValue in
            if !newValue {
                // Update when sheet is dismissed
                currentMadhab = PrefKeys.getAsrMadhab()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AsrMadhabChanged"))) { _ in
            // Update when preference changes
            currentMadhab = PrefKeys.getAsrMadhab()
        }
    }
}

