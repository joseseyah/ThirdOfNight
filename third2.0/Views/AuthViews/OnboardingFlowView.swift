//
//  OnboardingFlowView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @Binding var showAuth: Bool
    @Binding var showOnboarding: Bool
    @Binding var authMode: AuthMode
    @State private var currentPage: Int = 0
    
    let totalPages = 8
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= currentPage ? Color.accentPurple : Color.cardBg)
                            .frame(width: 24, height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Back Button
                HStack {
                    Button(action: {
                        if currentPage > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        } else {
                            // Go back to landing
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showOnboarding = false
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .padding()
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                
                // Content
                OnboardingSlideView(
                    slide: onboardingSlides[currentPage],
                    isLastPage: currentPage == totalPages - 1,
                    onNext: {
                        if currentPage < totalPages - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } else {
                            // Navigate to signup
                            withAnimation(.easeInOut(duration: 0.3)) {
                                authMode = .signup
                                showOnboarding = false
                                showAuth = true
                            }
                        }
                    },
                    onSkip: {
                        // Navigate to login
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authMode = .login
                            showOnboarding = false
                            showAuth = true
                        }
                    }
                )
                .id(currentPage) // Force view refresh on page change
            }
        }
    }
}

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let features: [FeatureCard]?
}

struct FeatureCard {
    let icon: String
    let title: String
    let description: String
}

let onboardingSlides: [OnboardingSlide] = [
    OnboardingSlide(
        title: "Watch Prayer Tracking",
        subtitle: "Automatic detection",
        description: "Your Apple Watch detects prayer movements and automatically ticks off prayers for you",
        iconName: "applewatch",
        features: nil
    ),
    OnboardingSlide(
        title: "Qibla Direction",
        subtitle: "Always know where to face",
        description: "Find the direction of the Kaaba from anywhere in the world with our accurate compass",
        iconName: "location.north.line.fill",
        features: nil
    ),
    OnboardingSlide(
        title: "Prayer Analysis",
        subtitle: "Track your progress",
        description: "View detailed trends and insights about your prayer habits over time",
        iconName: "chart.line.uptrend.xyaxis",
        features: nil
    ),
    OnboardingSlide(
        title: "Travel Mode",
        subtitle: "Prayer times on the go",
        description: "Automatically adjust prayer times when you travel to different locations",
        iconName: "airplane",
        features: nil
    ),
    OnboardingSlide(
        title: "Freeze Trends",
        subtitle: "For those menstruating",
        description: "Pause your prayer tracking during your period without affecting your statistics",
        iconName: "moon.circle.fill",
        features: nil
    ),
    OnboardingSlide(
        title: "Prayer Notifications",
        subtitle: "Never miss a salah",
        description: "Get timely reminders so you never miss the next prayer time",
        iconName: "bell.badge.fill",
        features: nil
    ),
    OnboardingSlide(
        title: "Privacy First",
        subtitle: "Made by Muslims, for Muslims",
        description: "Built with privacy in mind, by a Muslim developer to help Muslims for free",
        iconName: "lock.shield.fill",
        features: nil
    ),
    OnboardingSlide(
        title: "Support Charity",
        subtitle: "Give back",
        description: "A portion of proceeds goes to charity to help those in need",
        iconName: "heart.circle.fill",
        features: nil
    )
]

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let isLastPage: Bool
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Icon
                        Image(systemName: slide.iconName)
                            .font(.system(size: 80))
                            .foregroundColor(.accentPurple)
                            .frame(height: 120)
                        
                        // Title
                        VStack(spacing: 8) {
                            Text(slide.title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            if !slide.subtitle.isEmpty {
                                Text(slide.subtitle)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Description
                        Text(slide.description)
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                        
                        // Features (if any)
                        if let features = slide.features {
                            VStack(spacing: 16) {
                                ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                                    FeatureCardView(feature: feature)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
                
                // Bottom Actions - Fixed at bottom
                VStack(spacing: 16) {
                    Button(action: onNext) {
                        Text(isLastPage ? "Create account" : "Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.cardBg)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    }
                    
                    Button(action: onSkip) {
                        Text("Got an account? Log in")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(Color.appBg)
            }
        }
    }
}

struct FeatureCardView: View {
    let feature: FeatureCard
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundColor(.accentPurple)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.stroke, lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingFlowView(showAuth: .constant(false), showOnboarding: .constant(true), authMode: .constant(.signup))
}

