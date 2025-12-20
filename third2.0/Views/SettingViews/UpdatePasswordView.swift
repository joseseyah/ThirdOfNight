//
//  UpdatePasswordView.swift
//  Night Prayers
//
//  Created for password update functionality
//

import SwiftUI

struct UpdatePasswordView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrentPassword = false
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSuccess = false
    
    private let sidePadding: CGFloat = 24
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header - Moon Icon
                    Image("moon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.accentMoon)
                        .shadow(color: .accentMoon.opacity(0.25), radius: 12, x: 0, y: 0)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    
                    // Title
                    Text("Update Password")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, 32)
                    
                    VStack(spacing: 20) {
                        // Current Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Password")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                if showCurrentPassword {
                                    TextField("", text: $currentPassword)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("", text: $currentPassword)
                                        .textContentType(.password)
                                }
                                
                                Button(action: {
                                    showCurrentPassword.toggle()
                                }) {
                                    Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding(16)
                            .background(Color.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                        }
                        
                        // New Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                if showNewPassword {
                                    TextField("", text: $newPassword)
                                        .textContentType(.newPassword)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("", text: $newPassword)
                                        .textContentType(.newPassword)
                                }
                                
                                Button(action: {
                                    showNewPassword.toggle()
                                }) {
                                    Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding(16)
                            .background(Color.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.textSecondary)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding(16)
                            .background(Color.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.stroke, lineWidth: 1)
                            )
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Success Message
                        if showSuccess {
                            Text("Password updated successfully!")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Update Button
                        Button(action: {
                            updatePassword()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Update Password")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentPurple)
                            .foregroundColor(.buttonText)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .disabled(isLoading || currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                        .opacity(isLoading || currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty ? 0.6 : 1.0)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, sidePadding)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .tint(.accentPurple)
    }
    
    private func updatePassword() {
        // Validation
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match"
            return
        }
        
        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    UpdatePasswordView()
        .preferredColorScheme(.dark)
}



