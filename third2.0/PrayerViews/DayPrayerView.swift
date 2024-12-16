import SwiftUI
import FirebaseFirestore

struct DayPrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]
    @State private var currentDayIndex = 0  // Current index of day
    @State private var dateKeys: [String] = []  // Sorted list of dates
    @State private var readableDate: String = ""
    @State private var londonPrayerData: [String: Timings] = [:]  // API prayer data
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
                    .disabled(currentDayIndex >= dateKeys.count - 1)
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
                        TimeBox(title: "Dhuhr", time: prayerTimes["Dhuhr"] ?? "N/A", isDaytime: isDaytime)
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
                        self.updatePrayerTimesForDay()
                    }
                }
            } else {
                print("Failed to fetch document for city: \(city)")
            }
        }
    }

    // MARK: - Update Prayer Times for Current Day
    func updatePrayerTimesForDay() {
        guard !dateKeys.isEmpty else { return }
        let selectedDate = dateKeys[currentDayIndex]
        if let timings = londonPrayerData[selectedDate] {
            self.prayerTimes = [
                "Fajr": timings.fajr,
                "Sunrise": timings.sunrise,
                "Dhuhr": timings.dhuhr,
                "Asr": timings.asr,
                "Maghrib": timings.magrib
            ]
            self.readableDate = selectedDate
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
        if currentDayIndex < dateKeys.count - 1 {
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
