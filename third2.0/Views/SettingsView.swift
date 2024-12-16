import SwiftUI
import FirebaseFirestore
import FirebaseFunctions

import SwiftUI
import FirebaseFirestore
import FirebaseFunctions
import MessageUI

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var searchQuery: String = ""  // City input
    @State private var countryQuery: String = ""  // Country input
    @State private var isAddingNewCity: Bool = false  // Toggle for adding a new city
    @State private var errorMessage: String? = nil  // To show error messages
    @State private var showMailView: Bool = false  // Toggle to show email composer
    @State private var showMailError: Bool = false  // Show error if mail can't be sent

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)  // Background color

                VStack(spacing: 20) {
                    // Title
                    Text("Settings")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    if isAddingNewCity {
                        // Input fields for city and country
                        VStack(spacing: 15) {
                            // City Input
                            TextField("Enter a city", text: $searchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color("PageBackgroundColor"))
                                .cornerRadius(10)
                                .shadow(radius: 5)

                            // Country Input
                            TextField("Enter a country (e.g., South Korea)", text: $countryQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color("PageBackgroundColor"))
                                .cornerRadius(10)
                                .shadow(radius: 5)

                            // Save Button
                            Button(action: {
                                saveCity(city: searchQuery, countryName: countryQuery)
                            }) {
                                Text("Save")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("HighlightColor"))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .disabled(searchQuery.isEmpty || countryQuery.isEmpty) // Ensure both fields are filled
                        }
                        .padding()

                        // Show error message if any
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                    } else {
                        // Display the current city and country
                        VStack {
                            Text("Your Location")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("\(viewModel.selectedCity), \(viewModel.selectedCountry)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("HighlightColor"))
                                .padding()
                                .background(Color("PageBackgroundColor"))
                                .cornerRadius(10)
                                .shadow(radius: 5)

                            Button(action: {
                                isAddingNewCity = true // Enable adding a new city
                            }) {
                                Text("Add New City")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)  // Smaller height
                                    .padding(.horizontal, 20)
                                    .background(Color("HighlightColor"))
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                    }

                    Spacer()

                    // Feature request button
                    Button(action: {
                        if MFMailComposeViewController.canSendMail() {
                            showMailView = true
                        } else {
                            showMailError = true
                        }
                    }) {
                        SettingsButton(title: "Feature Request", icon: "envelope")
                    }
                    .sheet(isPresented: $showMailView) {
                        MailView(recipientEmail: "joseph.hayes003@gmail.com", subject: "Feature Request", body: "Please share your feature request here.")
                    }
                    .alert(isPresented: $showMailError) {
                        Alert(title: Text("Mail Not Set Up"), message: Text("Please set up a mail account to send feature requests."), dismissButton: .default(Text("OK")))
                    }

                    // Navigation Links for Mission and Privacy Policy
                    VStack(spacing: 15) {
                        NavigationLink(destination: TextDetailView(title: "Our Mission", content: MissionText.content)) {
                            SettingsButton(title: "Our Mission", icon: "chevron.right")
                        }

                        NavigationLink(destination: TextDetailView(title: "Privacy Policy", content: PrivacyPolicyText.content)) {
                            SettingsButton(title: "Privacy Policy", icon: "chevron.right")
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func saveCity(city: String, countryName: String) {
        // Convert the country name to a code
        guard let countryCode = countryCodeMapping[countryName] else {
            errorMessage = "Invalid country name. Please try again."
            return
        }

        let functions = Functions.functions()

        // Immediately update the view model
        DispatchQueue.main.async {
            viewModel.selectedCity = city
            viewModel.selectedCountry = countryCode
        }

        // Call the addCity Cloud Function
        functions.httpsCallable("addCity").call(["city": city, "country": countryCode]) { result, error in
            if let error = error {
                errorMessage = "Error adding city: \(error.localizedDescription)"
            } else if let data = result?.data as? [String: Any],
                      let message = data["message"] as? String {
                print(message)
                errorMessage = nil // Clear any previous error messages
            }
        }

        // Reset input fields and exit adding city mode
        isAddingNewCity = false
        searchQuery = ""
        countryQuery = ""
    }
}

// Custom reusable button style
struct SettingsButton: View {
    var title: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// MailView struct remains unchanged





struct MailView: UIViewControllerRepresentable {
    var recipientEmail: String
    var subject: String
    var body: String

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.setToRecipients([recipientEmail])
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: false)
        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}


// Notifications Settings View
struct NotificationsView: View {
    @Binding var azaanNotifications: Bool
    @Binding var prayerReminderNotifications: Bool

    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text("Notifications")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Toggle(isOn: $azaanNotifications) {
                    Text("Azaan Notifications")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color("BoxBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

                Toggle(isOn: $prayerReminderNotifications) {
                    Text("Prayer Reminders")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color("BoxBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

                Spacer()
            }
            .padding()
        }
    }
}

// Text detail view for Our Mission and Privacy Policy
struct TextDetailView: View {
    var title: String
    var content: String

    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Text(content)
                    .foregroundColor(.white)
                    .padding()

                Spacer()
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: CityViewModel())
    }
}

