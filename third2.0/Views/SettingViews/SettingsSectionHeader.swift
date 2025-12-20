//
//  SettingsSectionHeader.swift
//  Night Prayers
//
//  Created for section headers in Settings
//

import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(.textSecondaryLight)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.top, 4)
    }
}



