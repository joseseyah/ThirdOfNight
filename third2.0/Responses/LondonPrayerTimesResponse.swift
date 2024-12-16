struct LondonPrayerTimesResponse: Decodable {
    let times: [String: Timings]
}

struct Timings: Decodable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let magrib: String
    let isha: String
}




