# Apple Watch Model Integration Guide

## Overview
This guide explains how to integrate your trained Apple Watch model for prayer detection into the Night Prayers app.

## Architecture

### iOS App Side
- **WatchConnectivityManager.swift**: Handles communication with the Watch app
- **PrayerDetectionService.swift**: Determines which prayer should be ticked based on current time windows
- **TrackerViewModel.swift**: Contains `handleWatchPrayerDetection()` method that processes Watch detections

### Watch App Side
- **WatchConnectivityManagerWatch.swift**: Handles communication with iPhone and sends notifications
- **PrayerDetectionModel**: Placeholder class where you'll integrate your trained model

## Integration Steps

### 1. Add Your Model to the Watch App Target

1. Add your `.mlmodel` or `.mlpackage` file to the Watch app target in Xcode
2. Ensure the model is included in the Watch app bundle

### 2. Integrate Your Model in WatchConnectivityManagerWatch.swift

Replace the `PrayerDetectionModel` class with your actual model integration:

```swift
import CoreML

class PrayerDetectionModel {
    private var model: YourTrainedModel?
    private var isDetecting = false
    
    init() {
        // Load your model
        do {
            let config = MLModelConfiguration()
            model = try YourTrainedModel(configuration: config)
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    func startDetection() {
        guard !isDetecting else { return }
        isDetecting = true
        
        // Start your model's detection process
        // This might involve:
        // - Starting motion sensors
        // - Processing sensor data
        // - Running inference on your model
        
        // When a prayer is detected, call:
        // WatchConnectivityManagerWatch.shared.onPrayerDetected(prayerName: detectedPrayer)
    }
    
    func stopDetection() {
        isDetecting = false
        // Stop sensors and cleanup
    }
    
    // Example detection method (replace with your actual implementation)
    private func processSensorData() {
        // Your model inference code here
        // When prayer is detected:
        // let detectedPrayer = "Fajr" // or whatever your model detects
        // WatchConnectivityManagerWatch.shared.onPrayerDetected(prayerName: detectedPrayer)
    }
}
```

### 3. Start Detection When Watch App Launches

In `WatchContentView.swift` or your main view, start detection:

```swift
.onAppear {
    watchConnectivity.prayerDetectionModel?.startDetection()
}
.onDisappear {
    watchConnectivity.prayerDetectionModel?.stopDetection()
}
```

## How It Works

1. **Watch detects prayer**: Your model running on the Watch detects that a prayer has been performed
2. **Watch sends to iPhone**: The Watch sends a message to the iPhone app via WatchConnectivity
3. **iPhone determines prayer**: The iPhone app uses `PrayerDetectionService` to determine which prayer should be ticked based on the current time window
4. **Prayer is ticked**: The appropriate prayer is marked as complete in the app
5. **Confirmation sent**: The iPhone sends a confirmation back to the Watch
6. **Watch notification**: The Watch displays a notification: "You have completed [Prayer Name]"

## Time Window Logic

The app uses intelligent time window detection:
- If **Asr** has started and **Dhuhr** has ended, but the user prays, only **Asr** will be ticked (not Dhuhr)
- This ensures users can't tick prayers that are outside their valid time window
- Each prayer has a window from its start time until the next prayer's start time

## Testing

1. Build and run the Watch app on a physical device (Watch apps require physical devices)
2. Ensure your iPhone and Watch are paired
3. Test prayer detection by triggering your model
4. Verify that:
   - The prayer is ticked in the iPhone app
   - A notification appears on the Watch
   - Only the correct prayer (based on time window) is ticked

## Troubleshooting

- **Watch not connecting**: Ensure both devices are on the same network and WatchConnectivity is properly initialized
- **Prayer not ticking**: Check that the time window logic is correct and that your coordinate is set
- **No notification**: Ensure notification permissions are granted on the Watch

