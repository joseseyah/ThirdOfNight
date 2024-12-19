import SwiftUI

struct TasbihCounterView: View {
    @State private var count: Int = 0
    let target: Int = 99
    
    var body: some View {
        ZStack {
            // Background color matching your theme
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Title
                Text("Tasbih Counter")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PageBackgroundColor"))  // Light cream color for contrast
                    .padding()

                // Counter Display
                Text("\(count)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(Color("HighlightColor"))  // Orange accent for the number
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("BoxBackgroundColor"))  // Slightly lighter navy box
                                    .shadow(radius: 5)
                                )
                
                // Increment Button
                Button(action: incrementCounter) {
                    Text("Tap to Count")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("HighlightColor")))  // Orange button
                        .shadow(radius: 5)
                }
                .padding()

                // Reset Button
                Button(action: resetCounter) {
                    Text("Reset")
                        .font(.subheadline)
                        .foregroundColor(Color("HighlightColor"))  // Orange text for reset
                        .frame(width: 100, height: 40)
                        .background(RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("BoxBackgroundColor"), lineWidth: 2))  // Outline button
                        .padding()
                }
                
                // Optional: Display the goal
                Text("Goal: \(target)")
                    .font(.subheadline)
                    .foregroundColor(Color("PageBackgroundColor"))
                    .padding()
                
                Spacer()
            }
        }
    }

    // Increment counter
    func incrementCounter() {
        if count < target {
            count += 1
            provideHapticFeedback() // Add haptic feedback here
        }
    }
    
    // Reset counter
    func resetCounter() {
        count = 0
    }

    // Function for haptic feedback
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
