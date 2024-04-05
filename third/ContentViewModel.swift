import SwiftUI
import CoreLocation
import UserNotifications

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var islamicDate: String = ""
    @Published var fajrTime: String = ""
    @Published var maghribTime: String = ""
    @Published var fajrTimeNextDay: String = "" // Fajr time for the next day
    @Published var midnightTimeView: String = "" // Middle of the night time
    
    //for location purpose
    private let locationManager: CLLocationManager
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?

    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }

    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
            
            self.fetchPrayerTimes()
        }
    }

    func getCurrentDateAndMonth() -> (year: Int, month: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Extract day and month components from the current date
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        return (year: year, month: month)
    }
    
    func extractTime(from timeString: String) -> String {
        return timeString.components(separatedBy: " ")[0] // Extracting only the time portion
    }
    
    func calculateTotalFastingDuration() -> TimeInterval? {
            guard let fajrTime = convertTimeStringToDecimal(fajrTime), let maghribTime = convertTimeStringToDecimal(maghribTime) else {
                return nil
            }
            return maghribTime - fajrTime
    }


    func fetchPrayerTimes() {
        //please get current year and current month
        let currentDateAndMonth = getCurrentDateAndMonth()
        
        let city = self.currentPlacemark?.administrativeArea ?? ""
        let country = self.currentPlacemark?.country ?? ""
        let method = 2 // Islamic Society of North America

        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity/\(currentDateAndMonth.year)/\(currentDateAndMonth.month)?city=\(city)&country=\(country)&method=\(method)") else {
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

                // Extract Islamic date, Fajr time, Maghrib time, and Midnight time from the response
                guard let firstData = calendarResponse.data.first else {
                    print("Error: Unable to extract data from response")
                    return
                }

                if let islamicDate = firstData.date.hijri,
                   let fajrTime = firstData.timings.fajr,
                   let maghribTime = firstData.timings.maghrib,
                   let midnightTime = firstData.timings.midnight {
                    DispatchQueue.main.async {
                        self.islamicDate = "\(islamicDate.getDisplayIslamicDate())"
                        self.fajrTime = self.extractTime(from: fajrTime)
                        self.maghribTime = self.extractTime(from: maghribTime)
                        self.midnightTimeView = self.extractTime(from: midnightTime)

                        // Schedule a notification 10 minutes before midnight
                        self.scheduleMidnightNotification(midnightTime: midnightTime)
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
    
    func convertTimeStringToDecimal(_ timeString: String) -> Double? {
            let components = timeString.components(separatedBy: ":")
            guard components.count == 2,
                  let hours = Double(components[0]),
                  let minutes = Double(components[1])
            else {
                return nil
            }
            return hours + (minutes / 60)
    }

    func scheduleMidnightNotification(midnightTime: String) {
        guard let midnightTimeDecimal = convertTimeStringToDecimal(midnightTime) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Midnight Reminder"
        content.body = "Midnight is approaching. Make sure you have completed Isha."

        // Calculate notification trigger time (10 minutes before midnight)
        let notificationTime = midnightTimeDecimal - (10.0 / 60.0) * 24.0
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = Int(notificationTime)
        dateComponents.minute = Int((notificationTime - Double(Int(notificationTime))) * 60)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "MidnightReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
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
    let midnight: String? // Add midnight property
    
    private enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case maghrib = "Maghrib"
        case midnight = "Midnight" // Map to the appropriate key in API response
    }
}

struct DateInfo: Codable {
    let hijri: HijriDate?
    // You can add more properties if needed
}

struct HijriDate: Codable {
    let date: String?
    let day: String?
    let month: HijriMonth?
    let year: String?
    let designation: Designation?
    
    func getDisplayIslamicDate() -> String {
        return "\(day ?? "") \(month?.en ?? "") \(year ?? "") \(designation?.abbreviated ?? "")"
    }
}

struct Designation: Codable {
    let abbreviated: String?
}

struct HijriMonth: Codable {
    let number: Int?
    let en: String?
}

