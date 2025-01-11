//
//  SettingsView.swift
//  Night Prayers MacOS
//
//  Created by Joseph Hayes on 08/01/2025.
//

import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @Binding var isPresented: Bool // Pass a binding to manage presentation
    @State private var selectedToggle: String = "Local Masjid" // Default toggle option
    @State private var mosqueList: [String] = [] // List of mosques from Firebase
    @State private var selectedMosque: String? // Selected mosque
    @State private var isPickerVisible: Bool = false // Toggles visibility of the picker

    var body: some View {
        VStack(spacing: 20) {
            // Header with Back Button
            HStack {
                Button(action: {
                    isPresented = false // Close the settings view
                }) {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(Color("HighlightColor"))
                        .padding()
                }
                .buttonStyle(.borderless)

                Spacer()

                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("HighlightColor"))

                Spacer() // Center align the text
            }

            Divider()
                .background(Color("HighlightColor"))

            // Toggles Section
            VStack(spacing: 16) {
                ToggleBox(
                    title: "Local Masjid",
                    isActive: Binding(
                        get: { selectedToggle == "Local Masjid" },
                        set: { if $0 { selectedToggle = "Local Masjid"; isPickerVisible = true } }
                    )
                )

                if isPickerVisible && selectedToggle == "Local Masjid" {
                    VStack {
                        if mosqueList.isEmpty {
                            ProgressView("Loading mosques...")
                                .foregroundColor(.white)
                        } else {
                            Picker("Choose Mosque", selection: $selectedMosque) {
                                ForEach(mosqueList, id: \.self) { mosque in
                                    Text(mosque).tag(mosque as String?)
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
                    .onAppear {
                        fetchMosqueList { mosques in
                            mosqueList = mosques
                        }
                    }
                }

                ToggleBox(
                    title: "Location",
                    isActive: Binding(
                        get: { selectedToggle == "Location" },
                        set: { if $0 { selectedToggle = "Location"; isPickerVisible = false } }
                    )
                )

                ToggleBox(
                    title: "Input Current Location",
                    isActive: Binding(
                        get: { selectedToggle == "Input Current Location" },
                        set: { if $0 { selectedToggle = "Input Current Location"; isPickerVisible = false } }
                    )
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color("BackgroundColor"))
        .frame(width: 400, height: 400)
        .cornerRadius(12)
    }

    // Function to save selected mosque
    func saveSelectedMosque() {
        guard let selectedMosque = selectedMosque else { return }
        print("Selected Mosque: \(selectedMosque)") // Replace with persistence logic
    }

    // Function to fetch mosques from Firebase Firestore
    func fetchMosqueList(completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        var mosqueList = [String]()
        
        // Fetch documents from the "Mosques" collection
        db.collection("Mosques").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching mosques: \(error.localizedDescription)")
                completion([]) // Return an empty list in case of error
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([]) // Return an empty list if no documents
                return
            }
            
            // Extract mosque names and add to the list
            mosqueList = documents.compactMap { $0.documentID }
            
            // Pass the fetched list to the completion handler
            completion(mosqueList)
        }
    }
}

struct ToggleBox: View {
    let title: String
    @Binding var isActive: Bool

    var body: some View {
        VStack {
            Toggle(isOn: $isActive) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color("HighlightColor")))
        }
        .padding()
        .background(Color("BoxBackgroundColor"))
        .cornerRadius(8)
    }
}
