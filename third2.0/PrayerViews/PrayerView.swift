import SwiftUI
import FirebaseFirestore

struct PrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]
    @State private var currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
    @State private var maxDayIndex = 30
    @State private var timer: Timer?
    @State private var moonScale: CGFloat = 1.0
    @State private var isDaytime = false
    @State private var readableDate: String = ""
    @State private var hijriDate: String = ""
    @State private var prayerData: [[String: Any]] = []
    
    @AppStorage("dateFormat") private var dateFormat: String = "Gregorian" // Date format setting

    var body: some View {
        ZStack {
            if isDaytime {
                DayPrayerView(viewModel: viewModel, isDaytime: $isDaytime, moonScale: $moonScale)
                    .transition(.opacity)
            } else {
                ZStack {
                    Color("BackgroundColor")
                        .edgesIgnoringSafeArea(.all)

                    StarrySkyView()

                    VStack(spacing: 20) {
                        ZStack {
                            DesertView()
                                .foregroundColor(Color(hex: "#FDF3E7"))

                            Circle()
                                .fill(Color(hex: "#F6923A"))
                                .frame(width: 100, height: 100)
                                .scaleEffect(moonScale)
                                .offset(y: -80)
                                .onAppear {
                                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                        moonScale = 1.2
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isDaytime.toggle()
                                    }
                                }
                        }
                        .frame(height: 300)

                        // Navigation Arrows and City Name
                        HStack {
                            Button(action: { navigateToPreviousDay() }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .disabled(currentDayIndex <= 0)

                            Spacer()

                            VStack {
                                // Show mosque name if mosque timetables are enabled
                                if viewModel.isUsingMosqueTimetable {
                                    Text(viewModel.selectedMosque)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                } else {
                                    Text(viewModel.selectedCity)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                // Date Display - Hijri or Gregorian
                                if dateFormat == "Hijri" {
                                    Text(hijriDate)
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "#F6923A"))
                                } else {
                                    Text(readableDate)
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "#F6923A"))
                                }
                            }


                            Spacer()

                            Button(action: { navigateToNextDay() }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .disabled(currentDayIndex >= maxDayIndex - 1)
                        }
                        .padding(.horizontal, 20)

                        Spacer()

                        if prayerTimes.isEmpty {
                            Text("Loading prayer times...")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                        } else {
                            TimeBox(title: "Isha", time: prayerTimes["Isha"] ?? defaultPrayerTimes["Isha"]!, isDaytime: isDaytime)
                            TimeBox(title: "Midnight", time: prayerTimes["Midnight"] ?? defaultPrayerTimes["Midnight"]!, isDaytime: isDaytime)
                            TimeBox(title: "Last Third of Night", time: prayerTimes["Lastthird"] ?? defaultPrayerTimes["Lastthird"]!, isDaytime: isDaytime)

                        }

                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchPrayerTimes(city: viewModel.selectedCity)
            startTimer()

            // Listen for date format changes
            NotificationCenter.default.addObserver(forName: .dateFormatChanged, object: nil, queue: .main) { _ in
                updatePrayerTimesForDay()
            }
        }
        .onDisappear {
            timer?.invalidate()
            NotificationCenter.default.removeObserver(self, name: .dateFormatChanged, object: nil)
        }
    }
    
    func convertToHijri(from date: Date) -> String {
        let islamicCalendar = Calendar(identifier: .islamicUmmAlQura)
        let formatter = DateFormatter()
        formatter.calendar = islamicCalendar
        formatter.dateFormat = "dd MMMM yyyy" // Example format: 05 Jumada I 1445
        formatter.locale = Locale(identifier: "en") // Set to "ar" for Arabic names if needed
        return formatter.string(from: date)
    }


    // MARK: - Fetch Prayer Times
    
    func fetchPrayerTimes(city: String) {
        if viewModel.isUsingMosqueTimetable {
            fetchMosqueDetails(mosque: viewModel.selectedMosque)
        } else if city.lowercased() == "london" && viewModel.selectedCountry.lowercased() == "unified timetable" {
            fetchLondonUnifiedTimetableAPI()
        } else {
            fetchPrayerTimesFromFirestore(city: city)
        }
    }


    // MARK: - Fetch London Unified Timetable API
    func fetchLondonUnifiedTimetableAPI() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let formattedMonth = String(format: "%02d", month)

        guard let url = URL(string: "https://www.londonprayertimes.com/api/times/?format=json&key=f31cd22f-be6a-4410-bd20-cdd3b9923cff&year=\(year)&month=\(formattedMonth)&24hours=true") else {
            print("Invalid API URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching Unified Timetable API: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned from API")
                return
            }

            // Debug: Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(LondonPrayerTimesResponse.self, from: data)

                DispatchQueue.main.async {
                    self.prayerData = decodedResponse.times.map { date, timings in
                        return [
                            "date": date,
                            "timings": timings
                        ]
                    }

                    // Sort prayerData by date
                    self.prayerData.sort {
                        guard let date1 = $0["date"] as? String,
                              let date2 = $1["date"] as? String else {
                            return false
                        }
                        return date1 < date2
                    }

                    self.maxDayIndex = self.prayerData.count

                    // Set default to today
                    self.currentDayIndex = self.prayerData.firstIndex(where: { ($0["date"] as? String) == self.currentReadableDate() }) ?? 0
                    self.updatePrayerTimesForLondonDay()
                }
            } catch {
                print("Error decoding JSON response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func fetchMosqueDetails(mosque: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Mosques").document(mosque)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(),
                   let nestedData = data["data"] as? [[String: String]] {
                    if currentDayIndex < nestedData.count {
                        let prayerTimesDict = nestedData[currentDayIndex]
                        let mappedPrayerTimes = mapCheadleMasjidKeys(prayerTimesDict)
                        let date = prayerTimesDict["d_date"] ?? ""

                        // Fetch next day's Fajr time
                        fetchNextDayFajrTime(mosque: mosque, nextDayIndex: currentDayIndex + 1) { nextDayFajr in
                            DispatchQueue.main.async {
                                var updatedPrayerTimes = mappedPrayerTimes
                                if let maghribTime = mappedPrayerTimes["Maghrib"],
                                   let fajrTime = nextDayFajr {
                                    updatedPrayerTimes["Midnight"] = calculateMidnightTime(maghribTime: maghribTime, fajrTime: fajrTime)
                                    updatedPrayerTimes["Lastthird"] = calculateLastThirdOfNight(maghribTime: maghribTime, fajrTime: fajrTime)
                                }
                                self.prayerTimes = updatedPrayerTimes
                                self.readableDate = date
                            }
                        }
                    } else {
                        print("Day index out of range for prayer times data.")
                    }
                }
            } else {
                print("Failed to fetch mosque document: \(mosque)")
            }
        }
    }




    func mapCheadleMasjidKeys(_ prayerTimesDict: [String: String]) -> [String: String] {
        return [
            "Fajr": formatTime(prayerTimesDict["fajr_begins"] ?? "N/A"),
            "Sunrise": formatTime(prayerTimesDict["sunrise"] ?? "N/A"),
            "Dhuhr": formatTime(prayerTimesDict["zuhr_begins"] ?? "N/A"),
            "Asr": formatTime(prayerTimesDict["asr_jamah"] ?? "N/A"),
            "Maghrib": formatTime(prayerTimesDict["maghrib_begins"] ?? "N/A"),
            "Isha": formatTime(prayerTimesDict["isha_begins"] ?? "N/A")
        ]
    }

    // MARK: - Fetch from Firestore
    func fetchPrayerTimesFromFirestore(city: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("prayerTimes").document(city)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let fetchedPrayerData = document.data()?["prayerTimes"] as? [[String: Any]] {
                    self.prayerData = fetchedPrayerData
                    self.maxDayIndex = fetchedPrayerData.count
                    updatePrayerTimesForDay()
                }
            } else {
                print("Failed to fetch document for city: \(city)")
            }
        }
    }
    
    

    // MARK: - Helper to Get Current Date
    func currentReadableDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // MARK: - Update Prayer Times for the Day
    func updatePrayerTimesForDay() {
        if viewModel.isUsingMosqueTimetable {
            fetchMosqueDetails(mosque: viewModel.selectedMosque)
            
        } else{
            guard currentDayIndex < prayerData.count else { return }

            let dayData = prayerData[currentDayIndex]

            if let date = dayData["date"] as? [String: Any],
               let readable = date["readable"] as? String {
                self.readableDate = readable
            }

            if let hijri = dayData["hijri"] as? [String: Any],
               let day = hijri["day"] as? String,
               let month = hijri["month"] as? [String: Any],
               let monthName = month["en"] as? String,
               let year = hijri["year"] as? String {
                self.hijriDate = "\(day) \(monthName) \(year)"  // Format Hijri date
            }

            if let timings = dayData["timings"] as? [String: String],
               let nextDayTimings = prayerData[(currentDayIndex + 1) % prayerData.count]["timings"] as? [String: String],
               let fajrNextDay = nextDayTimings["Fajr"],
               let maghrib = timings["Maghrib"] {
                self.prayerTimes = timings.mapValues { sanitizeTime($0) }
                self.prayerTimes["Midnight"] = calculateMidnightTime(maghribTime: maghrib, fajrTime: fajrNextDay)
                self.prayerTimes["Lastthird"] = calculateLastThirdOfNight(maghribTime: maghrib, fajrTime: fajrNextDay)
                
                
                scheduleLastThirdOfNightNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeMidnightNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeIshaNotification(prayerTimes: self.prayerTimes)
            }
            
        }
        
    }
    
    func fetchNextDayFajrTime(mosque: String, nextDayIndex: Int, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("Mosques").document(mosque)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(),
                   let nestedData = data["data"] as? [[String: String]] {
                    if nextDayIndex < nestedData.count {
                        let nextDayPrayerTimes = nestedData[nextDayIndex]
                        let fajrTime = nextDayPrayerTimes["fajr_begins"]
                        completion(fajrTime)
                        return
                    }
                }
            }
            completion(nil) // Return nil if fetching fails
        }
    }

    
    func updatePrayerTimesForLondonDay() {
        guard currentDayIndex < prayerData.count else { return }

        let dayData = prayerData[currentDayIndex]
        if let date = dayData["date"] as? String,
           let timings = dayData["timings"] as? Timings {
            self.readableDate = date
            self.prayerTimes = [
                "Isha": timings.isha,
                "Midnight": calculateMidnightTime(maghribTime: timings.magrib, fajrTime: timings.fajr),
                "Lastthird": calculateLastThirdOfNight(maghribTime: timings.magrib, fajrTime: timings.fajr)
            ]
            
            scheduleLastThirdOfNightNotification(prayerTimes: self.prayerTimes)
            scheduleTenMinutesBeforeMidnightNotification(prayerTimes: self.prayerTimes)
            scheduleTenMinutesBeforeIshaNotification(prayerTimes: self.prayerTimes)
        }
    }


    func navigateToPreviousDay() {
        if currentDayIndex > 0 {
            currentDayIndex -= 1
            updatePrayerTimes()
        }
    }

    func navigateToNextDay() {
        if currentDayIndex < prayerData.count - 1 {
            currentDayIndex += 1
            updatePrayerTimes()
        }
    }

    // Unified function to decide which update function to call
    func updatePrayerTimes() {
        if viewModel.selectedCity.lowercased() == "london" && viewModel.selectedCountry.lowercased() == "unified timetable" {
            updatePrayerTimesForLondonDay()
        } else {
            updatePrayerTimesForDay()
        }
    }

    // MARK: - Utility Functions
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let now = Date()
            let hour = Calendar.current.component(.hour, from: now)
            let minute = Calendar.current.component(.minute, from: now)

            if hour == 6 && minute == 0 {
                fetchPrayerTimes(city: viewModel.selectedCity)
            }
        }
    }

    func sanitizeTime(_ time: String) -> String {
        return time.components(separatedBy: " ").first ?? time
    }
    
    func formatTime(_ time: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss" // Input format from Firestore

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        if let date = inputFormatter.date(from: time) {
            return outputFormatter.string(from: date)
        }

        return time // Fallback to original if parsing fails
    }


    func calculateMidnightTime(maghribTime: String, fajrTime: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm" // Input format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: inputFormatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: inputFormatter)?.addingTimeInterval(24 * 60 * 60) else {
            print("Error calculating Midnight: Invalid Maghrib (\(maghribTime)) or Fajr (\(fajrTime)) time")
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return outputFormatter.string(from: maghribDate.addingTimeInterval(totalDuration / 2))
    }

    func calculateLastThirdOfNight(maghribTime: String, fajrTime: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm" // Input format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Desired output format

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: inputFormatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: inputFormatter)?.addingTimeInterval(24 * 60 * 60) else {
            print("Error calculating Last Third of Night: Invalid Maghrib (\(maghribTime)) or Fajr (\(fajrTime)) time")
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        return outputFormatter.string(from: fajrDate.addingTimeInterval(-totalDuration / 3))
    }





    func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
        let sanitizedTime = time.components(separatedBy: " ").first ?? time
        
        // Try parsing with "HH:mm" format first
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: sanitizedTime) {
            return date
        }
        
        // Fallback to "HH:mm:ss" if "HH:mm" fails
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: sanitizedTime) {
            return date
        }
        
        print("Failed to parse time: \(sanitizedTime)")
        return nil
    }

}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
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


