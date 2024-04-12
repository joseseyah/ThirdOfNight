import SwiftUI

struct MidnightTimeView: View {
    let midnightTime: String
    @State private var isShowing = false // State variable to toggle animation

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Midnight Occurs")
                    .font(.caption)
                    .foregroundColor(Color.white) // Changed text color to white
                    .padding(.leading, 20)
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 70)
                .overlay(
                    Text(midnightTime)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.black)
                )
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                .scaleEffect(isShowing ? 1.0 : 0.5)
                .onAppear {
                    withAnimation(.spring()) { // Apply spring animation effect
                        self.isShowing = true // Toggle animation when view appears
                    }
                }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            VStack {
                Spacer()
                AnimatedMountainView()
            }
        )
        .cornerRadius(15)
    }
}

struct AnimatedMountainView: View {
    @State private var mountainOffset: CGFloat = -200 // Initial mountain offset

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 101/255, green: 126/255, blue: 154/255), Color(red: 26/255, green: 25/255, blue: 28/255)]), startPoint: .top, endPoint: .bottom) // Flipped gradient
                .edgesIgnoringSafeArea(.all)
            
            Image("animated_mountain")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: UIScreen.main.bounds.height / 2) // Adjust mountain height as needed
                .offset(x: mountainOffset, y: 0) // Initial offset
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                self.mountainOffset = UIScreen.main.bounds.width + 200 // Final offset position (off-screen)
            }
        }
    }
}

