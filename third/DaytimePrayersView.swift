import SwiftUI

struct DaytimePrayersView: View {
    @ObservedObject private var viewModel = ContentViewModel()

    @State private var isSettingsViewPresented = false
    @State private var isSurahMulkSheetPresented = false
    @State private var isBasicPrayerGuidancePresented = false
    @State private var isNamesOfAllahPresented = false

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
                        Text("Daytime Prayers")
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        PrayerRowView(prayerName: "Fajr", prayerTime: "5:00")
                        PrayerRowView(prayerName: "Dhuhr", prayerTime: "12:30")
                        PrayerRowView(prayerName: "Asr", prayerTime: "15:45")
                        PrayerRowView(prayerName: "Maghrib", prayerTime: "18:20")
                        PrayerRowView(prayerName: "Isha", prayerTime: "20:00")
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isSettingsViewPresented) {
            SettingView()
        }
        .sheet(isPresented: $isBasicPrayerGuidancePresented) {
            BasicPrayerGuidance()
        }
        .sheet(isPresented: $isNamesOfAllahPresented) {
            NamesOfAllahView()
        }
        .onAppear {
            viewModel.requestPermission()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        FloatingNavBar(
            prayerGuidanceAction: {
                isBasicPrayerGuidancePresented.toggle()
            },
            namesOfAllahAction: {
                isNamesOfAllahPresented.toggle()
            }
        )
    }
}

struct PrayerRowView: View {
    var prayerName: String
    var prayerTime: String

    var body: some View {
        HStack {
            Text(prayerName)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.leading)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(prayerTime)
                .foregroundColor(.white)
                .font(.headline)
                .padding(.trailing)
                .frame(width: 100, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
    }
}
