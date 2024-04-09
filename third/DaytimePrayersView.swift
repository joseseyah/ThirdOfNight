import SwiftUI

struct DaytimePrayersView: View {
    @ObservedObject private var viewModel = ContentViewModel()

    @State private var isBasicPrayerGuidancePresented = false
    @State private var isNamesOfAllahPresented = false
    @State private var isPrayerTimesSheetPresented = false
    @State private var isQiblaDirectionPresented = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 40/255, blue: 70/255), Color(red: 0/255, green: 30/255, blue: 50/255)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                ScrollView {
                    VStack(spacing: 20) {
                        PrayerRowView(prayerName: "Fajr", prayerTime: "5:00")
                        PrayerRowView(prayerName: "Dhuhr", prayerTime: "12:30")
                        PrayerRowView(prayerName: "Asr", prayerTime: "15:45")
                        PrayerRowView(prayerName: "Maghrib", prayerTime: "18:20")
                        PrayerRowView(prayerName: "Isha", prayerTime: "20:00")
                    }
                    .padding()
                    .background(Color.white.opacity(0.9)) // Semi-transparent white background
                    .cornerRadius(20) // Rounded corners
                    .padding(20) // Add padding around the prayer times
                }
                
                Spacer()
                
                FloatingNavBar(
                    prayerGuidanceAction: {
                        isBasicPrayerGuidancePresented.toggle()
                    },
                    namesOfAllahAction: {
                        isNamesOfAllahPresented.toggle()
                    },
                    prayerTimesAction: {
                        isPrayerTimesSheetPresented.toggle()
                    },
                    qiblaDirectionAction: {
                        isQiblaDirectionPresented.toggle()
                    }
                )
            }
        }
        .sheet(isPresented: $isBasicPrayerGuidancePresented) {
            BasicPrayerGuidance()
        }
        .sheet(isPresented: $isNamesOfAllahPresented) {
            NamesOfAllahView()
        }
        .sheet(isPresented: $isPrayerTimesSheetPresented) {
            PrayerTimesSheetView()
        }
        .onAppear {
            viewModel.requestPermission()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct PrayerTimesSheetView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Prayer Times")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0/255, green: 40/255, blue: 70/255)) // Title color
                    .padding(.bottom, 10) // Add spacing below the title
                
                Divider() // Divider
                
                // Add your prayer times here
                PrayerRowView(prayerName: "Fajr", prayerTime: "5:00")
                PrayerRowView(prayerName: "Dhuhr", prayerTime: "12:30")
                PrayerRowView(prayerName: "Asr", prayerTime: "15:45")
                PrayerRowView(prayerName: "Maghrib", prayerTime: "18:20")
                PrayerRowView(prayerName: "Isha", prayerTime: "20:00")
            }
            .padding()
            .background(Color.white.opacity(0.9)) // Semi-transparent white background
            .cornerRadius(20) // Rounded corners
            .padding(20) // Add padding around the prayer times
            .navigationTitle("Prayer Times") // Set navigation title
        }
    }
}


struct PrayerRowView: View {
    var prayerName: String
    var prayerTime: String

    var body: some View {
        HStack {
            Text(prayerName)
                .foregroundColor(Color(red: 0/255, green: 40/255, blue: 70/255)) // Text color
                .font(.headline)
                .padding(.leading)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(prayerTime)
                .foregroundColor(Color(red: 0/255, green: 40/255, blue: 70/255)) // Text color
                .font(.headline)
                .padding(.trailing)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.5)) // Semi-transparent white background
        .cornerRadius(10) // Rounded corners
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DaytimePrayersView()
    }
}
