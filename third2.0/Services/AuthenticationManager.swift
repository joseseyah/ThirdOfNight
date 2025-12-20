//
//  AuthenticationManager.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 15/12/2025.
//

import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import FirebaseCore

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var memberSinceDate: Date?
    
    private let memberSinceKey = "memberSinceDate"
    
    private init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
                if let user = user {
                    await self?.loadMemberSinceDate(user: user)
                } else {
                    self?.memberSinceDate = nil
                }
            }
        }
        
        // Check initial auth state
        self.user = Auth.auth().currentUser
        self.isAuthenticated = user != nil
        if let user = self.user {
            Task {
                await loadMemberSinceDate(user: user)
            }
        }
    }
    
    private func loadMemberSinceDate(user: User) async {
        // First check local storage
        if let storedTimestamp = UserDefaults.standard.object(forKey: memberSinceKey) as? TimeInterval {
            memberSinceDate = Date(timeIntervalSince1970: storedTimestamp)
        }
        
        // Then fetch from Firebase Auth metadata
        // Firebase Auth User metadata contains creationDate
        let creationDate = user.metadata.creationDate ?? Date()
        memberSinceDate = creationDate
        
        // Store locally
        UserDefaults.standard.set(creationDate.timeIntervalSince1970, forKey: memberSinceKey)
    }
    
    // MARK: - Email/Password Authentication
    
    func signUp(email: String, password: String, fullName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update user profile with display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func deleteAccount() async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let user = Auth.auth().currentUser else {
            throw AuthError.invalidAppleCredential
        }
        
        do {
            try await user.delete()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthError.invalidAppleCredential
        }
        
        // Re-authenticate user with current password
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        do {
            try await user.reauthenticate(with: credential)
            
            // Update password
            try await user.updatePassword(to: newPassword)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle() async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.noIDToken
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(authorization: ASAuthorization) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidAppleCredential
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                 idToken: idTokenString,
                                                 rawNonce: nonce)
        
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Apple Sign In Nonce
    
    private var currentNonce: String?
    
    func startSignInWithApple() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
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

import CryptoKit

enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case noIDToken
    case invalidAppleCredential
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Firebase client ID"
        case .noRootViewController:
            return "Unable to find root view controller"
        case .noIDToken:
            return "Unable to get ID token"
        case .invalidAppleCredential:
            return "Invalid Apple credential"
        }
    }
}

