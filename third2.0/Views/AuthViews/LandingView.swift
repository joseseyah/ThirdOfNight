//
//  LandingView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI

struct LandingView: View {
    @State private var showAuth = false
    @State private var showOnboarding = false
    @State private var authMode: AuthMode = .login
    
    var body: some View {
        ZStack {
            if showAuth {
                AuthContainerView(showAuth: $showAuth, initialMode: authMode)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else if showOnboarding {
                OnboardingFlowView(showAuth: $showAuth, showOnboarding: $showOnboarding, authMode: $authMode)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else {
                ZStack {
                    Color.appBg.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // App Logo Only
                        Image("moon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(color: .accentMoon.opacity(0.25), radius: 18, x: 0, y: 0)
                            .padding(.top, 120)
                            .padding(.bottom, 48)
                        
                        Spacer()
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showOnboarding = true
                                }
                            }) {
                                Text("Get started")
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
                            
                            Button(action: {
                                authMode = .login
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showAuth = true
                                }
                            }) {
                                Text("Log in")
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
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
    }
}

#Preview {
    LandingView()
}

