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
                        Text(viewModel.selectedCity)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
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
                            title: isFriday() ? "Jummah" : "Dhuhr",
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
    
    func isFriday() -> Bool {
        let calendar = Calendar.current
        let currentDate = calendar.date(byAdding: .day, value: currentDayIndex, to: Date()) ?? Date()
        return calendar.component(.weekday, from: currentDate) == 7
    }



    // MARK: - Update Prayer Times for Current Day
    func updatePrayerTimesForDay() {
        if viewModel.selectedCity.lowercased() == "london" {
            // London Unified Timetable
            guard !dateKeys.isEmpty else { return }
            let selectedDate = dateKeys[currentDayIndex]
            if let timings = londonPrayerData[selectedDate] {
                self.prayerTimes = [
                    "Fajr": sanitizeTime(timings.fajr),
                    "Sunrise": sanitizeTime(timings.sunrise),
                    "Dhuhr": sanitizeTime(timings.dhuhr),
                    "Asr": sanitizeTime(timings.asr),
                    "Maghrib": sanitizeTime(timings.magrib)
                ]
                self.readableDate = selectedDate

                // Schedule notification for the next prayer
                scheduleNextPrayerNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeSunriseNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeDhuhrNotification(prayerTimes: self.prayerTimes)
                scheduleDhuhrNotification(prayerTimes: self.prayerTimes)
                scheduleAsrNotification(prayerTimes: self.prayerTimes)
                scheduleMaghribNotification(prayerTimes:self.prayerTimes)
                scheduleFortyMinutesBeforeMaghribNotification(prayerTimes:self.prayerTimes)
                scheduleTenMinutesBeforeAsrNotification(prayerTimes: self.prayerTimes)
            }
        } else {
            // Firebase Prayer Times
            guard currentDayIndex < prayerData.count else { return }
            let dayData = prayerData[currentDayIndex]
            if let date = dayData["date"] as? [String: Any],
               let readable = date["readable"] as? String {
                self.readableDate = readable
            }
            if let timings = dayData["timings"] as? [String: String] {
                self.prayerTimes = timings.mapValues { sanitizeTime($0) }

                // Schedule notification for the next prayer
                scheduleNextPrayerNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeSunriseNotification(prayerTimes: self.prayerTimes)
                scheduleTenMinutesBeforeDhuhrNotification(prayerTimes: self.prayerTimes)
                scheduleDhuhrNotification(prayerTimes: self.prayerTimes)
                scheduleAsrNotification(prayerTimes: self.prayerTimes)
                scheduleMaghribNotification(prayerTimes:self.prayerTimes)
                scheduleFortyMinutesBeforeMaghribNotification(prayerTimes:self.prayerTimes)
                scheduleTenMinutesBeforeAsrNotification(prayerTimes: self.prayerTimes)
            }
        }
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
