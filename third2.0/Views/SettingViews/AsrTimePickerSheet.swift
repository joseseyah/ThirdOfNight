//
//  AsrTimePickerSheet.swift
//  Night Prayers
//
//  Created for Asr time selection in settings
//

import SwiftUI
import Adhan
import CoreLocation

struct AsrTimeOption: Identifiable {
    let id: String
    let madhab: Madhab
    let title: String
    let description: String
}

struct AsrTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentMadhab: Madhab = PrefKeys.getAsrMadhab()
    
    private var currentCoordinate: CLLocationCoordinate2D? {
        SettingsStore.shared.lastKnownCoordinate
    }
    
    static let options: [AsrTimeOption] = [
        .init(
            id: "shafi",
            madhab: .shafi,
            title: "Earlier Asr (Shafi)",
            description: "Standard calculation method"
        ),
        .init(
            id: "hanafi",
            madhab: .hanafi,
            title: "Later Asr (Hanafi)",
            description: "Hanafi school calculation method"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack(spacing: 14) {
                Capsule()
                    .fill(Color.stroke)
                    .frame(width: 44, height: 5)
                    .padding(.top, 6)
                
                Text("Choose Asr Time")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 6)
                
                VStack(spacing: 10) {
                    ForEach(Self.options) { option in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.title)
                                        .foregroundStyle(Color.textPrimary)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    
                                    Text(option.description)
                                        .foregroundStyle(Color.textSecondary)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                }
                                Spacer()
                                Radio(isSelected: currentMadhab == option.madhab)
                            }
                        }
                        .padding(14)
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                        .onTapGesture {
                            selectOption(option)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 8)
            }
        }
        .onAppear {
            currentMadhab = PrefKeys.getAsrMadhab()
        }
    }
    
    private func selectOption(_ option: AsrTimeOption) {
        guard currentMadhab != option.madhab else {
            dismiss()
            return
        }
        
        PrefKeys.setAsrMadhab(option.madhab)
        currentMadhab = option.madhab
        
        // Clear the prayer times cache so times are recalculated
        PrayerTimesCache().clear()
        
        // Post notification to trigger prayer times reload
        NotificationCenter.default.post(name: NSNotification.Name("AsrMadhabChanged"), object: nil)
        
        // Refresh notifications if they're enabled
        if UserDefaults.standard.bool(forKey: "notif_prayer_enabled") {
            Task {
                NotificationManager.shared.setPrayerAlertsEnabled(
                    false,
                    coordinates: currentCoordinate,
                    method: .muslimWorldLeague,
                    madhab: option.madhab
                )
                NotificationManager.shared.setPrayerAlertsEnabled(
                    true,
                    coordinates: currentCoordinate,
                    method: .muslimWorldLeague,
                    madhab: option.madhab
                )
            }
        }
        
        dismiss()
    }
}

#Preview {
    AsrTimePickerSheet()
        .preferredColorScheme(.dark)
}






