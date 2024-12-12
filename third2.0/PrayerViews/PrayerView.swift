import SwiftUI
import FirebaseFirestore

struct PrayerView: View {
    @ObservedObject var viewModel: CityViewModel  // Observing the view model
    @State private var prayerTimes: [String: String] = [:]
    @State private var currentDayIndex = 0  // Store the current day index (0 for 1st day of the month)
    @State private var timer: Timer?  // Timer to check for time
    @State private var moonScale: CGFloat = 1.0  // Moon scale for animation
    @State private var isDaytime = false  // Toggle between day and night mode

    var body: some View {
        ZStack {
            if isDaytime {
                // Switch to DayPrayerView when it's daytime
                DayPrayerView(viewModel: viewModel, isDaytime: $isDaytime, moonScale: $moonScale)
                    .transition(.opacity)  // Transition animation
            } else {
                // Night prayer view
                ZStack {
                    Color("BackgroundColor")
                        .edgesIgnoringSafeArea(.all)

                    // Starry background
                    StarrySkyView()

                    VStack(spacing: 20) {
                        // Animated moon and desert scene
                        ZStack {
                            // Desert dunes
                            DesertView()
                                .foregroundColor(Color(hex: "#FDF3E7"))  // Light cream for desert

                            // Pulsating Moon
                            Circle()
                                .fill(Color(hex: "#F6923A"))  // Orange moon
                                .frame(width: 100, height: 100)
                                .scaleEffect(moonScale)  // Apply the pulsating scale effect
                                .offset(y: -80)
                                .onAppear {
                                    // Start the pulsating moon animation
                                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                        moonScale = 1.2  // Increase scale slightly
                                    }
                                }
                                .onTapGesture {
                                    // Toggle between day and night views
                                    withAnimation(.easeInOut) {
                                        isDaytime.toggle()
                                    }
                                }
                        }
                        .frame(height: 300)

                        // Move city name higher
                        VStack {
                            Text(viewModel.selectedCity)
                                .font(.largeTitle)  // Larger font for the city name
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 20)  // Reduced padding to move it higher
                        }

                        Spacer()

                        // Check if prayer times have been loaded
                        if prayerTimes.isEmpty {
                            Text("Loading prayer times...")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                        } else {
                            // Display dynamically loaded prayer times
                            TimeBox(title: "Isha", time: prayerTimes["Isha"] ?? "08:00 PM", isDaytime: isDaytime)  // Add Isha TimeBox
                            TimeBox(title: "Midnight", time: prayerTimes["Midnight"] ?? "00:00 AM", isDaytime: isDaytime)
                            TimeBox(title: "Last Third of Night", time: prayerTimes["Lastthird"] ?? "03:00 AM", isDaytime: isDaytime)
                            
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Fetch prayer times for the selected city and the current day
            fetchPrayerTimes(city: viewModel.selectedCity)
            
            // Start the timer to check for 6 a.m. refresh
            startTimer()
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
        }
        .onChange(of: viewModel.selectedCity) { newCity in
            fetchPrayerTimes(city: newCity)

        }


    }

    // Fetch prayer times for the selected city from Firestore
    func fetchPrayerTimes(city: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("prayerTimes").document(city)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let prayerData = document.data()?["prayerTimes"] as? [[String: Any]] {
                    let currentDay = Calendar.current.component(.day, from: Date())
                    
                    if currentDay <= prayerData.count {
                        let dayData = prayerData[currentDay - 1]
                        
                        if let timings = dayData["timings"] as? [String: String],
                           let nextDayTimings = prayerData[(currentDay % prayerData.count)]["timings"] as? [String: String],
                           let fajrNextDay = nextDayTimings["Fajr"],
                           let maghrib = timings["Maghrib"] {
                            
                            // Sanitize times to remove timezone info
                            self.prayerTimes = timings.mapValues { sanitizeTime($0) }
                            
                            // Calculate Midnight time
                            let midnight = calculateMidnightTime(maghribTime: maghrib, fajrTime: fajrNextDay)
                            self.prayerTimes["Midnight"] = midnight
                            
                            // Calculate Last Third of the Night
                            let lastThird = calculateLastThirdOfNight(maghribTime: maghrib, fajrTime: fajrNextDay)
                            self.prayerTimes["Lastthird"] = lastThird
                        }
                    } else {
                        print("Day index out of range")
                    }
                } else {
                    print("Prayer times not available for \(city).")
                    self.prayerTimes = ["Error": "Prayer times not available."]
                }
            } else {
                print("Document does not exist for \(city): \(error?.localizedDescription ?? "Unknown error")")
                self.prayerTimes = ["Error": "City not found in Firestore."]
            }
        }
    }



    
    






    // Start a timer to check for 6 a.m. refresh
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let now = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)

            // Check if it is exactly 6:00 a.m.
            if hour == 6 && minute == 0 {
                // Fetch prayer times for the selected city at 6 a.m.
                fetchPrayerTimes(city: viewModel.selectedCity)

            }
        }
    }
    
    func sanitizeTime(_ time: String) -> String {
        // Extract the time part before any timezone or additional text
        return time.components(separatedBy: " ").first ?? time
    }

    
    func calculateMidnightTime(maghribTime: String, fajrTime: String) -> String {
        // Create a date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"  // Expect "HH:mm" format
        formatter.timeZone = TimeZone.current  // Use the current time zone

        // Parse Maghrib time to Date
        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter) else {
            return "Invalid Maghrib Time"
        }
        
        // Parse Fajr time to Date (for the next day)
        guard let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else {
            return "Invalid Fajr Time"
        }
        
        // Calculate the duration between Maghrib and Fajr
        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        
        // Calculate the midpoint
        let midnightDate = maghribDate.addingTimeInterval(totalDuration / 2)
        
        // Convert the midpoint back to a string
        return formatter.string(from: midnightDate)
    }
    
    func calculateLastThirdOfNight(maghribTime: String, fajrTime: String) -> String {
        // Create a date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"  // Expect "HH:mm" format
        formatter.timeZone = TimeZone.current  // Use the current time zone

        // Parse Maghrib time to Date
        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter) else {
            return "Invalid Maghrib Time"
        }
        
        // Parse Fajr time to Date (for the next day)
        guard let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else {
            return "Invalid Fajr Time"
        }
        
        // Calculate the duration between Maghrib and Fajr
        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        
        // Calculate the start of the last third
        let lastThirdStartDate = fajrDate.addingTimeInterval(-totalDuration / 3)
        
        // Convert the last third start time back to a string
        return formatter.string(from: lastThirdStartDate)
    }


    // Helper function to sanitize and parse time strings
    func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
        // Remove timezone information if present
        let sanitizedTime = time.components(separatedBy: " ").first ?? time
        return formatter.date(from: sanitizedTime)
    }

}



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
