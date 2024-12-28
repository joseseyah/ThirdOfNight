import SwiftUI
import FirebaseFirestore

struct DayPrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]  // Dynamic prayer times
    @State private var currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
    @State private var dateKeys: [String] = []  // Sorted list of dates for London API
    @State private var readableDate: String = ""
    @State private var londonPrayerData: [String: Timings] = [:]  // API prayer data
    @State private var prayerData: [[String: Any]] = []  // Firebase prayer data
    @State private var maxDayIndex: Int = 0  // Maximum day index for navigation
    @Binding var isDaytime: Bool
    @Binding var moonScale: CGFloat

    var body: some View {
        ZStack {
            Color("DayBackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Sun animation
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                    .scaleEffect(moonScale)
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

                // Navigation and city name
                HStack {
                    Button(action: navigateToPreviousDay) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .disabled(currentDayIndex <= 0)

                    Spacer()

                    VStack {
                        // Display mosque name if mosque timetable is enabled, otherwise city name
                        if viewModel.isUsingMosqueTimetable {
                            Text(viewModel.selectedMosque)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        } else {
                            Text(viewModel.selectedCity)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }

                        Text(readableDate)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }


                    Spacer()

                    Button(action: navigateToNextDay) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .disabled(currentDayIndex >= maxDayIndex - 1)
                }
                .padding(.horizontal, 20)

                // Display prayer times
                if prayerTimes.isEmpty {
                    Text("Loading prayer times...")
                        .font(.title)
                        .foregroundColor(.black)
                } else {
                    VStack(spacing: 16) {
                        TimeBox(title: "Fajr", time: prayerTimes["Fajr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Sunrise", time: prayerTimes["Sunrise"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(
                            title: "Dhuhr",
                            time: prayerTimes["Dhuhr"] ?? "N/A",
                            isDaytime: isDaytime
                        )

                        TimeBox(title: "Asr", time: prayerTimes["Asr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Maghrib", time: prayerTimes["Maghrib"] ?? "N/A", isDaytime: isDaytime)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            fetchPrayerTimes(city: viewModel.selectedCity)
            updatePrayerTimesForDay()
        }
    }

    // MARK: - Fetch Prayer Times
    func fetchPrayerTimes(city: String) {
        if city.lowercased() == "london" {
            fetchLondonUnifiedTimetable()
        } else {
            fetchPrayerTimesFromFirestore(city: city)
        }
    }

    func fetchLondonUnifiedTimetable() {
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let formattedMonth = String(format: "%02d", month)

        guard let url = URL(string: "https://www.londonprayertimes.com/api/times/?format=json&key=f31cd22f-be6a-4410-bd20-cdd3b9923cff&year=\(year)&month=\(formattedMonth)&24hours=true") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching London Unified Timetable: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned from API")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(LondonPrayerTimesResponse.self, from: data)
                DispatchQueue.main.async {
                    self.londonPrayerData = decodedResponse.times
                    self.dateKeys = decodedResponse.times.keys.sorted()
                    self.maxDayIndex = self.dateKeys.count
                    self.currentDayIndex = self.dateKeys.firstIndex(of: currentReadableDate()) ?? 0
                    updatePrayerTimesForDay()
                }
            } catch {
                print("Error decoding JSON response: \(error.localizedDescription)")
            }
        }.resume()
    }

    func fetchPrayerTimesFromFirestore(city: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("prayerTimes").document(city)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let fetchedPrayerData = document.data()?["prayerTimes"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.prayerData = fetchedPrayerData
                        self.maxDayIndex = fetchedPrayerData.count
                        self.currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
                        updatePrayerTimesForDay()
                    }
                }
            } else {
                print("Failed to fetch document for city: \(city)")
            }
        }
    }
    
    func sanitizeTime(_ time: String) -> String {
        return time.components(separatedBy: " ").first ?? time
    }
    
    func fetchMosqueDetails(mosque: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Mosques").document(mosque)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    if let nestedData = data["data"] as? [[String: String]] {
                        if currentDayIndex < nestedData.count {
                            let prayerTimesDict = nestedData[currentDayIndex]
                            let mappedPrayerTimes = mapCheadleMasjidKeys(prayerTimesDict)
                            let date = prayerTimesDict["d_date"] ?? ""
                            DispatchQueue.main.async {
                                self.prayerTimes = mappedPrayerTimes
                                self.readableDate = date // Use d_date for the readable date
                            }
                        } else {
                            print("Day index out of range for prayer times data.")
                        }
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


    // MARK: - Update Prayer Times for Current Day
    func updatePrayerTimesForDay() {
        if viewModel.isUsingMosqueTimetable {
            // Mosque Prayer Times
            fetchMosqueDetails(mosque: viewModel.selectedMosque)
        } else if viewModel.selectedCity.lowercased() == "london" {
            // London Unified Timetable
            guard !dateKeys.isEmpty else { return }
            let selectedDate = dateKeys[currentDayIndex]
            if let timings = londonPrayerData[selectedDate] {
                self.prayerTimes = [
                    "Fajr": sanitizeTime(timings.fajr),
                    "Sunrise": sanitizeTime(timings.sunrise),
                    "Dhuhr": sanitizeTime(timings.dhuhr),
                    "Asr": sanitizeTime(timings.asr),
                    "Maghrib": sanitizeTime(timings.magrib),
                    "Isha": sanitizeTime(timings.isha)
                ]
                self.readableDate = selectedDate
            }
        } else {
            // Firebase Prayer Times
            guard currentDayIndex < prayerData.count else { return }
            let dayData = prayerData[currentDayIndex]
            if let date = dayData["date"] as? String {
                self.readableDate = date
            }
            if let timings = dayData["timings"] as? [String: String] {
                self.prayerTimes = timings.mapValues { sanitizeTime($0) }
            }
        }

        // Schedule notifications for all cases
        scheduleAllNotifications(prayerTimes: self.prayerTimes)
    }

    private func scheduleAllNotifications(prayerTimes: [String: String]) {
        scheduleNextPrayerNotification(prayerTimes: prayerTimes)
        scheduleTenMinutesBeforeSunriseNotification(prayerTimes: prayerTimes)
        scheduleTenMinutesBeforeDhuhrNotification(prayerTimes: prayerTimes)
        scheduleDhuhrNotification(prayerTimes: prayerTimes)
        scheduleAsrNotification(prayerTimes: prayerTimes)
        scheduleMaghribNotification(prayerTimes: prayerTimes)
        scheduleFortyMinutesBeforeMaghribNotification(prayerTimes: prayerTimes)
        scheduleTenMinutesBeforeAsrNotification(prayerTimes: prayerTimes)
    }


    // MARK: - Navigation
    func navigateToPreviousDay() {
        if currentDayIndex > 0 {
            currentDayIndex -= 1
            updatePrayerTimesForDay()
        }
    }

    func navigateToNextDay() {
        if currentDayIndex < maxDayIndex - 1 {
            currentDayIndex += 1
            updatePrayerTimesForDay()
        }
    }

    func currentReadableDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
