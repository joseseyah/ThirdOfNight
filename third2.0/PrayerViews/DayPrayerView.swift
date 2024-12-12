import SwiftUI
import FirebaseFirestore

struct DayPrayerView: View {
    @ObservedObject var viewModel: CityViewModel
    @State private var prayerTimes: [String: String] = [:]  // Dynamic prayer times
    @Binding var isDaytime: Bool  // Bind the toggle to switch back to night mode
    @Binding var moonScale: CGFloat  // Reuse moonScale to animate the sun

    var body: some View {
        ZStack {
            // Daytime color background
            Color("DayBackgroundColor")
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Pulsating Sun, same position and size as the moon
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                    .scaleEffect(moonScale)  // Apply the same pulsating effect as the moon
                    .onAppear {
                        // Start the pulsating sun animation
                        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            moonScale = 1.2  // Same scale effect as the moon
                        }
                    }
                    .onTapGesture {
                        // Toggle back to night mode when the sun is pressed
                        withAnimation(.easeInOut) {
                            isDaytime.toggle()
                        }
                    }

                // Top bar with city name only
                VStack {
                    Text(viewModel.selectedCity)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                }
                .padding(.top, 20)  // Reduce padding to move city name higher

                // Display prayer times in boxes
                if prayerTimes.isEmpty {
                    Text("Loading prayer times...")
                        .foregroundColor(.black)
                        .font(.title)
                        .padding()
                } else {
                    VStack(spacing: 16) {  // Adjust spacing between the time boxes
                        TimeBox(title: "Fajr", time: prayerTimes["Fajr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Sunrise", time: prayerTimes["Sunrise"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Dhuhr", time: prayerTimes["Dhuhr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Asr", time: prayerTimes["Asr"] ?? "N/A", isDaytime: isDaytime)
                        TimeBox(title: "Maghrib", time: prayerTimes["Maghrib"] ?? "N/A", isDaytime: isDaytime)
                    }
                }

                Spacer()  // Keep the Spacer here to push everything upwards
            }
            .padding()
        }
        .onAppear {
            // Fetch prayer times for the selected city
            fetchPrayerTimes(city: viewModel.selectedCity)
        }
        .onChange(of: viewModel.selectedCity) { newCity in
            fetchPrayerTimes(city: newCity)
        }
    }

    // Fetch prayer times for the selected city from Firestore
    func fetchPrayerTimes(city: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("prayerTimes").document(city)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let prayerData = document.data()?["prayerTimes"] as? [[String: Any]] {
                    let currentDay = Calendar.current.component(.day, from: Date())
                    
                    if currentDay <= prayerData.count {
                        let dayData = prayerData[currentDay - 1]
                        
                        if let timings = dayData["timings"] as? [String: String] {
                            // Remove timezones and keep only HH:mm format
                            self.prayerTimes = [
                                "Fajr": sanitizeTime(timings["Fajr"] ?? "N/A"),
                                "Sunrise": sanitizeTime(timings["Sunrise"] ?? "N/A"),
                                "Dhuhr": sanitizeTime(timings["Dhuhr"] ?? "N/A"),
                                "Asr": sanitizeTime(timings["Asr"] ?? "N/A"),
                                "Maghrib": sanitizeTime(timings["Maghrib"] ?? "N/A")
                            ]
                        }
                    } else {
                        print("Day index out of range for \(city).")
                        self.prayerTimes = ["Error": "Prayer times not available."]
                    }
                } else {
                    print("Prayer times not available for \(city).")
                    self.prayerTimes = ["Error": "Prayer times not available."]
                }
            } else {
                print("Document does not exist for \(city): \(error?.localizedDescription ?? "Unknown error")")
                self.prayerTimes = ["Error": "City not found in Firestore."]
            }
        }
    }

    
    func sanitizeTime(_ time: String) -> String {
        // Extract only the "HH:mm" part, ignoring any timezone or extra text
        return time.components(separatedBy: " ").first ?? time
    }

}
