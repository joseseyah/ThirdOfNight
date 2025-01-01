import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPageIndex: Int = 0

    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                AnimatedAppIconView(
                    title: "As-salamu alaykum",
                    description: "Welcome to your guide for seamless night prayers and Islamic reminders.",
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 1 {
                FullScreenImageGallery(
                    images: [
                        "file (8)",
                        "file (4)",
                        "file (1)",
                        "file (2)",
                        "file (3)",
                        "file (6)",
                        "onboard",
                        "file (10)",
                    ],
                    onFinish: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 2 {
                LastOnboardingSlide(
                    title: "Ready to Begin?",
                    buttonText: "Bismillah",
                    action: {
                        hasSeenOnboarding = true
                    }
                )
            }
        }
        .animation(.easeInOut, value: currentPageIndex)
        .ignoresSafeArea()
    }
}

struct FullScreenImageGallery: View {
    let images: [String]
    let onFinish: () -> Void

    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            // Fullscreen Image Gallery
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(edges: .all) // Ensures the image covers the entire screen
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea()

            // Navigation Arrows
            HStack {
                // Left Arrow
                if currentIndex > 0 {
                    Button(action: {
                        withAnimation {
                            currentIndex -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                } else {
                    Spacer().frame(width: 40) // Placeholder to keep spacing consistent
                }

                Spacer()

                // Right Arrow
                if currentIndex < images.count - 1 {
                    Button(action: {
                        withAnimation {
                            currentIndex += 1
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                } else {
                    // Replace "Next" action with onFinish for the last page
                    Button(action: {
                        onFinish()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green.opacity(0.8))
                            .padding()
                    }
                }
            }
            .padding()
        }
    }
}





// Updated AnimatedAppIconView with Navigation
struct AnimatedAppIconView: View {
    let title: String
    let description: String
    let onNext: () -> Void  // Navigation callback

    @State private var rotateEffect: Double = 0

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image("AppIconImage") // Replace with your icon asset name
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .rotationEffect(.degrees(rotateEffect))
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        rotateEffect = 10
                    }
                }

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 40)

            Spacer()

            Button(action: onNext) {
                Text("Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("HighlightColor"), Color("BoxBackgroundColor")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("BackgroundColor") // Matches the app icon's background
        )
        .ignoresSafeArea()
    }
}


// Last Page View
// Last Page View
struct LastOnboardingSlide: View {
    let title: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Image(systemName: "hands.sparkles.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(Color("HighlightColor"))

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("""
                Welcome to the app! Your location is currently set to Manchester, and you'll see prayer times based on this city.
                
                You can update your location anytime in the settings page to view prayer times for your preferred city or mosque.
                
                Tap the button below to start exploring the app and enjoy its features!
                """)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: action) {
                Text(buttonText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color("HighlightColor"), Color("BoxBackgroundColor")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("PageBackgroundColor"), Color("BackgroundColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

