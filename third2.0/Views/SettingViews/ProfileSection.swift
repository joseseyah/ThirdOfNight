//
//  ProfileSection.swift
//  Night Prayers
//
//  Created for profile display in settings
//

import SwiftUI

struct ProfileSection: View {
    let email: String
    let memberSinceDate: Date?
    
    private var avatarLetter: String {
        guard let firstChar = email.first else { return "?" }
        return String(firstChar).uppercased()
    }
    
    private var memberSinceText: String {
        guard let date = memberSinceDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "Member since \(formatter.string(from: date))"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentPurple.opacity(0.4), Color.accentPurple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text(avatarLetter)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.accentPurple)
            }
            
            // Email
            Text(email)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.textPrimaryLight)
            
            // Member since
            if !memberSinceText.isEmpty {
                Text(memberSinceText)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondaryLight)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

#Preview {
    ProfileSection(
        email: "joseph@example.com",
        memberSinceDate: Date()
    )
    .padding()
    .background(Color.appBg)
    .preferredColorScheme(.dark)
}

