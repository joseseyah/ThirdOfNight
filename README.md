# Third of the Night App

The **Third of the Night** app is designed to assist users in tracking prayer times, including the specific Midnight and Last Third of the Night times, for selected cities. It features a clean, privacy-focused, ad-free user experience with beautiful night and day themes, along with various functionalities tailored for Muslims around the world.

## Features

- **Accurate Prayer Times**: Fetches and displays prayer times for specific cities.
- **Night and Day Modes**: Transition between night and day themes with animations.
- **City Picker**: Choose cities for prayer times with a highlighted box design.
- **Qibla Direction**: Guidance for the direction of prayer.
- **Tasbih Counter**: Keep track of your dhikr.
- **Surah Mulk Reader**: Read Surah Mulk before sleeping.
- **Privacy-Focused**: Ad-free experience with no unnecessary data collection.
- **Launch Storyboard**: Overview of app features on startup.
- **Quran Listening Feature**: Listen to Surahs from the Quran.

## Tech Stack

- **Language**: Swift
- **Framework**: SwiftUI
- **Database**: Firebase Firestore
- **Tools**: Xcode

## Setup Instructions

### Prerequisites
1. **Mac Computer**: Ensure you are using macOS.
2. **Xcode**: Download and install Xcode from the Mac App Store.
3. **Firebase Account**: Create a Firebase account and set up a project for the app.

### Firebase Setup
1. Go to [Firebase Console](https://firebase.google.com/).
2. Create a new project.
3. Add an iOS app to your project and download the `GoogleService-Info.plist` file.
4. Add the `GoogleService-Info.plist` file to the app's root directory in Xcode.
5. Enable Firestore Database in your Firebase project.

### Code Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/third-of-the-night.git
   ```
2. Open the `.xcodeproj` file in Xcode.
3. Install CocoaPods dependencies (if any):
   ```bash
   cd third-of-the-night
   pod install
   ```

### Running the App
1. Open the project in Xcode.
2. Select your target device (e.g., iPhone 14 emulator) from the top bar.
3. Press **Cmd + R** or click the **Run** button to build and run the app.

### Emulator Setup
1. Open Xcode and go to **Preferences > Locations** to ensure the Command Line Tools path is set.
2. Click on **Window > Devices and Simulators** to view the list of available simulators.
3. Add a new simulator if necessary, or select an existing one.
4. Run the app to see it in the emulator.

### Testing on a Physical Device
1. Connect your iPhone to your Mac.
2. In Xcode, go to **Signing & Capabilities** and add your Apple ID as a team.
3. Ensure your device is trusted and select it as the target device.
4. Build and run the app on your physical device.

## Key Files

### `ContentView.swift`
The primary user interface file displaying the app's home view.

### `PrayerView.swift`
Displays the prayer times fetched from Firebase Firestore, including 'Midnight' and 'Last Third' times.

### `SettingsView.swift`
Allows users to customize the app's behavior, including location selection and privacy preferences.

### `FirebaseManager.swift`
Handles Firebase interactions, including fetching and storing prayer times.

### `LaunchStoryboard.swift`
Displays a walkthrough of the app's features when launched for the first time.

## Contributing
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Make changes and commit:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push changes and create a pull request:
   ```bash
   git push origin feature-name
   ```

## Support
If you encounter any issues, feel free to open an issue in the repository or contact the developer at [email@example.com].

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
