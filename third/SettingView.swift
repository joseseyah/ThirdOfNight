import SwiftUI

struct SettingView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isMissionExpanded = false // State variable to track mission dropdown
    @State private var isPrivacyExpanded = false // State variable to track privacy policy dropdown
    
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
            
            // Our Mission section
            DisclosureGroup(
                isExpanded: $isMissionExpanded,
                content: {
                    Text("The Third of the Night app revolutionizes Tahajjud prayers, empowering Muslims to connect deeply with Allah during the sacred hours. Through innovative technology, the app facilitates a profound spiritual experience, allowing users to engage in intimate conversation with Allah, transforming nights into moments of profound connection and reflection.")
                        .padding()
                        .foregroundColor(.black)
                },
                label: {
                    Text("Our Mission")
                        .foregroundColor(.blue) // Adjusted label color to blue
                        .font(.headline)
                }
            )
            .accentColor(.blue) // Adjusted accent color to blue
            
            // Privacy Policy section
            DisclosureGroup(
                isExpanded: $isPrivacyExpanded,
                content: {
                    Text("Our Privacy Policy ensures that your personal information is protected and used responsibly. We collect data only for enhancing your app experience and employ strict security measures to safeguard it. You have full control over your information, and we are committed to transparency and compliance with privacy regulations.")
                        .padding()
                        .foregroundColor(.black)
                },
                label: {
                    Text("Privacy Policy")
                        .foregroundColor(.blue) // Adjusted label color to blue
                        .font(.headline)
                }
            )
            .accentColor(.blue) // Adjusted accent color to blue
            
            Spacer()
        }
        .padding()
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
