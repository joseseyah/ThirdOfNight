//
//  PermissionBadge.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct PermissionBadge: View {
    let status: UNAuthorizationStatus

    var text: String {
        switch status {
        case .authorized, .provisional, .ephemeral: return "Enabled"
        case .denied: return "Disabled"
        case .notDetermined: return "Ask"
        @unknown default: return "Unknown"
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(status == .authorized ? Color.accentMoon.opacity(0.18)
                                                : Color.white.opacity(0.06))
            )
            .overlay(
                Capsule().stroke(Color.stroke, lineWidth: 1)
            )
            .foregroundStyle(status == .authorized ? Color.textPrimary : Color.textSecondary)
    }
}
