import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    @State private var isSurahMulkExpanded = false
    @State private var fastingProgress: Double = 0.0
    @State private var midnightTime: String = ""
    @State private var lastThirdTime: String = ""
    @State private var fajrStartTime: String = ""
    @State private var currentTime: String = ""
    @State private var currentMarkerIndex: Int = 0
    @State private var isFastingInProgress: Bool = true
    @State private var totalFastingDuration: TimeInterval?

    @State private var isSettingsViewPresented = false
    @State private var isSurahMulkSheetPresented = false
    @State private var isBasicPrayerGuidancePresented = false
    @State private var isNamesOfAllahPresented = false
    @State private var isPrayerTimesPresented = false
    @State private var isQiblaDirectionPresented = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 40/255, blue: 70/255), Color(red: 0/255, green: 30/255, blue: 50/255)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        isSettingsViewPresented.toggle()
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                    }

                    VStack(alignment: .leading) {
                        
                        Text("Night Suplication")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.leading, 20)
                        
                        
                        Text(viewModel.islamicDate)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 150/255, green: 180/255, blue: 210/255))
                            .padding(.leading, 20)
                        
                        Text("\(viewModel.currentPlacemark?.administrativeArea ?? ""), \(viewModel.currentPlacemark?.country ?? "")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 150/255, green: 180/255, blue: 210/255))
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                
                .navigationBarHidden(true)
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            PrayerTimeView(title: "Fajr", time: viewModel.fajrTime)
                            PrayerTimeView(title: "Maghrib", time: viewModel.maghribTime)
                        }
                        .padding(.horizontal)
                        
                        if isFastingInProgress {
                            if let totalDuration = viewModel.calculateTotalFastingDuration() {
                                FastingProgressView(progress: fastingProgress, remainingTime: remainingTimeUntilIftar(), totalDuration: totalDuration)
                                    .padding(.horizontal, 20)
                            }
                        } else {
                            EatingProgressView(progress: eatingProgress(), remainingTime: remainingTimeUntilFajr())
                                .padding(.horizontal, 20)
                        }
                        
                        MidnightTimeView(midnightTime: viewModel.midnightTimeView)
                            .padding(.horizontal, 20)
                        
                        LastThirdOfNightView(lastThirdTime: viewModel.lastThirdView)
                            .padding(.horizontal, 20)



                        
                        CircularTimelineView(timings: ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"])
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            withAnimation {
                                isSurahMulkExpanded.toggle()
                            }
                        }) {
                            Text("Surah Al-Mulk Translation:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.leading, 20)
                        }
                    }
                }
            }
        }
            .sheet(isPresented: $isSettingsViewPresented) {
                SettingView()
            }
            .sheet(isPresented: $isSurahMulkExpanded) {
                SurahMulkPageView(isExpanded: $isSurahMulkExpanded)
            }
        
            .sheet(isPresented: $isBasicPrayerGuidancePresented) {
                BasicPrayerGuidance()
            }
            
            .sheet(isPresented: $isNamesOfAllahPresented) {
                NamesOfAllahView()
            }
        
            .sheet(isPresented: $isPrayerTimesPresented){
                DaytimePrayersView()
            }

            .onTapGesture {
                withAnimation {
                    isSurahMulkExpanded = false
                }
            }
            .onAppear {
                viewModel.requestPermission()
                calculateFastingProgress()
                
                updateCurrentTimeMarkerIndex()
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                updateProgressView()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            FloatingNavBar(
                prayerGuidanceAction: {
                    isBasicPrayerGuidancePresented.toggle()
                },
                namesOfAllahAction: {
                    isNamesOfAllahPresented.toggle()
                },
                prayerTimesAction: {
                    isPrayerTimesPresented.toggle()
                },
                qiblaDirectionAction: {
                    isQiblaDirectionPresented.toggle()
                }
            )

        }
    
    func calculateFastingProgress() {
        guard let fajrTime = Double(viewModel.fajrTime), let maghribTime = Double(viewModel.maghribTime) else {
            return
        }
        let currentTime = Date()
        let totalFastingDuration = maghribTime - fajrTime
        let elapsedFastingDuration = currentTime.timeIntervalSinceReferenceDate - fajrTime
        let progress = elapsedFastingDuration / totalFastingDuration
        self.fastingProgress = max(0.0, min(progress, 1.0))
    }
    
    func remainingTimeUntilIftar() -> String {
        guard let maghribTime = convertTimeStringToDecimal(viewModel.maghribTime) else {
            return "Error"
        }
        
        let currentTime = Date()
        let maghribDate = Calendar.current.date(bySettingHour: Int(maghribTime), minute: Int((maghribTime - floor(maghribTime)) * 60), second: 0, of: currentTime)!
        
        let remainingTimeInterval = maghribDate.timeIntervalSince(currentTime)
        
        let remainingHours = Int(remainingTimeInterval) / 3600
        let remainingMinutes = (Int(remainingTimeInterval) % 3600) / 60
        
        return String(format: "%02d:%02d", remainingHours, remainingMinutes)
    }
    
    func calculateLastThirdOfNight() {
        guard let fajrTime = convertTimeStringToDecimal(viewModel.fajrTimeNextDay),
              let maghribTime = convertTimeStringToDecimal(viewModel.maghribTime) else {
            print("Error: Unable to parse fajrTimeNextDay or maghribTime")
            return
        }
        
        print("Fajr Time Next Day:", fajrTime)
        print("Maghrib Time:", maghribTime)
        
        // Calculate the total night duration
        let nightDuration = 24.0 - maghribTime + fajrTime
        print("Night Duration:", nightDuration)
        
        // Calculate the start time of the last third of the night
        let lastThirdStartTimeDecimal = fajrTime - nightDuration / 3.0
        print("Last Third Start Time Decimal:", lastThirdStartTimeDecimal)
        
        // Convert the decimal time to hours and minutes
        let lastThirdHour = Int(lastThirdStartTimeDecimal)
        let lastThirdMinute = Int((lastThirdStartTimeDecimal - Double(lastThirdHour)) * 60)
        
        // Format the last third time as a string
        self.lastThirdTime = String(format: "%02d:%02d", lastThirdHour, lastThirdMinute)
        print("Last Third Time:", lastThirdTime)
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
    
    func updateCurrentTimeMarkerIndex() {
        let currentTimeDecimal = convertTimeStringToDecimal(currentTime) ?? 0.0
        var currentIndex = 0
        let timings = ["Sunset", "Midnight", "Last Third", "Fajr", "Sunrise"]
        for i in 0..<timings.count {
            if let time = convertTimeStringToDecimal(timings[i]) {
                if currentTimeDecimal < time {
                    currentIndex = i
                    break
                }
            }
        }
        self.currentMarkerIndex = currentIndex
    }
    
    func updateProgressView() {
        let currentTimeDecimal = convertTimeStringToDecimal(currentTime) ?? 0.0
        
        if currentMarkerIndex == 3 && currentTimeDecimal >= convertTimeStringToDecimal(viewModel.maghribTime) ?? 0.0 {
            isFastingInProgress = false
        }
    }
    
    func eatingProgress() -> Double {
        guard let fajrTime = Double(viewModel.fajrTime), let maghribTime = Double(viewModel.maghribTime) else {
            return 0.0
        }
        let currentTime = Date().timeIntervalSince1970
        let totalEatingDuration = fajrTime - maghribTime
        let elapsedEatingDuration = currentTime - maghribTime
        let progress = elapsedEatingDuration / totalEatingDuration
        return max(0.0, min(progress, 1.0))
    }
    
    func remainingTimeUntilFajr() -> String {
        guard let fajrTime = convertTimeStringToDecimal(viewModel.fajrTime) else {
            return "Error"
        }
        
        let currentTime = Date()
        let fajrDate = Calendar.current.date(bySettingHour: Int(fajrTime), minute: Int((fajrTime - floor(fajrTime)) * 60), second: 0, of: currentTime)!
        
        let remainingTimeInterval = fajrDate.timeIntervalSince(currentTime)
        
        let remainingHours = Int(remainingTimeInterval) / 3600
        let remainingMinutes = (Int(remainingTimeInterval) % 3600) / 60
        
        return String(format: "%02d:%02d", remainingHours, remainingMinutes)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

