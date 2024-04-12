import SwiftUI
import CoreLocation
import UserNotifications

class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var islamicDate: String = ""
    @Published var fajrTime: String = ""
    @Published var maghribTime: String = ""
    @Published var fajrTimeNextDay: String = "" // Fajr time for the next day
    @Published var midnightTimeView: String = "" // Middle of the night time
    @Published var lastThirdView: String = ""
    
    @Published var dhuhr: String = ""
    @Published var asr: String = ""
    @Published var isha: String = ""
    
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

    func getCurrentDateAndMonth() -> (year: Int, month: Int, day: Int) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Extract day and month components from the current date
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        
        return (year: year, month: month, day: day)
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
    func calculateTotalNightDuration() -> TimeInterval? {
        guard let fajrTimeDecimal = convertTimeStringToDecimal(fajrTimeNextDay),
              let maghribTimeDecimal = convertTimeStringToDecimal(maghribTime) else {
            return nil
        }
        return maghribTimeDecimal - fajrTimeDecimal
    }


    
    func calculate1Third() -> String? {
        guard let totalDuration = calculateTotalNightDuration() else {
            return nil
        }
        print(totalDuration)
        let oneThirdDuration = totalDuration / 3
        let oneThirdTimeString = formatTimeInterval(timeInterval: oneThirdDuration)
        
        return addTimeStrings(timeString1: oneThirdTimeString, timeString2: maghribTime)
    }




    func formatTimeInterval(timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval)!
    }

    func addTimeStrings(timeString1: String, timeString2: String) -> String {
        let time1Components = timeString1.split(separator: ":").compactMap { Int($0) }
        let time2Components = timeString2.split(separator: ":").compactMap { Int($0) }

        let hours = time1Components[0] + time2Components[0]
        let minutes = time1Components[1] + time2Components[1]

        let correctedHours = hours + (minutes / 60)
        let correctedMinutes = minutes % 60

        return String(format: "%02d:%02d", correctedHours, correctedMinutes)
    }

    


    func fetchPrayerTimes() {
        //please get current year and current month
        let currentDateAndMonth = getCurrentDateAndMonth()
        
        let city = self.currentPlacemark?.administrativeArea ?? ""
        let country = self.currentPlacemark?.country ?? ""
        let method = 15 // Islamic Society of North America
        
        let currentDay = currentDateAndMonth.day
        let currentDayString = String(format: "%02d", currentDay)

        guard let url = URL(string: "https://api.aladhan.com/v1/calendarByCity/\(currentDateAndMonth.year)/\(currentDateAndMonth.month)?city=\(city)&country=\(country)&method=\(method)") else {
            return
        }

        print("https://api.aladhan.com/v1/calendarByCity/\(currentDateAndMonth.year)/\(currentDateAndMonth.month)?city=\(city)&country=\(country)&method=\(method)")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching prayer times:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let decoder = JSONDecoder()
                let calendarResponse = try decoder.decode(CalendarResponse.self, from: data)
                
                var arrayIndexToUse = 0
                let dataArray: [PrayerTimeData] = calendarResponse.data ?? [PrayerTimeData]()
                for (index, response) in dataArray.enumerated() {
                    if response.date.gregorian?.day ?? "0" == currentDayString {
                        arrayIndexToUse = index
                        break
                    }
                }
                let todayData = dataArray[arrayIndexToUse]

                if let fajrTime = todayData.timings.fajr,
                   let dhuhrTime = todayData.timings.dhuhr,
                   let asrTime = todayData.timings.asr,
                   let maghribTime = todayData.timings.maghrib,
                   let ishaTime = todayData.timings.isha {

                    // Extract and store prayer times for display in your app
                    DispatchQueue.main.async {
                        self.fajrTime = self.extractTime(from: fajrTime)
                        self.dhuhr = self.extractTime(from: dhuhrTime)
                        self.asr = self.extractTime(from: asrTime)
                        self.maghribTime = self.extractTime(from: maghribTime)
                        self.isha = self.extractTime(from: ishaTime)
                    }
                    
                    // Schedule notifications for each prayer time
                    self.schedulePrayerNotification(prayerTime: fajrTime, title: "Fajr Prayer Reminder", body: "It's almost time for Fajr prayer. Make sure you have Wudu.")
                    self.schedulePrayerNotification(prayerTime: dhuhrTime, title: "Dhuhr Prayer Reminder", body: "It's almost time for Dhuhr prayer. Make sure you have Wudu.")
                    self.schedulePrayerNotification(prayerTime: asrTime, title: "Asr Prayer Reminder", body: "It's almost time for Asr prayer. Make sure you have Wudu.")
                    self.schedulePrayerNotification(prayerTime: maghribTime, title: "Maghrib Prayer Reminder", body: "It's almost time for Maghrib prayer. Make sure you have Wudu.")
                    self.schedulePrayerNotification(prayerTime: ishaTime, title: "Isha Prayer Reminder", body: "It's almost time for Isha prayer. Make sure you have Wudu.")
                } else {
                    print("Error: Prayer timings not found in response")
                }
            } catch {
                print("Error decoding calendar response:", error)
            }
        }

        task.resume()
    }

    func schedulePrayerNotification(prayerTime: String, title: String, body: String) {
        guard let prayerTimeDecimal = convertTimeStringToDecimal(prayerTime) else { return }

        // Calculate notification trigger time (10 minutes before prayer time)
        let notificationTime = prayerTimeDecimal - (10.0 / 60.0)
        
        // Check if notification for this prayer time has already been scheduled
        let notificationIdentifier = "PrayerReminder_\(prayerTime)"
        if UserDefaults.standard.bool(forKey: notificationIdentifier) {
            print("Notification for \(prayerTime) already scheduled")
            return
        }

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = Int(notificationTime)
        dateComponents.minute = Int((notificationTime - Double(Int(notificationTime))) * 60)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling prayer notification: \(error.localizedDescription)")
            } else {
                print("Prayer notification for \(prayerTime) scheduled successfully")
                // Store flag indicating notification has been scheduled for this prayer time
                UserDefaults.standard.set(true, forKey: notificationIdentifier)
            }
        }
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

        let notificationIdentifier = "MidnightReminder"
        
        // Check if notification is already scheduled
        if UserDefaults.standard.bool(forKey: notificationIdentifier) {
            print("Notification already scheduled")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Midnight Reminder"
        content.body = "Midnight is approaching. Make sure you have completed Isha."

        // Calculate notification trigger time (10 minutes before midnight)
        let notificationTime = midnightTimeDecimal - (10.0 / 60.0) * 24.0
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        dateComponents.hour = Int(notificationTime)
        dateComponents.minute = Int((notificationTime - Double(Int(notificationTime))) * 60)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
                // Store flag indicating notification has been scheduled
                UserDefaults.standard.set(true, forKey: notificationIdentifier)
            }
        }
    }

}

struct CalendarResponse: Codable {
    let data: [PrayerTimeData]?
}

struct PrayerTimeData: Codable {
    let timings: PrayerTimings
    let date: DateInfo
}

struct PrayerTimings: Codable {
    let fajr: String?
    let maghrib: String?
    let midnight: String?
    let dhuhr: String?
    let asr: String?
    let isha:String?
    
    private enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case maghrib = "Maghrib"
        case midnight = "Midnight"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case isha = "Isha"
    }
}

struct DateInfo: Codable {
    let hijri: HijriDate?
    let gregorian: Gregorian?
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

struct Gregorian: Codable {
    let day: String?
}

struct HijriMonth: Codable {
    let number: Int?
    let en: String?
}

extension Data
{
    func printJSON()
    {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8)
        {
            print(JSONString)
        }
    }
}

