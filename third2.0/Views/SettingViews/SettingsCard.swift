//
//  SettingsCard.swift
//  Night Prayers
//
//  Created for clean card style in Settings
//

import SwiftUI

struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(16)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }
}






