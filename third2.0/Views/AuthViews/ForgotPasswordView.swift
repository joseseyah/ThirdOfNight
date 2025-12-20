//
//  ForgotPasswordView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Binding var showForgotPassword: Bool
    @StateObject private var authManager = AuthenticationManager.shared
    
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header - Moon Icon Only
                Image("moon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.accentPurple)
                    .shadow(color: .accentPurple.opacity(0.35), radius: 12, x: 0, y: 0)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                
                VStack(spacing: 24) {
                    // Title
                    Text("Forgot password")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimaryLight)
                        .frame(maxWidth: .infinity)
                    
                    // Instructional text
                    Text("If you have forgotten your password please enter your email below and we'll send you a verification code.")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondaryLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email address")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondaryLight)
                        
                        TextField("", text: $email, prompt: Text("Email address").foregroundColor(.textSecondary.opacity(0.6)))
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.textPrimary)
                            .padding()
                            .background(Color.cardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    }
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Success Message
                    if showSuccess {
                        Text("Password reset email sent! Check your inbox.")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Submit Button - Purple style like Support us button
                    Button(action: {
                        Task {
                            do {
                                try await authManager.resetPassword(email: email)
                                showSuccess = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showForgotPassword = false
                                }
                            } catch {
                                // Error is handled by authManager
                            }
                        }
                    }) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .buttonText))
                            } else {
                                Text("Submit")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.accentPurple)
                        .cornerRadius(28)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.stroke, lineWidth: 1)
                        )
                    }
                    .disabled(authManager.isLoading || email.isEmpty)
                    .opacity((authManager.isLoading || email.isEmpty) ? 0.6 : 1.0)
                    
                    // Back to log in link
                    Button(action: {
                        withAnimation(.none) {
                            showForgotPassword = false
                        }
                    }) {
                        Text("Back to log in")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.accentPurple)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    ForgotPasswordView(showForgotPassword: .constant(true))
}

