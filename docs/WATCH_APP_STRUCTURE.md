# Watch App Code Structure

## Overview
This document describes the organized structure of the Watch app codebase.

## Directory Structure

```
Third of the Night Watch App/
├── Third_of_the_NightApp.swift    # App entry point
├── Assets.xcassets/                # App assets
├── Managers/                        # Connection and communication managers
│   └── WatchConnectivityManagerWatch.swift
├── Models/                          # Data models and ML integration
│   └── PrayerDetectionModel.swift
└── Views/                           # SwiftUI views
    └── ContentView.swift
```

## File Organization

### App Entry Point
- **Third_of_the_NightApp.swift**: Main app file that initializes the app and sets up lifecycle management

### Managers/
Contains classes that handle communication and connectivity:
- **WatchConnectivityManagerWatch.swift**: Manages Watch-to-iPhone communication, handles session lifecycle, sends heartbeats, and manages notifications

### Models/
Contains data models and ML model integration:
- **PrayerDetectionModel.swift**: Placeholder for your trained Core ML model integration

### Views/
Contains SwiftUI views:
- **ContentView.swift**: Main UI view showing connection status and app information

## iOS App Watch Integration

Watch-related iOS services are organized in:
```
third2.0/Services/Watch/
├── WatchConnectivityManager.swift    # iOS side WatchConnectivity manager
└── PrayerDetectionService.swift      # Service to determine which prayer to tick
```

## Documentation

All Watch app documentation is in the `docs/` folder:
- `WATCH_INTEGRATION_SUMMARY.md` - Overview of the integration
- `WATCH_APP_SETUP_COMPLETE.md` - Setup instructions
- `PERSISTENT_CONNECTION_SETUP.md` - Connection management guide
- `BACKGROUND_DETECTION_SETUP.md` - Background operation guide
- `MODEL_INTEGRATION_GUIDE.md` - How to integrate your trained model
- `ADD_WATCH_TARGET_INSTRUCTIONS.md` - Xcode setup steps

