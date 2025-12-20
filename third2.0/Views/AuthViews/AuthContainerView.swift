//
//  AuthContainerView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import SwiftUI

enum AuthMode {
    case login
    case signup
    case forgotPassword
}

struct AuthContainerView: View {
    @Binding var showAuth: Bool
    @State private var authMode: AuthMode
    @State private var showForgotPassword = false
    
    init(showAuth: Binding<Bool>, initialMode: AuthMode = .login) {
        _showAuth = showAuth
        _authMode = State(initialValue: initialMode)
    }
    
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: {
                        if showForgotPassword {
                            withAnimation(.none) {
                                showForgotPassword = false
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAuth = false
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimaryLight)
                            .padding()
                    }
                    Spacer()
                }
                .padding(.top, 8)
                
                Group {
                    if showForgotPassword {
                        ForgotPasswordView(showForgotPassword: $showForgotPassword)
                    } else if authMode == .login {
                        LoginContentView(authMode: $authMode, showForgotPassword: $showForgotPassword)
                    } else {
                        SignupContentView(authMode: $authMode)
                    }
                }
            }
        }
    }
}

