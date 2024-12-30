import Foundation
import SwiftUI

struct LocationSelectionView: View {
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""
    @AppStorage("selectedMosque") private var selectedMosque: String = ""
    @Binding var useMosqueTimetable: Bool   // New toggle for mosque timetable

    @State private var customCity: String = ""
    @State private var errorMessage: String? = nil  // Holds the validation error

     // Sample mosque list
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Select Your Preference")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Toggle between location or mosque timetable
            Picker("Timetable Type", selection: $useMosqueTimetable) {
                Text("Location").tag(false)
                Text("Mosque").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color("BoxBackgroundColor"))
            .cornerRadius(10)
            .padding(.horizontal, 20)

            if useMosqueTimetable {
                // Mosque Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Mosque")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Menu {
                        ForEach(mosqueList, id: \..self) { mosque in
                            Button(action: {
                                selectedMosque = mosque
                            }) {
                                Text(mosque)
                            }
                        }
                    } label: {
                        Text(selectedMosque.isEmpty ? "Select a mosque" : selectedMosque)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("BoxBackgroundColor"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // Location Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Country")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Menu {
                        ForEach(countryCodeMapping.keys.sorted(), id: \..self) { country in
                            Button(action: {
                                selectedCountry = country
                                selectedCity = ""  // Reset city when country changes
                            }) {
                                Text(country)
                            }
                        }
                    } label: {
                        Text(selectedCountry.isEmpty ? "Select a country" : selectedCountry)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("BoxBackgroundColor"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("City")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Enter city", text: $customCity)
                        .font(.body)
                        .foregroundColor(.white) // Text color
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("BoxBackgroundColor")) // Match the background color theme
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("HighlightColor"), lineWidth: 1) // Subtle border for visibility
                        )
                        .padding(.horizontal, 20)

                }
            }

            Spacer()

            // Validation Message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.bottom, 10)
            }

            // Continue Button
            Button(action: {
                if validateSelection() {
                    errorMessage = nil
                    if !useMosqueTimetable {
                        selectedCity = customCity  // Save the entered city
                    }
                    onContinue()
                } else {
                    errorMessage = "Invalid selection. Please select a valid option."
                }
            }) {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("HighlightColor"), Color("BoxBackgroundColor")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
            }
            .disabled(!isSelectionComplete())  // Disable button until selection is complete


            Spacer()
        }
        .background(Color("BackgroundColor"))
        .ignoresSafeArea()
    }

    // MARK: - Validation Logic
    private func validateSelection() -> Bool {
        if useMosqueTimetable {
            return !selectedMosque.isEmpty  // Valid if a mosque is selected
        } else {
            if selectedCountry == "Unified Timetable" && customCity.lowercased() != "london" {
                errorMessage = "For Unified Timetable, only 'London' is allowed as a city."
                return false
            }
            return !selectedCountry.isEmpty && !customCity.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private func isSelectionComplete() -> Bool {
        if useMosqueTimetable {
            return !selectedMosque.isEmpty  // Enable "Continue" if mosque is selected
        } else {
            return !selectedCountry.isEmpty && !customCity.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }


}

