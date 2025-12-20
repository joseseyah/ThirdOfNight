# Quick Fix: Add WatchConnectivityManager to Xcode Project

## Problem
`WatchConnectivityManager` cannot be found because the file isn't in your Xcode project.

## Solution - Add File to Xcode

### Step 1: Open Xcode Project
Open your `Night Prayers.xcodeproj` in Xcode

### Step 2: Add WatchConnectivityManager.swift

1. **In Xcode Project Navigator**, right-click on the `third2.0/Services/Watch/` folder (or `Services` folder if `Watch` doesn't exist in the navigator)

2. Select **"Add Files to 'Night Prayers'..."**

3. **Navigate to**: `third2.0/Services/Watch/WatchConnectivityManager.swift`

4. **Important Settings**:
   - ✅ **Uncheck** "Copy items if needed" (file is already in the right place)
   - ✅ **Check** "Create groups" (not "Create folder references")
   - ✅ **Check** your iOS app target (e.g., "Night Prayers" or "third2.0")
   - ❌ **Uncheck** Watch app target (this is iOS-only)

5. Click **"Add"**

### Step 3: Add PrayerDetectionService.swift (if needed)

Repeat the same process for:
- `third2.0/Services/Watch/PrayerDetectionService.swift`

### Step 4: Verify Target Membership

1. Select `WatchConnectivityManager.swift` in Project Navigator
2. Open **File Inspector** (right panel, ⌥⌘1)
3. Under **"Target Membership"**:
   - ✅ Check your iOS app target
   - ❌ Uncheck Watch app target

### Step 5: Clean and Build

1. **Product** → **Clean Build Folder** (⇧⌘K)
2. **Product** → **Build** (⌘B)

## Verify It Works

After adding, the error should disappear. The file exists at:
```
third2.0/Services/Watch/WatchConnectivityManager.swift
```

And contains the class:
```swift
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    // ...
}
```

## Alternative: Check if File is Already There

1. In Xcode, press **⌘⇧O** (Command + Shift + O)
2. Type: `WatchConnectivityManager`
3. If it appears, select it and check its location
4. If it's in the wrong place, you can move it or update the reference










