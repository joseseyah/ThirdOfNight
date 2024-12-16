import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        TabView {
            // First Page: App Icon with Animation
            AnimatedAppIconView(
                title: "As-salamu alaykum",
                description: "Welcome to your guide for seamless night prayers and Islamic reminders."
            )

            // Second Page: Midnight & Last Third
            OnboardingSlideView(
                title: "Midnight & Last Third",
                description: "Automatically calculate midnight and the last third of the night for your location.",
                imageName: "clock.arrow.circlepath",
                backgroundColor: Color("BoxBackgroundColor")
            )

            // Third Page: Tasbih
            OnboardingSlideView(
                title: "Tasbih Counter",
                description: "Keep track of your Dhikr with a counter for the 99 Names of Allah.",
                imageName: "hands.sparkles",
                backgroundColor: Color("HighlightColor")
            )
            
            OnboardingSlideView(
                title: "Surah Mulk",
                description: """
                “Blessed is He in whose hand is the dominion, and He is over all things competent.”
                Surah Al-Mulk (سورة الملك)
                """,
                imageName: "book.fill", // Replace with a more appropriate symbol if needed
                backgroundColor: Color("HighlightColor")
            )


            // Fourth Page: Quran Listening
            OnboardingSlideView(
                title: "Listen to the Quran",
                description: "Enjoy listening to your favorite Surahs anytime.",
                imageName: "music.note.list",
                backgroundColor: Color("PageBackgroundColor")
            )

            // Last Page: Ready to Begin
            LastOnboardingSlide(
                title: "Ready to Begin?",
                buttonText: "Bismillah",
                action: {
                    hasSeenOnboarding = true
                }
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

// First Page with Animated App Icon
struct AnimatedAppIconView: View {
    let title: String
    let description: String

    @State private var rotateEffect: Double = 0

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated App Icon
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("BackgroundColor") // Matches the app icon's background
        )
        .ignoresSafeArea()
    }
}

// Generic Onboarding Slide View
struct OnboardingSlideView: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(Color("HighlightColor"))

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor, Color("BoxBackgroundColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

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

            Text("Tap below to explore all the features of the app and start your journey.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
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
