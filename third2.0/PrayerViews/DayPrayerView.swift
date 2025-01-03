import SwiftUI
import FirebaseFirestore

struct DayPrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]  // Dynamic prayer times
    @State private var currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
    @State private var dateKeys: [String] = []  // Sorted list of dates for London API
    @State private var readableDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }()
    @AppStorage("dateFormat") private var dateFormat: String = "Gregorian"
    @State private var londonPrayerData: [String: Timings] = [:]  // API prayer data
    @State private var prayerData: [[String: Any]] = []  // Firebase prayer data
    @State private var maxDayIndex: Int = 0  // Maximum day index for navigation
    @Binding var isDaytime: Bool
    @Binding var moonScale: CGFloat
    @State private var hijriDate: String = ""

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

                        Text(dateFormat == "Hijri" ? hijriDate : readableDate)
                                                    .font(.headline)
                                                    .foregroundColor(.gray)
                    }


                    Spacer()

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
                    updateDisplayedDate()
                }
                .onChange(of: dateFormat) { _ in
                    updateDisplayedDate()
                }

    }
    
    private func updateDisplayedDate() {
        if dateFormat == "Hijri" {
            // Convert the current readableDate (Gregorian) to Hijri
            if let hijri = PrayerHelper.convertToHijri(from: readableDate) {
                self.hijriDate = hijri
            }
        } else {
            // Update readableDate to Gregorian format
            self.readableDate = PrayerHelper.currentReadableDate()
        }
    }
    
    func fetchPrayerTimes(city: String) {
        if viewModel.isUsingMosqueTimetable {
            fetchMosqueDetails(mosque: viewModel.selectedMosque)
        } else if city.lowercased() == "london" && viewModel.selectedCountry.lowercased() == "unified timetable" {
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
                    self.currentDayIndex = self.dateKeys.firstIndex(of: PrayerHelper.currentReadableDate()) ?? 0
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
    
    func fetchMosqueDetails(mosque: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Mosques").document(mosque)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    if let nestedData = data["data"] as? [[String: String]] {
                        if currentDayIndex < nestedData.count {
                            let prayerTimesDict = nestedData[currentDayIndex]
                            let mappedPrayerTimes = PrayerHelper.mapCheadleMasjidKeys(prayerTimesDict)
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

    // MARK: - Update Prayer Times for Current Day
    func updatePrayerTimesForDay() {
        if viewModel.isUsingMosqueTimetable {
            // Mosque Prayer Times
            fetchMosqueDetails(mosque: viewModel.selectedMosque)
            scheduleAllNotifications(prayerTimes: self.prayerTimes)
        } else if viewModel.selectedCity.lowercased() == "london" {
            // London Unified Timetable
            guard !dateKeys.isEmpty else { return }
            let selectedDate = dateKeys[currentDayIndex]
            if let timings = londonPrayerData[selectedDate] {
                self.prayerTimes = [
                    "Fajr": PrayerHelper.sanitizeTime(timings.fajr),
                    "Sunrise": PrayerHelper.sanitizeTime(timings.sunrise),
                    "Dhuhr": PrayerHelper.sanitizeTime(timings.dhuhr),
                    "Asr": PrayerHelper.sanitizeTime(timings.asr),
                    "Maghrib": PrayerHelper.sanitizeTime(timings.magrib),
                    "Isha": PrayerHelper.sanitizeTime(timings.isha)
                ]
                self.readableDate = selectedDate
            }
            scheduleAllNotifications(prayerTimes: self.prayerTimes)
        } else {
            // Firebase Prayer Times
            guard currentDayIndex < prayerData.count else { return }
            let dayData = prayerData[currentDayIndex]
            if let date = dayData["date"] as? String {
                self.readableDate = date
            }
            if let timings = dayData["timings"] as? [String: String] {
                self.prayerTimes = timings.mapValues { PrayerHelper.sanitizeTime($0) }
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
}
