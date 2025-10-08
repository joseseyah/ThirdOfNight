//import SwiftUI
//
//struct TasbihCounterView: View {
//    @State private var count: Int = 0
//    let target: Int = 99
//
//    var body: some View {
//        ZStack {
//            // Background color
//            Color("BackgroundColor") // Replace with your defined color in Assets
//                .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 20) {
//                // Decorative Arch at the Top
//                RoundedRectangle(cornerRadius: 50)
//                    .fill(Color("BoxBackgroundColor").opacity(0.9))
//                    .frame(width: 250, height: 150)
//                    .overlay(
//                        VStack {
//                            Image(systemName: "star.fill")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(Color("HighlightColor"))
//                            Text("Tasbih Counter")
//                                .font(.title)
//                                .fontWeight(.semibold)
//                                .foregroundColor(Color("PageBackgroundColor"))
//                        }
//                    )
//
//                // Counter Display
//                Text("\(count)")
//                    .font(.system(size: 80, weight: .bold, design: .rounded))
//                    .foregroundColor(Color("HighlightColor"))
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 30)
//                            .fill(Color("BoxBackgroundColor"))
//                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
//                    )
//                    .scaleEffect(count % 10 == 0 && count != 0 ? 1.2 : 1.0) // Pulse animation
//                    .animation(.spring(), value: count)
//
//                // Increment Button
//                Button(action: incrementCounter) {
//                    Text("Tap to Count")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            LinearGradient(gradient: Gradient(colors: [Color("HighlightColor"), Color("HighlightColor").opacity(0.8)]), startPoint: .top, endPoint: .bottom)
//                                .cornerRadius(20)
//                                .shadow(radius: 5)
//                        )
//                }
//                .padding()
//
//                // Reset Button
//                Button(action: resetCounter) {
//                    Text("Reset")
//                        .font(.subheadline)
//                        .foregroundColor(Color("HighlightColor"))
//                        .padding()
//                        .frame(maxWidth: 150)
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color("BoxBackgroundColor"), lineWidth: 2)
//                        )
//                        .padding()
//                }
//
//                // Optional: Display the goal
//                Text("Goal: \(target)")
//                    .font(.subheadline)
//                    .foregroundColor(Color("PageBackgroundColor"))
//            }
//            .padding()
//        }
//    }
//
//    // Increment counter
//    func incrementCounter() {
//        if count < target {
//            count += 1
//            provideHapticFeedback()
//        }
//    }
//
//    // Reset counter
//    func resetCounter() {
//        count = 0
//    }
//
//    // Function for haptic feedback
//    private func provideHapticFeedback() {
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//    }
//}
