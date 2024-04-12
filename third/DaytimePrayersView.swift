import SwiftUI

struct DaytimePrayersView: View {
    @ObservedObject private var viewModel = ContentViewModel()

    @State private var isBasicPrayerGuidancePresented = false
    @State private var isNamesOfAllahPresented = false
    @State private var isQiblaDirectionPresented = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 40/255, blue: 70/255), Color(red: 0/255, green: 30/255, blue: 50/255)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        PrayerRowView(prayerName: "Fajr", prayerTime: viewModel.fajrTime)
                        PrayerRowView(prayerName: "Dhuhr", prayerTime: viewModel.dhuhr)
                        PrayerRowView(prayerName: "Asr", prayerTime: viewModel.asr)
                        PrayerRowView(prayerName: "Maghrib", prayerTime: viewModel.maghribTime)
                        PrayerRowView(prayerName: "Isha", prayerTime: viewModel.isha)
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0/255, green: 40/255, blue: 70/255), Color(red: 0/255, green: 30/255, blue: 50/255)]), startPoint: .top, endPoint: .bottom)) // Apply gradient background
                    .cornerRadius(20) // Rounded corners
                    .padding(20) // Add padding around the prayer times
                }
                
                HStack(spacing: 20) {
                    VStack {
                        Text("Sunrise")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text(viewModel.sunrise)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0/255, green: 40/255, blue: 70/255))
                    .cornerRadius(10)
                    
                    VStack {
                        Text("Sunset")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text(viewModel.sunset)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0/255, green: 40/255, blue: 70/255))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.requestPermission()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
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
