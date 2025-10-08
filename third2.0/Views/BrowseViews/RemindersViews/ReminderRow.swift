//
//  ReminderRow.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 08/10/2025.
//


import SwiftUI

struct ReminderRow: View {
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            // thumbnail chip
            Circle()
                .fill(tint)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle().stroke(Color.appBg.opacity(0.3), lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.stroke, lineWidth: 1)
                )
        )
    }
}
