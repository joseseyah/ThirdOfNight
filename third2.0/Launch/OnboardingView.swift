import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""

    @State private var currentPageIndex: Int = 0  // Tracks the current page index

    var body: some View {
        TabView(selection: $currentPageIndex) {
            // First Page: App Icon with Animation
            AnimatedAppIconView(
                title: "As-salamu alaykum",
                description: "Welcome to your guide for seamless night prayers and Islamic reminders."
            )
            .tag(0)

            // Second Page: Midnight & Last Third
            OnboardingSlideView(
                title: "Midnight & Last Third",
                description: "Automatically calculate midnight and the last third of the night for your location.",
                imageName: "clock.arrow.circlepath",
                backgroundColor: Color("BoxBackgroundColor")
            )
            .tag(1)

            // Third Page: Tasbih
            OnboardingSlideView(
                title: "Tasbih Counter",
                description: "Keep track of your Dhikr with a counter for the 99 Names of Allah.",
                imageName: "hands.sparkles",
                backgroundColor: Color("HighlightColor")
            )
            .tag(2)

            // Fourth Page: Surah Mulk
            OnboardingSlideView(
                title: "Surah Mulk Before Sleep",
                description: """
                Recite Surah Al-Mulk before you sleep, as recommended by the Prophet Muhammad (ﷺ).
                You can read it in Arabic, English, or both to reflect on its beautiful meanings.
                """,
                imageName: "book.fill",
                backgroundColor: Color("HighlightColor")
            )
            .tag(3)

            // Fifth Page: Quran Listening
            OnboardingSlideView(
                title: "Listen to the Quran",
                description: "Enjoy listening to your favorite Surahs anytime.",
                imageName: "music.note.list",
                backgroundColor: Color("PageBackgroundColor")
            )
            .tag(4)

            // Sixth Page: Location Selection
            LocationSelectionView(
                onContinue: {
                    // Set default values if needed
                    if selectedCountry.isEmpty && selectedCity.isEmpty {
                        selectedCountry = "United Kingdom"
                        selectedCity = "London"
                    }
                    // Move to the next page
                    withAnimation {
                        currentPageIndex += 1
                    }
                }
            )
            .tag(5)

            // Last Page: Ready to Begin
            LastOnboardingSlide(
                title: "Ready to Begin?",
                buttonText: "Bismillah",
                action: {
                    hasSeenOnboarding = true
                }
            )
            .tag(6)
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
