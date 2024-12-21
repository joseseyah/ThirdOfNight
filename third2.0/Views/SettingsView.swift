import SwiftUI
import FirebaseFunctions
import MessageUI

struct SettingsView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var searchQuery: String = ""
    @State private var selectedCountry: String = ""
    @State private var isAddingNewCity: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showMailView: Bool = false
    @State private var showMailError: Bool = false
    @State private var useMosqueTimetable: Bool = false
    
    @AppStorage("dateFormat") private var dateFormat: String = "Gregorian"

    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        // Mosque Timetable Toggle
                        settingsSection(title: "Prayer Timetable") {
                            Toggle("Use Mosque Timetable", isOn: $useMosqueTimetable)
                                .padding()
                                .background(Color("BoxBackgroundColor"))
                                .cornerRadius(10)
                                .onChange(of: useMosqueTimetable) { _ in
                                    handleTimetableToggle()
                                }
                        }

                        // Custom Location or Mosque Timetable Section
                        if useMosqueTimetable {
                            settingsSection(title: "Select Mosque Timetable") {
                                VStack(spacing: 15) {
                                    Text("Mosque Timetable Enabled")
                                        .font(.headline)
                                        .foregroundColor(Color("HighlightColor"))
                                        .padding()
                                        .background(Color("BoxBackgroundColor"))
                                        .cornerRadius(10)

                                    // Add additional UI for selecting mosque timetables here
                                    // Example:
                                    Button(action: {
                                        // Placeholder action for selecting a mosque
                                    }) {
                                        Text("Choose Mosque")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color("HighlightColor"))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        } else {
                            // Current City or Add New City Section
                            if isAddingNewCity {
                                settingsSection(title: "Add New City") {
                                    VStack(spacing: 15) {
                                        TextField("Enter a city", text: $searchQuery)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .padding(10)
                                            .background(Color("PageBackgroundColor"))
                                            .cornerRadius(10)

                                        Picker("Select a country", selection: $selectedCountry) {
                                            ForEach(countryCodeMapping.keys.sorted(), id: \.self) { country in
                                                Text(country).tag(country)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .padding()
                                        .background(Color("PageBackgroundColor"))
                                        .cornerRadius(10)

                                        Button(action: {
                                            saveCity(city: searchQuery, countryName: selectedCountry)
                                        }) {
                                            Text("Save City")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color("HighlightColor"))
                                                .cornerRadius(10)
                                        }
                                        .disabled(searchQuery.isEmpty || selectedCountry.isEmpty)

                                        if let errorMessage = errorMessage {
                                            Text(errorMessage)
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            } else {
                                settingsSection(title: "Your Location") {
                                    VStack(spacing: 15) {
                                        Text("\(viewModel.selectedCity), \(viewModel.selectedCountry)")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("HighlightColor"))
                                            .padding()
                                            .background(Color("BoxBackgroundColor"))
                                            .cornerRadius(10)

                                        Button(action: { isAddingNewCity = true }) {
                                            Text("Add New City")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color("HighlightColor"))
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }

                        // Date Format Picker
                        settingsSection(title: "Date Format") {
                            Picker("Date Format", selection: $dateFormat) {
                                Text("Gregorian").tag("Gregorian")
                                Text("Hijri").tag("Hijri")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .background(Color("BoxBackgroundColor"))
                            .cornerRadius(10)
                        }
                        .onChange(of: dateFormat) { _ in
                            NotificationCenter.default.post(name: .dateFormatChanged, object: nil)
                        }

                        // Feature Request Section
                        settingsSection(title: "Feature Request") {
                            Button(action: {
                                if MFMailComposeViewController.canSendMail() {
                                    showMailView = true
                                } else {
                                    showMailError = true
                                }
                            }) {
                                SettingsButton(title: "Send Feedback", icon: "envelope")
                            }
                            .sheet(isPresented: $showMailView) {
                                MailView(recipientEmail: "joseph.hayes003@gmail.com", subject: "Feature Request", body: "Please share your feature request here.")
                            }
                            .alert(isPresented: $showMailError) {
                                Alert(title: Text("Mail Not Set Up"), message: Text("Please set up a mail account to send feature requests."), dismissButton: .default(Text("OK")))
                            }
                        }

                        // Mission and Policy Section
                        settingsSection(title: "About") {
                            VStack(spacing: 10) {
                                NavigationLink(destination: TextDetailView(title: "Our Mission", content: MissionText.content)) {
                                    SettingsButton(title: "Our Mission", icon: "info.circle")
                                }
                                NavigationLink(destination: TextDetailView(title: "Privacy Policy", content: PrivacyPolicyText.content)) {
                                    SettingsButton(title: "Privacy Policy", icon: "lock.circle")
                                }
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Handle Timetable Toggle
    private func handleTimetableToggle() {
        if useMosqueTimetable {
            viewModel.isUsingMosqueTimetable = true
        } else {
            viewModel.isUsingMosqueTimetable = false
        }
    }

    // MARK: - Save City Logic
    private func saveCity(city: String, countryName: String) {
        guard let countryCode = countryCodeMapping[countryName] else {
            errorMessage = "Invalid country name. Please try again."
            return
        }
        viewModel.selectedCity = city
        viewModel.selectedCountry = countryCode

        // Reset fields
        isAddingNewCity = false
        searchQuery = ""
        selectedCountry = ""
    }

    // MARK: - Helper for Settings Section
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            content()
        }
        .padding()
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

extension Notification.Name {
    static let dateFormatChanged = Notification.Name("dateFormatChanged")
}

