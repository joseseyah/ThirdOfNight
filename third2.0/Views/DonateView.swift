import Foundation
import SwiftUI

struct DonationView: View {
    @Binding var showDonationOptions: Bool
    let shopURL = URL(string: "https://yourshopurl.com")! // Replace with your shop URL
    let koFiURL = URL(string: "https://ko-fi.com/josephhayes")! // Replace with your Ko-fi URL
    @State private var showShareSheet = false

    @State private var animateShare = false

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
                    createButton(
                        text: "Shop (Coming Soon)",
                        subText: "Buy hoodies & T-shirts to support us!",
                        icon: "cart.fill",
                        isActive: false
                    )

                    // Ko-fi Donate Button
                    Link(destination: koFiURL) {
                        createButton(
                            text: "Donate via Ko-fi",
                            subText: "Support us with one-time or monthly donations!",
                            icon: "heart.fill",
                            isActive: true
                        )
                    }

                    // Charity/Zakat/Sadaqah Section (Coming Soon)
                    createButton(
                        text: "Charity/Zakat/Sadaqah (Coming Soon)",
                        subText: "Contribute to those in need through verified charities.",
                        icon: "hands.sparkles.fill",
                        isActive: false
                    )

                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button(action: {
                    showShareSheet = true // A new @State variable
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "#FDF3E7"))
                        Text("Share")
                            .foregroundColor(Color(hex: "#FDF3E7"))
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "#FF9D66").cornerRadius(12))
                    .shadow(color: Color(hex: "#FDF3E7"), radius: 5, x: 0, y: 5)
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [URL(string: "https://apps.apple.com/gb/app/third-of-the-night/id6483865746")!])
                }
            )

        }
    }

    func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/gb/app/third-of-the-night/id6483865746")! // Replace with your app's URL
        let activityVC = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)

        // Ensure the `rootViewController` is retrieved correctly
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // Present the Activity View Controller on the main thread
            DispatchQueue.main.async {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        } else {
            print("Failed to present UIActivityViewController. RootViewController not found.")
        }
    }



    // Helper to create button
    @ViewBuilder
    private func createButton(text: String, subText: String, icon: String, isActive: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isActive ? Color(hex: "#FF9D66") : Color(hex: "#1C2A49"))
                .shadow(color: isActive ? Color(hex: "#FDF3E7") : Color(hex: "#FF9D66"), radius: 10, x: 0, y: 10)
                .frame(height: 100)
                .opacity(isActive ? 1.0 : 0.6)
                .scaleEffect(isActive ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isActive)

            HStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isActive ? .white : .gray)
                VStack(alignment: .leading, spacing: 5) {
                    Text(text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white : .gray)
                    Text(subText)
                        .font(.subheadline)
                        .foregroundColor(isActive ? Color(hex: "#FDF3E7") : .gray)
                }
                .padding(.leading, 10)
            }
        }
        .padding(.horizontal)
    }
}
