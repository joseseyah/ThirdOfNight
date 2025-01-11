//
//  PrayerTimetableView.swift
//  Night Prayers
//
//  Created by Joseph Hayes on 05/01/2025.
//

import Foundation
import SwiftUI
struct PrayerTimesView: View {
    @ObservedObject var viewModel: CityViewModel
    @AppStorage("useMosqueTimetable") private var useMosqueTimetable: Bool = false
    @AppStorage("selectedMosque") private var selectedMosque: String = mosqueList.first ?? ""
    @State private var searchQuery: String = ""
    @State private var selectedCountry: String = ""
    @State private var errorMessage: String? = nil
    @State private var isAddingNewCity: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("Prayer Times Manager")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // Mosque Timetable Toggle
                settingsSection(title: "Prayer Timetable") {
                    Toggle("Use Mosque Timetable", isOn: $useMosqueTimetable)
                        .padding()
                        .background(Color("BoxBackgroundColor"))
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .onChange(of: useMosqueTimetable) { _ in
                            viewModel.isUsingMosqueTimetable = useMosqueTimetable
                        }
                }
                
                if useMosqueTimetable {
                    // Mosque selection when toggle is enabled
                    settingsSection(title: "Select Mosque Timetable") {
                        Picker("Choose Mosque", selection: $selectedMosque) {
                            ForEach(mosqueList, id: \.self) { mosque in
                                Text(mosque).tag(mosque)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .frame(maxWidth: .infinity) 
                        .background(Color("PageBackgroundColor"))
                        .cornerRadius(10)
                        .onChange(of: selectedMosque) { _ in
                            saveSelectedMosque()
                        }
                    }
                } else {
                    // Location Management Section
                    settingsSection(title: "Your Location") {
                        if isAddingNewCity {
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
                        } else {
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
            }
            .padding()
        }
        .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
    }
    
    // Save selected mosque logic
    private func saveSelectedMosque() {
        guard !selectedMosque.isEmpty else { return }
        print("Fetching prayer times for mosque: \(selectedMosque)")
        // Add Firebase or related logic here to fetch times
    }
    
    // Save city logic
    private func saveCity(city: String, countryName: String) {
        guard let countryCode = countryCodeMapping[countryName] else {
            errorMessage = "Invalid country name. Please try again."
            return
        }
        viewModel.selectedCity = city
        viewModel.selectedCountry = countryCode
        isAddingNewCity = false
        searchQuery = ""
        selectedCountry = ""
    }
    
    // Helper for consistent sections
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
        .frame(maxWidth: .infinity) // Ensure consistent width
        .shadow(radius: 5)
    }
}

