import SwiftUI
import FirebaseFirestore

struct PrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]
    @State private var currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
    @State private var maxDayIndex = 30  // Default max days for the month
    @State private var timer: Timer?
    @State private var moonScale: CGFloat = 1.0
    @State private var isDaytime = false
    @State private var readableDate: String = ""  // Holds the readable date
    @State private var prayerData: [[String: Any]] = []  // Store prayer times for the entire month

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
                            Button(action: {
                                navigateToPreviousDay()
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .disabled(currentDayIndex <= 0)

                            Spacer()

                            VStack {
                                Text(viewModel.selectedCity)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                if !readableDate.isEmpty {
                                    Text(readableDate)
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "#F6923A"))
                                }
                            }

                            Spacer()

                            Button(action: {
                                navigateToNextDay()
                            }) {
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
                            TimeBox(title: "Isha", time: prayerTimes["Isha"] ?? "08:00 PM", isDaytime: isDaytime)
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
            fetchPrayerTimes(city: viewModel.selectedCity)
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Fetch Prayer Times Once
    func fetchPrayerTimes(city: String) {
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

    // MARK: - Update Prayer Times for the Current Day Index
    func updatePrayerTimesForDay() {
        guard currentDayIndex < prayerData.count else { return }

        let dayData = prayerData[currentDayIndex]

        if let date = dayData["date"] as? [String: Any],
           let readable = date["readable"] as? String {
            self.readableDate = readable
        }

        if let timings = dayData["timings"] as? [String: String],
           let nextDayTimings = prayerData[(currentDayIndex + 1) % prayerData.count]["timings"] as? [String: String],
           let fajrNextDay = nextDayTimings["Fajr"],
           let maghrib = timings["Maghrib"] {
            self.prayerTimes = timings.mapValues { sanitizeTime($0) }
            self.prayerTimes["Midnight"] = calculateMidnightTime(maghribTime: maghrib, fajrTime: fajrNextDay)
            self.prayerTimes["Lastthird"] = calculateLastThirdOfNight(maghribTime: maghrib, fajrTime: fajrNextDay)
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

    // MARK: - Utility Functions
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            let now = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)

            if hour == 6 && minute == 0 {
                fetchPrayerTimes(city: viewModel.selectedCity)
            }
        }
    }

    func sanitizeTime(_ time: String) -> String {
        return time.components(separatedBy: " ").first ?? time
    }

    func calculateMidnightTime(maghribTime: String, fajrTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else {
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        let midnightDate = maghribDate.addingTimeInterval(totalDuration / 2)
        return formatter.string(from: midnightDate)
    }

    func calculateLastThirdOfNight(maghribTime: String, fajrTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        guard let maghribDate = sanitizeAndParseTime(maghribTime, using: formatter),
              let fajrDate = sanitizeAndParseTime(fajrTime, using: formatter)?.addingTimeInterval(24 * 60 * 60) else {
            return "Invalid"
        }

        let totalDuration = fajrDate.timeIntervalSince(maghribDate)
        let lastThirdStart = fajrDate.addingTimeInterval(-totalDuration / 3)
        return formatter.string(from: lastThirdStart)
    }

    func sanitizeAndParseTime(_ time: String, using formatter: DateFormatter) -> Date? {
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
