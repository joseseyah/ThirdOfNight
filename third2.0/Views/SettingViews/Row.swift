//
//  Row.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//
import SwiftUI

struct Row<Trailing: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentPurple.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.accentPurple)
            }

            Text(title)
                .foregroundStyle(Color.textPrimary)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer(minLength: 12)

            trailing
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
