import Foundation
import SwiftUI

struct LocationSelectionView: View {
    @AppStorage("selectedCountry") private var selectedCountry: String = "United Kingdom"
    @AppStorage("selectedCity") private var selectedCity: String = "London"

    @State private var countries = ["United Kingdom", "Saudi Arabia", "Unified Timetable"]
    @State private var cities = ["London", "Makkah", "Medina"]
    @State private var customCountry: String = ""
    @State private var customCity: String = ""
    @State private var isCustomLocation = false
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
                    ForEach(countries, id: \.self) { country in
                        Button(action: {
                            selectedCountry = country
                            selectedCity = "London"  // Reset city when country changes
                            isCustomLocation = (country == "Custom")
                        }) {
                            Text(country)
                        }
                    }
                } label: {
                    Text(selectedCountry)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("BoxBackgroundColor"))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)

            // City Selection
            if !isCustomLocation {
                VStack(alignment: .leading, spacing: 10) {
                    Text("City")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Menu {
                        ForEach(cities, id: \.self) { city in
                            Button(action: {
                                selectedCity = city
                            }) {
                                Text(city)
                            }
                        }
                    } label: {
                        Text(selectedCity)
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Custom City")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Enter Custom City", text: $customCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
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
                    onContinue()
                } else {
                    errorMessage = "Invalid location combination. Please try again."
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

            Spacer()
        }
        .background(Color("BackgroundColor"))
        .ignoresSafeArea()
    }

    // MARK: - Validation Logic
    private func validateSelection() -> Bool {
        switch selectedCountry {
        case "United Kingdom":
            return selectedCity == "London"
        case "Saudi Arabia":
            return selectedCity == "Makkah" || selectedCity == "Medina"
        case "Unified Timetable":
            return selectedCity == "London"
        default:
            return false
        }
    }
}
