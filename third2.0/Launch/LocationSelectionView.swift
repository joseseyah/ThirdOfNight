import Foundation
import SwiftUI

struct LocationSelectionView: View {
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""

    @State private var customCity: String = ""
    @State private var errorMessage: String? = nil  // Holds the validation error

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Select Your Location")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Country Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Country")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                Menu {
                    ForEach(countryCodeMapping.keys.sorted(), id: \.self) { country in
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

            // City Input
            VStack(alignment: .leading, spacing: 10) {
                Text("City")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                TextField("Enter city", text: $customCity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
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
                    selectedCity = customCity  // Save the entered city
                    onContinue()
                } else {
                    errorMessage = "Invalid selection. Please select a valid country and city."
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
        if selectedCountry == "Unified Timetable" {
            if customCity.lowercased() != "london" {
                errorMessage = "For Unified Timetable, only 'London' is allowed as a city."
                return false
            }
        }
        return !selectedCountry.isEmpty && !customCity.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func isSelectionComplete() -> Bool {
        return !selectedCountry.isEmpty && !customCity.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
