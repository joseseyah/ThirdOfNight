# Night Prayers - Documentation

Welcome to the Night Prayers app documentation. All documentation files are organized in this folder.

## Quick Links

### Watch App Integration
- **[Watch App Structure](WATCH_APP_STRUCTURE.md)** - Organization of Watch app code
- **[Watch Integration Summary](WATCH_INTEGRATION_SUMMARY.md)** - Overview of Watch integration
- **[Watch App Setup](WATCH_APP_SETUP_COMPLETE.md)** - Complete setup instructions
- **[Model Integration Guide](MODEL_INTEGRATION_GUIDE.md)** - How to integrate your trained ML model

### Connection & Communication
- **[Persistent Connection Setup](PERSISTENT_CONNECTION_SETUP.md)** - How connection is maintained (like Health app)
- **[Background Detection Setup](BACKGROUND_DETECTION_SETUP.md)** - Background operation guide

### Setup & Configuration
- **[Add Watch Target Instructions](ADD_WATCH_TARGET_INSTRUCTIONS.md)** - Step-by-step Xcode setup
- **[Codebase Structure](CODEBASE_STRUCTURE.md)** - Overall project organization
- **[Refactoring Summary](REFACTORING_SUMMARY.md)** - Recent codebase reorganization

## Codebase Organization

### Watch App
Located in `Third of the Night Watch App/`:
- **Managers/**: Connection and communication managers
- **Models/**: Data models and ML integration
- **Views/**: SwiftUI views

### iOS App Watch Integration
Located in `third2.0/Services/Watch/`:
- **WatchConnectivityManager.swift**: iOS side WatchConnectivity handling
- **PrayerDetectionService.swift**: Determines which prayer to tick

## Getting Started

1. Read [Watch Integration Summary](WATCH_INTEGRATION_SUMMARY.md) for overview
2. Follow [Add Watch Target Instructions](ADD_WATCH_TARGET_INSTRUCTIONS.md) to set up in Xcode
3. See [Model Integration Guide](MODEL_INTEGRATION_GUIDE.md) to integrate your trained model
4. Check [Persistent Connection Setup](PERSISTENT_CONNECTION_SETUP.md) for connection details

## Need Help?

- Check the relevant guide above
- Review [Codebase Structure](CODEBASE_STRUCTURE.md) to understand organization
- See [Refactoring Summary](REFACTORING_SUMMARY.md) for recent changes

