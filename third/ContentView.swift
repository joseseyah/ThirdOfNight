//
//  ContentView.swift
//  third
//
//  Created by Joseph Hayes on 29/03/2024.
//
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    @State private var isSurahMulkExpanded = false // State variable to track the dropdown state
    @State private var fastingProgress: Double = 0.0 // State variable to track fasting progress
    @State private var midnightTime: String = "23.41" // State variable to hold the midnight time
    @State private var lastThirdTime: String = "00.59" // State variable to hold the last third of the night time
    @State private var fajrStartTime: String = "04:09" // State variable to hold the start of Fajr time
    @State private var currentTime: String = "02.00" // State variable to hold the current time
    @State private var currentMarkerIndex: Int = 0 // State variable to hold the index of the current marker

    var body: some View {
            ZStack {
                // Background gradient resembling a desert sky
                LinearGradient(gradient: Gradient(colors: [Color(red: 204/255, green: 229/255, blue: 255/255), Color(red: 153/255, green: 204/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Night Supplication")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text(stageText)
                            .font(.system(size: 14, weight: .bold)) // Set the text to bold
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.trailing, 20) // Move the text to the right side
                    }
                    
                    Text(viewModel.islamicDate)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0/255, green: 121/255, blue: 153/255)) // Different color for Islamic date
                        .padding(.leading, 20)
                        .padding(.bottom, 20)

                    HStack {
                        PrayerTimeView(title: "Fajr", time: viewModel.fajrTime)
                        PrayerTimeView(title: "Maghrib", time: viewModel.maghribTime)
                    }
                    .padding(.horizontal)

                    // Add fasting progress view
                    FastingProgressView(progress: fastingProgress)
                        .padding(.horizontal, 20)

                    // Add midnight time view
                    MidnightTimeView(midnightTime: midnightTime)
                        .padding(.horizontal, 20)

                    // Add circular timeline view
                    CircularTimelineView(timings: ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"], trackerTime: currentTime)
                        .padding(.horizontal, 20)

                    Spacer()

                    // Animated dropdown for Surah Mulk
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Surah Al-Mulk Translation:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            .onTapGesture {
                                withAnimation {
                                    isSurahMulkExpanded.toggle()
                                }
                            }
                        
                        if isSurahMulkExpanded {
                            ScrollView {
                                Text("""
                                Surah Mulk Text
                                """)
                            }
                            .foregroundColor(.black) // Change text color to black for better readability
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white) // Apply white background to the text box
                            .cornerRadius(10) // Add corner radius for rounded corners
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .onAppear {
                calculateFastingProgress()
                calculateMidnightTime()
                calculateLastThirdOfNight()
                updateCurrentTimeMarkerIndex()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    
    func calculateFastingProgress() {
        guard let fajrTime = Double(viewModel.fajrTime), let maghribTime = Double(viewModel.maghribTime) else {
            return
        }
        let currentTime = Date()
        let totalFastingDuration = maghribTime - fajrTime
        let elapsedFastingDuration = currentTime.timeIntervalSinceReferenceDate - fajrTime
        let progress = elapsedFastingDuration / totalFastingDuration
        self.fastingProgress = max(0.0, min(progress, 1.0))
    }
    
    func calculateMidnightTime() {
        guard let maghribTime = convertTimeStringToDecimal(viewModel.maghribTime),
              let fajrTimeNextDay = convertTimeStringToDecimal(viewModel.fajrTimeNextDay)
        else {
            return
        }
        
        // Calculate the time difference between Maghrib and Fajr
        var timeDifference = fajrTimeNextDay - maghribTime
        
        // If the time difference is negative, it means Fajr time crosses midnight
        if timeDifference < 0 {
            timeDifference += 24 // Add 24 hours to account for crossing midnight
        }
        
        // Calculate midnight time as the sum of Maghrib time and half the time difference between Maghrib and Fajr
        let midnightTimeDecimal = maghribTime + (timeDifference / 2)
        
        // Convert the decimal time to hours and minutes
        let midnightHour = Int(midnightTimeDecimal)
        let midnightMinute = Int((midnightTimeDecimal - Double(midnightHour)) * 60)
        
        // Format the midnight time
        self.midnightTime = String(format: "%02d:%02d", midnightHour, midnightMinute)
    }
    
    func calculateLastThirdOfNight() {
        // Assuming the last third of the night starts 2 hours before Fajr
        guard let fajrTime = convertTimeStringToDecimal(viewModel.fajrTime) else {
            return
        }
        
        // Calculate last third time as Fajr time minus 2 hours
        let lastThirdTimeDecimal = fajrTime - 2
        
        // Convert the decimal time to hours and minutes
        let lastThirdHour = Int(lastThirdTimeDecimal)
        let lastThirdMinute = Int((lastThirdTimeDecimal - Double(lastThirdHour)) * 60)
        
        // Format the last third time
        self.lastThirdTime = String(format: "%02d:%02d", lastThirdHour, lastThirdMinute)
    }

    func convertTimeStringToDecimal(_ timeString: String) -> Double? {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let hours = Double(components[0]),
              let minutes = Double(components[1])
        else {
            return nil
        }
        return hours + (minutes / 60)
    }
    
    func updateCurrentTimeMarkerIndex() {
        let currentTimeDecimal = convertTimeStringToDecimal(currentTime) ?? 0.0
        var currentIndex = 0
        let timings = ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"]
        for i in 0..<timings.count {
            if let time = convertTimeStringToDecimal(timings[i]) {
                if currentTimeDecimal < time {
                    currentIndex = i
                    break
                }
            }
        }
        self.currentMarkerIndex = currentIndex
    }
    
    private var stageText: String {
            // Determine the stage based on the current time
            let currentTimeDecimal = convertTimeStringToDecimal(currentTime) ?? 0.0
            switch currentMarkerIndex {
            case 0:
                return currentTimeDecimal < 1.0 ? "Sunset" : "Isha Ended"
            case 1:
                return "Midnight"
            case 2:
                return "Last Third"
            case 3:
                return "Fajr"
            case 4:
                return "Sunrise"
            default:
                return ""
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




















