import SwiftUI
import UserNotifications
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showLanguageSheet = false
    @State private var showWatchSheet = false
    @State private var showDeleteAccountAlert = false
    @State private var showUpdatePassword = false
    @State private var showAsrTimeSheet = false

    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Settings Title
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimaryLight)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Profile Section (unboxed)
                    if authManager.isAuthenticated, let user = authManager.user {
                        ProfileSection(
                            email: user.email ?? "",
                            memberSinceDate: authManager.memberSinceDate
                        )
                        .padding(.horizontal, sidePadding)
                        .padding(.bottom, 16)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        // System Settings
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionHeader(title: "System Settings")
                            
                            SettingsCard {
                                VStack(spacing: 0) {
                                    LanguageRow()
                                        .onTapGesture { showLanguageSheet = true }
                                    
                                    Divider()
                                        .background(Color.stroke)
                                        .padding(.vertical, 8)
                                    
                                    WatchRows(onTap: { showWatchSheet = true })
                                    
                                    Divider()
                                        .background(Color.stroke)
                                        .padding(.vertical, 8)
                                    
                                    TravelModeRows()
                                }
                            }
                        }
                        
                        // Prayer Settings
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionHeader(title: "Prayer Settings")
                            
                            SettingsCard {
                                PrayerSettingsRow(showAsrTimeSheet: $showAsrTimeSheet)
                            }
                        }
                        
                        // Notifications
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionHeader(title: "Notifications")
                            
                            SettingsCard {
                                NotificationRows()
                            }
                        }
                        
                        // Legal
                        VStack(alignment: .leading, spacing: 12) {
                            SettingsSectionHeader(title: "Legal")
                            
                            SettingsCard {
                                LegalRows()
                            }
                        }
                        
                        // Account
                        if authManager.isAuthenticated {
                            VStack(alignment: .leading, spacing: 12) {
                                SettingsSectionHeader(title: "Account")
                                
                                SettingsCard {
                                    VStack(spacing: 0) {
                                        Row(icon: "key", title: "Update Password") {
                                            EmptyView()
                                        }
                                        .onTapGesture {
                                            showUpdatePassword = true
                                        }
                                        
                                        Divider()
                                            .background(Color.stroke)
                                            .padding(.vertical, 8)
                                        
                                        Row(icon: "arrow.right.square", title: "Log out") {
                                            EmptyView()
                                        }
                                        .onTapGesture {
                                            do {
                                                try authManager.signOut()
                                            } catch {
                                                // Error handled by authManager
                                            }
                                        }
                                        
                                        Divider()
                                            .background(Color.stroke)
                                            .padding(.vertical, 8)
                                        
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.06))
                                                    .frame(width: 34, height: 34)
                                                Image(systemName: "trash")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(Color.red)
                                            }
                                            
                                            Text("Delete account")
                                                .foregroundStyle(Color.red)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            
                                            Spacer(minLength: 12)
                                        }
                                        .padding(.vertical, 10)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            showDeleteAccountAlert = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                    
                    // App Version at bottom
                    AppInfoRow()
                        .padding(.top, 32)
                        .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguagePickerSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showWatchSheet) {
            WatchInfoSheetView()
        }
        .sheet(isPresented: $showUpdatePassword) {
            UpdatePasswordView()
        }
        .sheet(isPresented: $showAsrTimeSheet) {
            AsrTimePickerSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await authManager.deleteAccount()
                    } catch {
                        // Error handled by authManager
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .tint(.accentPurple)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
