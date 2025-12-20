//
//  SignupContentView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct SignupContentView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Binding var authMode: AuthMode
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var receiveEmails = false
    
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
                
                // Signup Form
                VStack(spacing: 24) {
                    Text("Sign up")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.textPrimaryLight)
                        .frame(maxWidth: .infinity)
                    
                    // Log in link
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button(action: {
                            withAnimation(.none) {
                                authMode = .login
                            }
                        }) {
                            Text("Log in")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.accentPurple)
                                .underline()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Full Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full name")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.textSecondaryLight)
                        
                        TextField("", text: $fullName, prompt: Text("Full name").foregroundColor(.textSecondary.opacity(0.6)))
                            .textContentType(.name)
                            .foregroundColor(.textPrimary)
                            .padding()
                            .background(Color.cardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                    }
                    
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
                                    .textContentType(.newPassword)
                                    .foregroundColor(.textPrimary)
                            } else {
                                SecureField("", text: $password, prompt: Text("Password").foregroundColor(.textSecondary.opacity(0.6)))
                                    .textContentType(.newPassword)
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
                        
                        Text("Min 8 characters in length")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondaryLight)
                            .padding(.top, 4)
                    }
                    
                    // Email Updates Checkbox
                    HStack(spacing: 12) {
                        Button(action: {
                            receiveEmails.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(receiveEmails ? Color.accentPurple : Color.clear)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(receiveEmails ? Color.accentPurple : Color.stroke, lineWidth: 1.5)
                                    )
                                
                                if receiveEmails {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.buttonText)
                                }
                            }
                        }
                        
                        Text("I'd like to receive emails and updates")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondaryLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Signup Button - Purple style like Support us button
                    Button(action: {
                        Task {
                            do {
                                try await authManager.signUp(email: email, password: password, fullName: fullName)
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
                                Text("Continue")
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
                    .disabled(authManager.isLoading || fullName.isEmpty || email.isEmpty || password.count < 8)
                    .opacity((authManager.isLoading || fullName.isEmpty || email.isEmpty || password.count < 8) ? 0.6 : 1.0)
                    
                    // Terms and Privacy
                    HStack(spacing: 4) {
                        Text("By signing up, you agree to")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button(action: {
                            // Open terms
                        }) {
                            Text("terms and conditions")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.accentPurple)
                                .underline()
                        }
                        
                        Text("and")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondaryLight)
                        
                        Button(action: {
                            // Open privacy policy
                        }) {
                            Text("privacy policy")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.accentPurple)
                                .underline()
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    
                    // Social Signup
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

