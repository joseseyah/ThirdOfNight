# Background Prayer Detection Setup

## Overview
The Watch app is now configured to run prayer detection in the background. The app doesn't need to be open - detection runs automatically and shows congratulatory notifications when prayers are completed.

## How It Works

### Background Detection Flow
1. **App Launches** → Detection starts automatically
2. **Model Detects Prayer** → Sends to iPhone via WatchConnectivity
3. **iPhone Processes** → Determines which prayer to tick (based on time window)
4. **Prayer Marked Complete** → iPhone sends confirmation back to Watch
5. **Watch Shows Notification** → "🎉 Congrats! You have completed [Prayer Name]"

### Key Features
- ✅ **Automatic Start**: Detection begins when app launches
- ✅ **Background Operation**: Works even when app isn't visible
- ✅ **Congratulatory Notifications**: Shows "🎉 Congrats!" when prayer is completed
- ✅ **No User Interaction Required**: Fully automatic

## Configuration Required

### 1. Enable Background Modes (if needed)

For continuous background detection, you may need to enable background modes:

1. Select **Third of the Night Watch App** target in Xcode
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **Background Modes**
5. Check:
   - ✅ **Background processing**
   - ✅ **Background fetch** (if needed)

### 2. Info.plist Configuration

Add to your Watch app's `Info.plist` (if it exists):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

### 3. For Continuous Sensor Access

If your model requires continuous sensor access (accelerometer, gyroscope), consider:

**Option A: WorkoutKit** (Recommended for continuous motion)
- Provides continuous sensor access
- Better battery management
- Designed for health/fitness apps

**Option B: HealthKit**
- For health-related tracking
- Requires HealthKit entitlement

**Option C: Background Tasks**
- Use `WKApplication.shared.scheduleBackgroundRefresh()`
- Limited execution time
- System manages scheduling

### 4. Battery Optimization

Background detection can impact battery life. Consider:
- Reducing detection frequency when not actively praying
- Using motion detection only during prayer times
- Implementing smart scheduling based on prayer times

## Testing Background Detection

### Test Steps:
1. **Launch Watch App** → Detection should start automatically
2. **Close/Minimize App** → Detection continues in background
3. **Trigger Your Model** → Should detect prayer and send to iPhone
4. **Check iPhone App** → Prayer should be ticked automatically
5. **Check Watch** → Should receive congratulatory notification

### Verify Background Operation:
- Check console logs: "Background prayer detection started"
- Model should continue detecting even when app is backgrounded
- Notifications should appear even when app isn't open

## Notification Customization

The congratulatory notification is configured in `WatchConnectivityManagerWatch.swift`:

```swift
content.title = "🎉 Congrats!"
content.body = "You have completed \(prayerName)"
```

You can customize:
- Title text
- Body message
- Sound (add custom sound file)
- Badge count
- Action buttons (if needed)

## Troubleshooting

### Detection Stops When App Backgrounds
- **Solution**: Enable Background Modes capability
- **Solution**: Use WorkoutKit for continuous sensor access
- **Solution**: Implement background task scheduling

### Notifications Not Appearing
- **Check**: Notification permissions granted
- **Check**: Do Not Disturb mode is off
- **Check**: Watch is not in theater mode
- **Verify**: `sendPrayerCompletionNotification()` is being called

### Model Not Running in Background
- **Check**: Background Modes enabled
- **Check**: Model initialization in `App.init()`
- **Check**: Sensors are configured for background operation
- **Consider**: Using WorkoutKit for continuous access

### Battery Drain
- **Optimize**: Reduce detection frequency
- **Optimize**: Only detect during prayer time windows
- **Optimize**: Use efficient sensor sampling rates
- **Consider**: Smart scheduling based on prayer times

## Code Locations

- **App Initialization**: `Third_of_the_NightApp.swift` → `init()`
- **Background Start**: `WatchConnectivityManagerWatch.swift` → `startBackgroundDetection()`
- **Notification**: `WatchConnectivityManagerWatch.swift` → `sendPrayerCompletionNotification()`
- **Model Detection**: `PrayerDetectionModel.swift` → `startDetection()`

## Next Steps

1. ✅ Background detection is configured
2. ✅ Notifications are set up with congratulatory messages
3. ⏳ Integrate your trained model in `PrayerDetectionModel.swift`
4. ⏳ Test on physical devices (Watch apps require physical devices)
5. ⏳ Optimize battery usage based on your model's requirements

## Important Notes

- **Physical Device Required**: Watch apps cannot run in simulator
- **Background Limitations**: watchOS has strict background execution limits
- **Battery Impact**: Continuous detection will impact battery life
- **User Permissions**: Ensure notification permissions are granted

