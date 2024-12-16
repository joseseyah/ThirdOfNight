import SwiftUI
import FirebaseFunctions
import MessageUI

struct SettingsView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var searchQuery: String = ""  // City input
    @State private var countryQuery: String = ""  // Country input
    @State private var isAddingNewCity: Bool = false  // Toggle for adding a new city
    @State private var errorMessage: String? = nil  // To show error messages
    @State private var showMailView: Bool = false  // Toggle to show email composer
    @State private var showMailError: Bool = false  // Show error if mail can't be sent

    @AppStorage("dateFormat") private var dateFormat: String = "Gregorian" // Default to Gregorian

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Title
                    Text("Settings")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    // Date Format Picker
                    VStack {
                        Text("Date Format")
                            .font(.headline)
                            .foregroundColor(.white)

                        Picker("Date Format", selection: $dateFormat) {
                            Text("Gregorian").tag("Gregorian")
                            Text("Hijri").tag("Hijri")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(Color("BoxBackgroundColor"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .onChange(of: dateFormat) { _ in
                            NotificationCenter.default.post(name: .dateFormatChanged, object: nil)
                        }
                    }

                    // Add New City Section
                    if isAddingNewCity {
                        addNewCityView()
                    } else {
                        currentCityView()
                    }

                    Spacer()

                    // Feature Request Section
                    featureRequestSection()

                    // Mission and Policy Section
                    missionAndPolicySection()
                }
            }
        }
    }

    // MARK: - Add New City View
    private func addNewCityView() -> some View {
        VStack(spacing: 15) {
            TextField("Enter a city", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color("PageBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

            TextField("Enter a country (e.g., Unified Timetable)", text: $countryQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color("PageBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

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
            .disabled(searchQuery.isEmpty || countryQuery.isEmpty)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }

    // MARK: - Current City View
    private func currentCityView() -> some View {
        VStack {
            Text("Your Location")
                .font(.headline)
                .foregroundColor(.white)

            Text("\(viewModel.selectedCity), \(viewModel.selectedCountry)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("HighlightColor"))
                .padding()
                .background(Color("PageBackgroundColor"))
                .cornerRadius(10)
                .shadow(radius: 5)

            Button(action: {
                isAddingNewCity = true
            }) {
                Text("Add New City")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color("HighlightColor"))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }

    // MARK: - Feature Request Section
    private func featureRequestSection() -> some View {
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
    }

    // MARK: - Mission and Policy Section
    private func missionAndPolicySection() -> some View {
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

    // MARK: - Save City Logic
    private func saveCity(city: String, countryName: String) {
        if city.lowercased() == "london" && countryName.lowercased() == "unified timetable" {
            viewModel.selectedCity = "London"
            viewModel.selectedCountry = "Unified Timetable"
            viewModel.isUsingLondonUnifiedTimetable = true
            viewModel.fetchLondonUnifiedTimetable() // Fetch London API
        } else {
            guard let countryCode = countryCodeMapping[countryName] else {
                errorMessage = "Invalid country name. Please try again."
                return
            }
            viewModel.selectedCity = city
            viewModel.selectedCountry = countryCode
        }

        // Reset fields
        isAddingNewCity = false
        searchQuery = ""
        countryQuery = ""
    }
}


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

extension Notification.Name {
    static let dateFormatChanged = Notification.Name("dateFormatChanged")
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: CityViewModel())
    }
}

