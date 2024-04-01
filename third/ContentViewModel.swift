import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var islamicDate: String = "1 Ramadan 1445AH"
    @Published var fajrTime: String = "4.12"
    @Published var maghribTime: String = "18.41"
    @Published var fajrTimeNextDay: String = "4.09" // Fajr time for the next day

    init() {
        fetchPrayerTimes()
    }

    func fetchPrayerTimes() {
        let city = "London"
        let country = "United Kingdom"
        let method = 2 // Islamic Society of North America

        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity?city=\(city)&country=\(country)&method=\(method)") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching prayer times:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decoder = JSONDecoder()
                let calendarResponse = try decoder.decode(CalendarResponse.self, from: data)

                // Extract Islamic date, Fajr time, and Maghrib time from the response
                guard let firstData = calendarResponse.data.first else {
                    print("Error: Unable to extract data from response")
                    return
                }

                if let islamicDate = firstData.date.hijri?.date,
                   let fajrTime = firstData.timings.fajr,
                   let maghribTime = firstData.timings.maghrib {
                    DispatchQueue.main.async {
                        self.islamicDate = islamicDate
                        self.fajrTime = fajrTime
                        self.maghribTime = maghribTime

                        // Calculate Fajr time for the next day
                        self.calculateFajrTimeNextDay()
                    }
                } else {
                    print("Error: Prayer timings not found in response")
                }
            } catch {
                print("Error decoding calendar response:", error)
            }
        }

        task.resume()
    }

    func calculateFajrTimeNextDay() {
        guard let fajrTimeDouble = Double(fajrTime) else {
            return
        }
        // Assuming Fajr time is before sunrise and after Maghrib
        // Add a fixed duration to calculate Fajr time for the next day
        let fajrTimeNextDayDouble = fajrTimeDouble + 12 // Assuming Fajr is 12 hours before Maghrib
        self.fajrTimeNextDay = String(format: "%.2f", fajrTimeNextDayDouble)
    }
}

struct CalendarResponse: Codable {
    let data: [PrayerTimeData]
}

struct PrayerTimeData: Codable {
    let timings: PrayerTimings
    let date: DateInfo
}

struct PrayerTimings: Codable {
    let fajr: String?
    let maghrib: String?
    // Add other prayer timings as needed
}

struct DateInfo: Codable {
    let hijri: HijriDate?
    // You can add more properties if needed
}

struct HijriDate: Codable {
    let date: String?
}
