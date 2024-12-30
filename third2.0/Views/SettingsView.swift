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
    @AppStorage("useMosqueTimetable") private var useMosqueTimetable: Bool = false
    @AppStorage("selectedMosque") private var selectedMosque: String = mosqueList.first ?? ""
    @State private var showTick: Bool = false
    


    
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

                        
                        if useMosqueTimetable {
                            settingsSection(title: "Select Mosque Timetable") {
                                VStack(spacing: 15) {
                                    Text("Mosque Timetable Enabled")
                                        .font(.headline)
                                        .foregroundColor(Color("HighlightColor"))
                                        .padding()
                                        .background(Color("BoxBackgroundColor"))
                                        .cornerRadius(10)
                                    
                                    // Use a Picker to display the mosqueList options
                                    Picker("Choose Mosque", selection: $selectedMosque) {
                                        ForEach(mosqueList, id: \.self) { mosque in
                                            Text(mosque).tag(mosque)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color("PageBackgroundColor"))
                                    .cornerRadius(10)
                                    .onChange(of: selectedMosque) { newValue in
                                        saveSelectedMosque()
                                    }



                                }
                            }
                        } else {
                            // Current City or Add New City Section
                            if isAddingNewCity {
                                settingsSection(title: "Add New City") {
                                    VStack(spacing: 15) {
                                        TextField("Enter a city", text: $searchQuery)
                                            .padding(10)
                                            .background(Color("BoxBackgroundColor"))
                                            .cornerRadius(10)
                                            .foregroundColor(Color("HighlightColor"))

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
                        
                        // MARK: - Donation Section
                        settingsSection(title: "Support Us") {
                            VStack(spacing: 30) {
                                // Decorative Banner
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("HighlightColor").opacity(0.2))
                                        .frame(height: 120)
                                    VStack {
                                        Text("Your Support Matters!")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("HighlightColor"))
                                        Text("Help us grow and keep improving the app.")
                                            .font(.subheadline)
                                            .foregroundColor(Color.gray)
                                    }
                                }

                                // Donation Options
                                HStack(spacing: 20) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(Color("HighlightColor"))
                                        Text("One-Time Donation")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Button(action: {
                                            // initiateOneTimeDonation()
                                        }) {
                                            Text("Donate")
                                                .font(.callout)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color("HighlightColor"))
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                    .background(Color("BoxBackgroundColor"))
                                    .cornerRadius(15)

                                    VStack(spacing: 10) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 36))
                                            .foregroundColor(Color("HighlightColor"))
                                        Text("Monthly Support")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Button(action: {
                                            // initiateMonthlyDonation()
                                        }) {
                                            Text("Subscribe")
                                                .font(.callout)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color("HighlightColor"))
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                    .background(Color("BoxBackgroundColor"))
                                    .cornerRadius(15)
                                }

                                // Footer Message
                                Text("Every contribution helps us build new features and improve your experience. Thank you!")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.gray)
                                    .padding(.horizontal)
                            }
                            .padding()
                            .background(Color("PageBackgroundColor"))
                            .cornerRadius(20)
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
                                MailView(recipientEmail: "thirdofthenightapp@gmail.com", subject: "Feature Request", body: "Please share your feature request here.")
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
    
    private func saveSelectedMosque() {
        guard !selectedMosque.isEmpty else {
            print("No mosque selected")
            return
        }

        print("Fetching prayer times for mosque: \(selectedMosque)")

        let functions = Functions.functions()
        functions.httpsCallable("getPrayerTimes").call(["mosque": selectedMosque]) { result, error in
            if let error = error {
                print("Error fetching prayer times: \(error.localizedDescription)")
                return
            }

            guard let data = result?.data as? [String: Any],
                  let prayerTimes = data["prayerTimes"] as? [String: String] else {
                print("Invalid prayer times format or data")
                return
            }

            viewModel.prayerTimes = prayerTimes
            print("Prayer times fetched: \(prayerTimes)")

            // Show the tick
            withAnimation {
                showTick = true
            }

            // Hide the tick after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showTick = false
                }
            }
        }

        viewModel.selectedMosque = selectedMosque
        print("Selected mosque saved: \(selectedMosque)")
  
    }




    // MARK: - Handle Timetable Toggle
    
    private func handleTimetableToggle() {
        viewModel.isUsingMosqueTimetable = useMosqueTimetable
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
