import SwiftUI

struct SettingView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isDaytimePrayersEnabled") private var isDaytimePrayersEnabled = false

    @State private var isMissionExpanded = false
    @State private var isPrivacyExpanded = false
    @State private var redirectToDaytimePrayers = false

    // Keep track of the app's current scene phase
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
                .padding(.bottom, 20)
            
            Toggle(isOn: $isDarkMode) {
                Text("Dark Mode")
            }
            .padding(.bottom, 20)
            
            Toggle(isOn: $isDaytimePrayersEnabled) {
                Text("Enable Daytime Prayers")
            }
            .padding(.bottom, 20)
            .onChange(of: isDaytimePrayersEnabled) { _ in
                redirectToDaytimePrayers = isDaytimePrayersEnabled
            }

            DisclosureGroup(
                isExpanded: $isMissionExpanded,
                content: {
                    Text("The Third of the Night app revolutionizes Tahajjud prayers, empowering Muslims to connect deeply with Allah during the sacred hours. Through innovative technology, the app facilitates a profound spiritual experience, allowing users to engage in intimate conversation with Allah, transforming nights into moments of profound connection and reflection.")
                        .padding()
                        .foregroundColor(.black)
                },
                label: {
                    Text("Our Mission")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            )
            .accentColor(.blue)

            DisclosureGroup(
                isExpanded: $isPrivacyExpanded,
                content: {
                    Text("Our Privacy Policy ensures that your personal information is protected and used responsibly. We collect data only for enhancing your app experience and employ strict security measures to safeguard it. You have full control over your information, and we are committed to transparency and compliance with privacy regulations.")
                        .padding()
                        .foregroundColor(.black)
                },
                label: {
                    Text("Privacy Policy")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            )
            .accentColor(.blue)
            
            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $redirectToDaytimePrayers) {
            DaytimePrayersView()
        }
        .onChange(of: scenePhase) { newPhase in
            // Reset the toggle state when the app moves to the background or terminates
            if newPhase == .inactive || newPhase == .background {
                isDaytimePrayersEnabled = false
            }
        }
    }
}
