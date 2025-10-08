//import Foundation
//import Combine
//
//class CityViewModel: ObservableObject {
//    @Published var selectedCity: String {
//        didSet {
//            UserDefaults.standard.set(selectedCity, forKey: "selectedCity")
//        }
//    }
//    @Published var selectedCountry: String {
//        didSet {
//            UserDefaults.standard.set(selectedCountry, forKey: "selectedCountry")
//        }
//    }
//    @Published var selectedMosque: String {
//        didSet {
//            UserDefaults.standard.set(selectedMosque, forKey: "selectedMosque")
//        }
//    }
//    @Published var prayerTimes: [String: String] = [:]
//    @Published var readableDate: String = ""
//    @Published var isUsingLondonUnifiedTimetable = false
//    
//    @Published var isUsingMosqueTimetable: Bool {
//        didSet {
//            UserDefaults.standard.set(isUsingMosqueTimetable, forKey: "isUsingMosqueTimetable")
//        }
//    }
//
//
//    private var cancellables = Set<AnyCancellable>()
//    private let londonPrayerTimesAPI = "https://www.londonprayertimes.com/api/times/?format=json&key=f31cd22f-be6a-4410-bd20-cdd3b9923cff"
//
//    init() {
//        self.selectedCity = UserDefaults.standard.string(forKey: "selectedCity") ?? "Manchester"
//        self.selectedCountry = UserDefaults.standard.string(forKey: "selectedCountry") ?? "UK"
//        self.isUsingMosqueTimetable = UserDefaults.standard.bool(forKey: "useMosqueTimetable")
//        self.selectedMosque = UserDefaults.standard.string(forKey: "selectedMosque") ?? "Manchester Isoc"
//    }
//
//    // MARK: - Fetch Unified Timetable API
//    func fetchLondonUnifiedTimetable() {
//        let year = Calendar.current.component(.year, from: Date())
//        let month = Calendar.current.component(.month, from: Date())
//        let formattedMonth = String(format: "%02d", month)
//
//        guard let url = URL(string: "\(londonPrayerTimesAPI)&year=\(year)&month=\(formattedMonth)&24hours=true") else {
//            print("Invalid URL")
//            return
//        }
//
//        print("Fetching data from URL: \(url)")
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching London Unified Timetable: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data else {
//                print("No data returned from API")
//                return
//            }
//
//            // Debug: Print the raw JSON response
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Raw JSON Response: \(jsonString)")
//            }
//
//            do {
//                let decodedResponse = try JSONDecoder().decode(LondonPrayerTimesResponse.self, from: data)
//                let todayDateString = DateParser.getCurrentDateToString()
//                let dateKeys = decodedResponse.times.keys.sorted() // Get sorted date keys
//
//                // Extract today's prayer data
//                guard let todayPrayerData = decodedResponse.times[todayDateString] else {
//                    print("Error: Could not find today's prayer times.")
//                    return
//                }
//
//                // Extract next day's prayer data for calculations
//                let todayIndex = dateKeys.firstIndex(of: todayDateString) ?? 0
//                let nextDayIndex = dateKeys.index(after: todayIndex)
//                let nextDayDateString = nextDayIndex < dateKeys.count ? dateKeys[nextDayIndex] : todayDateString
//                let nextDayPrayerData = decodedResponse.times[nextDayDateString]
//
//                let maghribTime = todayPrayerData.magrib
//                let fajrTimeNextDay = nextDayPrayerData?.fajr ?? "00:00"
//
//                // Calculate Midnight and Last Third
//                let midnight = PrayerTimeCalculator.calculateMidnightTime(maghribTime: maghribTime, fajrTime: fajrTimeNextDay)
//                let lastThird = PrayerTimeCalculator.calculateLastThirdOfNight(maghribTime: maghribTime, fajrTime: fajrTimeNextDay)
//
//                DispatchQueue.main.async {
//                    self.prayerTimes = [
//                        "Isha": todayPrayerData.isha,
//                        "Midnight": midnight,
//                        "Lastthird": lastThird
//                    ]
//                    self.readableDate = todayDateString // Set the readable date as today's date
//                }
//
//            } catch {
//                print("Error decoding JSON response: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//}
//
