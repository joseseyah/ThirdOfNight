import Foundation
import SwiftUI

struct DonationView: View {
    @Binding var showDonationOptions: Bool
    let shopURL = URL(string: "https://yourshopurl.com")! // Replace with your shop URL
    let koFiURL = URL(string: "https://ko-fi.com/josephhayes")! // Replace with your Ko-fi URL

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient with animation
                LinearGradient(gradient: Gradient(colors: [
                    Color(hex: "#0A1B3D"),
                    Color(hex: "#1C2A49"),
                    Color(hex: "#0A1B3D")
                ]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true))

                VStack(spacing: 40) {
                    // Header Section
                    VStack {
                        Text("🌙 Support Third of the Night")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#FDF3E7"))
                            .shadow(radius: 5)
                            .multilineTextAlignment(.center)
                        
                        Text("Your contribution helps us improve and bring value to more users!")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#FF9D66"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Shop Button (Coming Soon)
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#1C2A49"))
                            .shadow(color: Color(hex: "#FF9D66"), radius: 10, x: 0, y: 10)
                            .frame(height: 100)
                            .opacity(0.6) // Dimmed to indicate it's inactive
                        HStack {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Shop (Coming Soon)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Text("Buy hoodies & T-shirts to support us!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 10)
                        }
                    }

                    // Ko-fi Donate Button
                    Link(destination: koFiURL) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "#FF9D66"))
                                .shadow(color: Color(hex: "#FDF3E7"), radius: 10, x: 0, y: 10)
                                .frame(height: 100)
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Donate via Ko-fi")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Support us with one-time or monthly donations!")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#FDF3E7"))
                                }
                                .padding(.leading, 10)
                            }
                        }
                    }

                    // Charity/Zakat/Sadaqah Section (Coming Soon)
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#1C2A49"))
                            .shadow(color: Color(hex: "#FF9D66"), radius: 10, x: 0, y: 10)
                            .frame(height: 100)
                            .opacity(0.6) // Dimmed to indicate it's inactive
                        HStack {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Charity/Zakat/Sadaqah (Coming Soon)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Text("Contribute to those in need through verified charities.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.leading, 10)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                showDonationOptions = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color(hex: "#FDF3E7"))
            })
        }
    }
}
