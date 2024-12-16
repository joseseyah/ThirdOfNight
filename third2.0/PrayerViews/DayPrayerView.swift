import SwiftUI
import FirebaseFirestore

struct DayPrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]  // Dynamic prayer times
    @State private var currentDayIndex = Calendar.current.component(.day, from: Date()) - 1
    @State private var maxDayIndex = 30  // Default max days for the month
    @State private var readableDate: String = ""  // Holds the readable date
    @State private var prayerData: [[String: Any]] = []  // Store all prayer times for the month
    @Binding var isDaytime: Bool  // Bind the toggle to switch back to night mode
    @Binding var moonScale: CGFloat  // Reuse moonScale to animate the sun

    var body: some View {
        ZStack {
            // Daytime color background
            Color("DayBackgroundColor")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Pulsating Sun
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

                // Navigation Arrows and City Name
                HStack {
                    Button(action: {
                        navigateToPreviousDay()
                    }) {
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

                        if !readableDate.isEmpty {
                            Text(readableDate)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    Button(action: {
                        navigateToNextDay()
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .disabled(currentDayIndex >= maxDayIndex - 1)
                }
                .padding(.horizontal, 20)

                // Prayer Times
                if prayerTimes.isEmpty {
                    Text("Loading prayer times...")
                        .foregroundColor(.black)
                        .font(.title)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        TimeBox(title: "Fajr", time: prayerTimes["Fajr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Sunrise", time: prayerTimes["Sunrise"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: isFriday() ? "Jummah" : "Dhuhr", time: prayerTimes["Dhuhr"] ?? "N/A", isDaytime: isDaytime)
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
        .onChange(of: viewModel.selectedCity) { _ in
            fetchPrayerTimes(city: viewModel.selectedCity)
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

        if let timings = dayData["timings"] as? [String: String] {
            self.prayerTimes = [
                "Fajr": sanitizeTime(timings["Fajr"] ?? "N/A"),
                "Sunrise": sanitizeTime(timings["Sunrise"] ?? "N/A"),
                "Dhuhr": sanitizeTime(timings["Dhuhr"] ?? "N/A"),
                "Asr": sanitizeTime(timings["Asr"] ?? "N/A"),
                "Maghrib": sanitizeTime(timings["Maghrib"] ?? "N/A")
            ]
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
    func sanitizeTime(_ time: String) -> String {
        return time.components(separatedBy: " ").first ?? time
    }

    func isFriday() -> Bool {
        // Get the weekday for the current date based on the day index
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        if let startOfMonth = calendar.date(from: components),
           let currentDay = calendar.date(byAdding: .day, value: currentDayIndex, to: startOfMonth) {
            return calendar.component(.weekday, from: currentDay) == 6  // 6 = Friday
        }
        return false
    }
}
