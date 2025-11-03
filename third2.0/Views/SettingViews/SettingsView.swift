import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var showLanguageSheet = false

    private let sidePadding: CGFloat = 24
    private let gapBelowHeading: CGFloat = 14

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        Spacer().frame(height: 22)

                        Text("Settings")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .fontWidth(.condensed)
                            .tracking(-0.2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, sidePadding)
                            .padding(.bottom, gapBelowHeading)

                        VStack(spacing: 22) {
                            SectionCard(title: "Language") {
                                LanguageRow()
                                    .onTapGesture { showLanguageSheet = true }
                            }
                            SectionCard(title: "Travel Mode") {
                                TravelModeRows()
                            }


                            SectionCard(title: "Notifications") {
                                NotificationRows()
                            }

                            SectionCard(title: "Legal") {
                                LegalRows()
                            }

                            SectionCard(title: "About") {
                                AppInfoRow()
                            }
                        }
                        .padding(.horizontal, sidePadding)

                        Spacer(minLength: 28)
                    }
                }
            }
            .sheet(isPresented: $showLanguageSheet) {
                LanguagePickerSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .tint(.accentYellow)
    }
}



#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
