# How to Add Watch App Target in Xcode

## Step-by-Step Instructions

### 1. Open Your Project
- Open `Night Prayers.xcodeproj` in Xcode

### 2. Add New Target
1. In Xcode, go to **File → New → Target...**
2. In the template selector:
   - Select **watchOS** at the top
   - Choose **App** under "Application"
   - Click **Next**

### 3. Configure the Watch App
1. **Product Name**: `Night Prayers Watch App`
2. **Bundle Identifier**: Should auto-fill as `com.yourcompany.NightPrayers.watchkitapp` (adjust if needed)
3. **Language**: Swift
4. **Interface**: SwiftUI
5. **Include Notification Scene**: ✅ Check this (for notifications)
6. Click **Finish**

### 4. Add Watch App Files to Target
After creating the target, you need to add the files I created:

1. **Select all files in the `WatchApp/` folder**:
   - `NightPrayersWatchApp.swift`
   - `WatchContentView.swift`
   - `WatchConnectivityManagerWatch.swift`
   - `PrayerDetectionModelExample.swift`

2. **In the File Inspector** (right panel):
   - Under "Target Membership", check ✅ **Night Prayers Watch App**
   - Uncheck any other targets if they're selected

### 5. Configure Capabilities
1. Select the **Night Prayers Watch App** target in the project navigator
2. Go to **Signing & Capabilities** tab
3. Ensure **Automatically manage signing** is checked
4. Select your development team

### 6. Link Required Frameworks
1. Select the **Night Prayers Watch App** target
2. Go to **Build Phases** tab
3. Expand **Link Binary With Libraries**
4. Click **+** and add:
   - `WatchConnectivity.framework`
   - `UserNotifications.framework`
   - `CoreML.framework` (if using Core ML for your model)

### 7. Configure Info.plist (if needed)
The Watch app may need notification permissions. Check if there's an `Info.plist` and ensure it has:
- `NSUserNotificationsUsageDescription` (if needed)

### 8. Set Watch App as Companion App
1. Select the main **Night Prayers** (iOS) target
2. Go to **General** tab
3. Scroll to **App Extensions and Watch Apps**
4. You should see "Night Prayers Watch App" listed
5. Ensure it's enabled

### 9. Build and Test
1. Select a physical device (Watch apps require physical devices)
2. Build the project (⌘B)
3. Run the Watch app (⌘R)

## Important Notes

- **Physical Device Required**: Watch apps cannot run in the simulator
- **Pairing**: Ensure your iPhone and Apple Watch are paired
- **Bundle Identifier**: The Watch app bundle ID should be: `com.yourcompany.NightPrayers.watchkitapp`
- **Watch App Extension**: Xcode may create both a Watch App and Watch App Extension. The main app code goes in the Watch App.

## Troubleshooting

### If files don't appear in target:
- Select the file in the project navigator
- Open File Inspector (right panel)
- Check the target membership checkbox

### If build errors occur:
- Clean build folder (⇧⌘K)
- Delete derived data
- Rebuild

### If WatchConnectivity doesn't work:
- Ensure both iOS and Watch apps are signed with the same team
- Check that both apps have WatchConnectivity framework linked
- Verify bundle identifiers match the pattern: `com.company.app` and `com.company.app.watchkitapp`

