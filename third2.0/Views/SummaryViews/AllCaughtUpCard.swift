//
//  AllCaughtUpCard.swift
//  Night Prayers
//
//  Card component showing "You're all caught up!" message
//

import SwiftUI

struct AllCaughtUpCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("FASTING TALLY")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.textSecondaryLight)
                .tracking(1.2)
            
            Text("You're all caught up!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.accentGold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentPurple.opacity(0.15),
                            Color.accentPurple.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.appBg.ignoresSafeArea()
        
        AllCaughtUpCard()
            .padding()
    }
}

