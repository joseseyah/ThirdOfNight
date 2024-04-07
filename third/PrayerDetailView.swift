import SwiftUI

struct PrayerDetailView: View {
    var prayer: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(prayer == "Voluntary" ? "Voluntary Prayer" : "Obligatory Prayers")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0/255, green: 150/255, blue: 255/255)) // Adjust color to match your app's theme
            
            Text(prayer)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if prayer == "Voluntary" {
                Text("Perform 2 rakats to pray at night to have a conversation with Allah, to complain about yourself. Do it in the dark, where nobody can see or hear you but Allah.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                CircleNumberView(number: fardRakats(for: prayer), label: "Fard Rakats")
                
                Text(importanceDescription(for: prayer))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // Center-align the description
                
                HStack {
                    CircleNumberView(number: sunnahBeforeRakats(for: prayer), label: "Sunnah Before")
                    CircleNumberView(number: sunnahAfterRakats(for: prayer), label: "Sunnah After")
                }
                
                if prayer == "Isha" {
                    CircleNumberView(number: "Odd", label: "Witr")
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black) // Adjust color to match your app's theme
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func sunnahBeforeRakats(for prayer: String) -> String {
        switch prayer {
        case "Fajr":
            return "2"
        case "Dhuhr":
            return "2 or 4"
        case "Asr":
            return "0 or 2"
        case "Maghrib":
            return "2"
        case "Isha":
            return "0 or 2"
        default:
            return ""
        }
    }
    
    func fardRakats(for prayer: String) -> String {
        switch prayer {
        case "Fajr":
            return "2"
        case "Dhuhr":
            return "4"
        case "Asr":
            return "4"
        case "Maghrib":
            return "3"
        case "Isha":
            return "4"
        default:
            return ""
        }
    }
    
    func sunnahAfterRakats(for prayer: String) -> String {
        switch prayer {
        case "Fajr":
            return "None"
        case "Dhuhr":
            return "2"
        case "Asr":
            return "None"
        case "Maghrib":
            return "2"
        case "Isha":
            return "2"
        default:
            return ""
        }
    }
    
    func importanceDescription(for prayer: String) -> String {
        switch prayer {
        case "Fajr":
            return "Fajr prayer is of great importance as it marks the beginning of the day and is a means of seeking Allah's blessings."
        case "Dhuhr":
            return "Dhuhr prayer holds significance as it serves as a break during the day to remember Allah and seek guidance."
        case "Asr":
            return "Asr prayer is crucial as it reminds us to pause from our worldly affairs and turn towards Allah for guidance."
        case "Maghrib":
            return "Maghrib prayer holds importance as it marks the end of the day and is a time for reflection and gratitude."
        case "Isha":
            return "Isha prayer is vital as it marks the end of the day and is an opportunity to seek forgiveness and blessings from Allah."
        default:
            return ""
        }
    }
}

struct CircleNumberView: View {
    var number: String
    var label: String
    
    var body: some View {
        VStack {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue) // Adjust color as needed
                .overlay(
                    Text(number)
                        .foregroundColor(.white)
                        .font(.headline)
                )
            Text(label)
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}

struct PrayerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerDetailView(prayer: "Voluntary")
    }
}

