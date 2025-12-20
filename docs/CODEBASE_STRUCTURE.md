# Codebase Structure

## Overview
This document describes the organized structure of the Night Prayers codebase.

## Root Directory Structure

```
ThirdOfNight/
├── docs/                              # All documentation
├── third2.0/                          # Main iOS app
│   ├── Services/
│   │   ├── Watch/                     # Watch-related iOS services
│   │   └── [other services]
│   ├── Views/
│   ├── ViewModels/
│   ├── Model/
│   └── ...
├── Third of the Night Watch App/      # Watch app
│   ├── Managers/
│   ├── Models/
│   └── Views/
├── [Widget folders]/
└── [Other targets]/
```

## Main iOS App (`third2.0/`)

### Services/
Contains service classes organized by functionality:
- **Watch/**: Watch-related services
  - `WatchConnectivityManager.swift` - iOS side WatchConnectivity handling
  - `PrayerDetectionService.swift` - Determines which prayer to tick based on time windows
- Other services (PrayerCalculator, MiniLocationManager, etc.)

### Views/
Organized by feature:
- `PrayerTrackerViews/` - Prayer tracking UI
- `SettingViews/` - Settings UI
- `SummaryViews/` - Summary/statistics UI
- `QiblaViews/` - Qibla direction UI
- etc.

### ViewModels/
Business logic and state management:
- `TrackerViewModel.swift` - Prayer tracking logic (includes Watch integration)
- Other view models

### Model/
Data models:
- `PrayerDay.swift` - SwiftData model for prayer completion
- `TrackerPrayer.swift` - Prayer display model
- Other models

## Watch App (`Third of the Night Watch App/`)

### Managers/
- `WatchConnectivityManagerWatch.swift` - Handles all Watch-to-iPhone communication

### Models/
- `PrayerDetectionModel.swift` - ML model integration placeholder

### Views/
- `ContentView.swift` - Main Watch UI

## Documentation (`docs/`)

All documentation is centralized:
- Watch app setup and integration guides
- Connection management documentation
- Model integration guides
- Setup instructions

## Benefits of This Structure

✅ **Clear Separation**: Watch code is separate from iOS code  
✅ **Logical Grouping**: Related files are grouped together  
✅ **Easy Navigation**: Find files quickly by purpose  
✅ **Scalable**: Easy to add new features  
✅ **Maintainable**: Clear organization makes updates easier  

