//
//  LoginContentView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI
import CryptoKit
import AuthenticationServices

struct LoginContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Binding var authMode: AuthMode
    @Binding var showForgotPassword: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
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
                
                // Login Form
                VStack(spacing: 24) {
                    Text("Log in")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimaryLight)
                        .frame(maxWidth: .infinity)
                    
                    // Sign up link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button(action: {
                            withAnimation(.none) {
                                authMode = .signup
                            }
                        }) {
                            Text("Sign up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.accentPurple)
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
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
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondaryLight)
                        
                        HStack {
                            if showPassword {
                                TextField("", text: $password, prompt: Text("Password").foregroundColor(.textSecondary.opacity(0.6)))
                                    .textContentType(.password)
                                    .foregroundColor(.textPrimary)
                            } else {
                                SecureField("", text: $password, prompt: Text("Password").foregroundColor(.textSecondary.opacity(0.6)))
                                    .textContentType(.password)
                                    .foregroundColor(.textPrimary)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.textSecondary)
                            }
                        }
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
                    
                    // Login Button - Purple style like Support us button
                    Button(action: {
                        Task {
                            do {
                                try await authManager.signIn(email: email, password: password)
                                // Authentication success will be handled by RootView
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
                                Text("Log in")
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
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    .opacity((authManager.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    
                    // Forgot Password
                    Button(action: {
                        withAnimation(.none) {
                            showForgotPassword = true
                        }
                    }) {
                        Text("Forgot password")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.accentPurple)
                    }
                    .padding(.top, 8)
                    
                    // Social Login
                    VStack(spacing: 16) {
                        HStack {
                            Rectangle()
                                .fill(Color.stroke)
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondaryLight)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.stroke)
                                .frame(height: 1)
                        }
                        .padding(.top, 8)
                        
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                let nonce = authManager.startSignInWithApple()
                                request.requestedScopes = [.fullName, .email]
                                request.nonce = sha256(nonce)
                            },
                            onCompletion: { result in
                                Task {
                                    switch result {
                                    case .success(let authorization):
                                        do {
                                            try await authManager.signInWithApple(authorization: authorization)
                                            // Authentication success will be handled by RootView
                                        } catch {
                                            // Error is handled by authManager
                                        }
                                    case .failure(let error):
                                        authManager.errorMessage = error.localizedDescription
                                    }
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 56)
                        .cornerRadius(28)
                        
                        // Google Sign In
                        Button(action: {
                            Task {
                                do {
                                    try await authManager.signInWithGoogle()
                                    // Authentication success will be handled by RootView
                                } catch {
                                    // Error is handled by authManager
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 20))
                                
                                Text("Continue with Google")
                                    .font(.system(size: 17, weight: .semibold))
                            }
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
                        .disabled(authManager.isLoading)
                        .opacity(authManager.isLoading ? 0.6 : 1.0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

