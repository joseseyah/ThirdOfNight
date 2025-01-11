//
//  ContentView.swift
//  Night Prayers MacOS
//
//  Created by Joseph Hayes on 08/01/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var prayerTimes: [(name: String, time: String)] = [
        ("Fajr", "6:04 am"),
        ("Sunrise", "7:32 am"),
        ("Dhuhr", "12:57 pm"),
        ("Asr", "3:46 pm"),
        ("Maghrib", "6:14 pm"),
        ("Isha", "7:34 pm"),
        ("Midnight", "12:14 am"),
        ("Last Third", "2:45 am")
    ]
    @State private var isSettingsViewPresented = false
    private let gregorianDate = Date().formatted(date: .long, time: .omitted)

    var body: some View {
        VStack(spacing: 12) {
            // Header Section
            VStack(spacing: 4) {
                Text("Third of the Night")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("HighlightColor"))
                Text(gregorianDate)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Muharram 1438h")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)

            Divider()
                .background(Color("HighlightColor"))

            // Prayer Times List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(prayerTimes, id: \.name) { prayer in
                        HStack {
                            Text(prayer.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text(prayer.time)
                                .font(.headline)
                                .foregroundColor(Color("HighlightColor"))
                        }
                        .padding()
                        .background(Color("BoxBackgroundColor"))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(maxHeight: 300)

            Divider()
                .background(Color("HighlightColor"))

            // Footer Section
            HStack {
                Text("Cupertino")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    isSettingsViewPresented = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Color("HighlightColor"))
                }
                .sheet(isPresented: $isSettingsViewPresented) {
                    SettingsView(isPresented: $isSettingsViewPresented)
                }

            }
        }
        .padding(16)
        .background(Color("BackgroundColor"))
        .cornerRadius(12)
        .frame(width: 320, height: 450) // Optimized frame size
    }
}
