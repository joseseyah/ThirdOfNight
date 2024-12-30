import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("selectedCountry") private var selectedCountry: String = ""
    @AppStorage("selectedCity") private var selectedCity: String = ""
    @AppStorage("selectedMosque") private var selectedMosque: String = ""
    
    @State private var useMosqueTimetable: Bool = false

    @State private var currentPageIndex: Int = 0  // Tracks the current page index

    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                AnimatedAppIconView(
                    title: "As-salamu alaykum",
                    description: "Welcome to your guide for seamless night prayers and Islamic reminders.",
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 1 {
                OnboardingSlideView(
                    title: "Midnight & Last Third",
                    description: "Automatically calculate midnight and the last third of the night for your location.",
                    imageName: "clock.arrow.circlepath",
                    backgroundColor: Color("BoxBackgroundColor"),
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 2 {
                OnboardingSlideView(
                    title: "Tasbih Counter",
                    description: "Keep track of your Dhikr with a counter for the 99 Names of Allah.",
                    imageName: "hands.sparkles",
                    backgroundColor: Color("HighlightColor"),
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 3 {
                OnboardingSlideView(
                    title: "Surah Mulk Before Sleep",
                    description: """
                    Recite Surah Al-Mulk before you sleep, as recommended by the Prophet Muhammad (ﷺ).
                    You can read it in Arabic, English, or both to reflect on its beautiful meanings.
                    """,
                    imageName: "book.fill",
                    backgroundColor: Color("HighlightColor"),
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 4 {
                OnboardingSlideView(
                    title: "Listen to the Quran",
                    description: "Enjoy listening to your favorite Surahs anytime.",
                    imageName: "music.note.list",
                    backgroundColor: Color("PageBackgroundColor"),
                    onNext: { currentPageIndex += 1 }
                )
            } else if currentPageIndex == 5 {
                LocationSelectionView(
                    useMosqueTimetable: $useMosqueTimetable,  // Pass the state as a binding
                    onContinue: {
                        if useMosqueTimetable {
                            if !selectedMosque.isEmpty {
                                currentPageIndex += 1
                            }
                        } else {
                            if !selectedCountry.isEmpty && !selectedCity.isEmpty {
                                currentPageIndex += 1
                            }
                        }
                    }
                )
            } else if currentPageIndex == 6 {
                LastOnboardingSlide(
                    title: "Ready to Begin?",
                    buttonText: "Bismillah",
                    action: {
                        hasSeenOnboarding = true
                    }
                )
            }
        }
        .transition(.slide)
        .animation(.easeInOut, value: currentPageIndex)
        .ignoresSafeArea()
    }
}

// Updated OnboardingSlideView with Navigation
struct OnboardingSlideView: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    let onNext: () -> Void  // Navigation callback

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
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor, Color("BoxBackgroundColor")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
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
