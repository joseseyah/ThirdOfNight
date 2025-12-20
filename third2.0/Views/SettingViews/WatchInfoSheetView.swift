//
//  WatchInfoSheetView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 18/10/2025.
//

import SwiftUI

public struct WatchInfoSheetView: View {
    @State private var currentPage: Int = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(Color.stroke)
                .frame(width: 44, height: 5)
                .padding(.top, 8)
            
            // TabView for swipeable pages
            TabView(selection: $currentPage) {
                // Page 1: Introducing watch tracking
                WatchIntroPage()
                    .tag(0)
                
                // Page 2: How Apple Watch tracks prayer times
                WatchTrackingPage()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.cardBg.ignoresSafeArea())
        .presentationDetents([.fraction(0.65), .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Page 1: Introducing Watch Tracking
struct WatchIntroPage: View {
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(String(localized: "Watch Tracking"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 20)
            
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                Circle()
                    .stroke(Color.stroke, lineWidth: 1.2)
                Circle()
                    .stroke(Color.accentPurple.opacity(0.55), lineWidth: 3)
                    .blur(radius: 0.5)
                    .padding(8)
                
                Image(systemName: "applewatch")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentPurple)
                    .shadow(color: Color.accentPurple.opacity(0.28), radius: 10)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 6)
            
            // Body copy
            Text(String(localized: "Track your prayers seamlessly with Apple Watch integration. Keep your prayer times and reminders right on your wrist."))
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 22)
                .padding(.top, 6)
            
            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
    }
}

// MARK: - Page 2: How Apple Watch Tracks Prayer Times
struct WatchTrackingPage: View {
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(String(localized: "Automatic Tracking"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 20)
            
            // Icon circle
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                Circle()
                    .stroke(Color.stroke, lineWidth: 1.2)
                Circle()
                    .stroke(Color.accentPurple.opacity(0.55), lineWidth: 3)
                    .blur(radius: 0.5)
                    .padding(8)
                
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.accentPurple)
                    .shadow(color: Color.accentPurple.opacity(0.28), radius: 10)
            }
            .frame(width: 120, height: 120)
            .padding(.top, 6)
            
            // Body copy
            VStack(spacing: 12) {
                Text(String(localized: "If you have an Apple Watch, your prayer times can be tracked automatically."))
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "The watch will detect your prayer movements and log them directly to your prayer tracker, keeping your streaks up to date without any manual input."))
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 22)
            .padding(.top, 6)
            
            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 8)
    }
}

