import SwiftUI

struct FastingProgressView: View {
    let progress: Double
    let remainingTime: String // Time remaining until Iftar
    let totalDuration: TimeInterval // Total fasting duration

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Progress Left till Iftar")
                    .font(.caption)
                    .foregroundColor(.white) // Adjusted to match the new color theme
                    .padding(.leading, 20)
                Spacer()
                Text("Time Left: \(remainingTime)")
                    .font(.caption)
                    .foregroundColor(.white) // Adjusted to match the new color theme
                    .padding(.trailing, 20)
            }

            // Progress bar with custom styling
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(progressColor(progress)) // Fill color based on progress
                    .frame(height: 10)
                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white)
                        .frame(width: CGFloat(progress * self.getWidth(proxy: proxy)), height: 10)
                } // Adjust width based on progress
            }
            .frame(height: 10)
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(red: 26/255, green: 25/255, blue: 28/255),
                        Color(red: 101/255, green: 126/255, blue: 154/255)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        ) // Adjusted background to match the new color theme
        .cornerRadius(15)
    }

    // Function to calculate progress bar color based on progress
    private func progressColor(_ progress: Double) -> Color {
        let blue = Color(red: 0/255, green: 121/255, blue: 153/255)
        let white = Color.white
        return progress == 1.0 ? white : blue
    }
}

struct FastingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        FastingProgressView(progress: 0.5, remainingTime: "00:40", totalDuration: 13.84)
    }
}

extension View{
    func getScreenBounds() -> CGRect{
        return UIScreen.main.bounds
    }
    
    func getWidth(proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width
    }
}

