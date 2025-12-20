# Fixing Xcode File Reference Issues After Refactoring

## Problem
After moving files to new locations, Xcode may show "Cannot find 'X' in scope" errors because the project file still references old paths.

## Solution

### Option 1: Update File References in Xcode (Recommended)

1. **Open Xcode Project**
2. **Find the missing file** (WatchConnectivityManager.swift) in Project Navigator
   - It may show in red (missing) or be missing entirely
3. **Select the file** (or the folder it should be in)
4. **Right-click** → **Delete**
   - Choose **"Remove Reference"** (NOT "Move to Trash")
5. **Re-add the file**:
   - Right-click on `third2.0/Services/Watch/` folder
   - **Add Files to "Night Prayers"...**
   - Navigate to `third2.0/Services/Watch/WatchConnectivityManager.swift`
   - Select it
   - Ensure **"Copy items if needed"** is UNCHECKED (file is already there)
   - Ensure **"Create groups"** is selected
   - Ensure correct **Target** is checked (Night Prayers iOS app)
   - Click **Add**

### Option 2: Clean and Rebuild

1. **Product** → **Clean Build Folder** (⇧⌘K)
2. **Close Xcode**
3. **Delete Derived Data**:
   - `~/Library/Developer/Xcode/DerivedData/`
   - Delete the folder for your project
4. **Reopen Xcode**
5. **Build** (⌘B)

### Option 3: Verify File is in Target

1. **Select** `WatchConnectivityManager.swift` in Project Navigator
2. **File Inspector** (right panel)
3. **Target Membership** section
4. Ensure **✅ Night Prayers** (or your iOS target) is checked
5. Ensure Watch app target is **NOT** checked (this is iOS-only)

## Files That Need to Be Re-added

After the refactoring, these files were moved and may need re-adding:

### iOS App Files
- `third2.0/Services/Watch/WatchConnectivityManager.swift`
- `third2.0/Services/Watch/PrayerDetectionService.swift`

### Watch App Files
- `Third of the Night Watch App/Managers/WatchConnectivityManagerWatch.swift`
- `Third of the Night Watch App/Models/PrayerDetectionModel.swift`
- `Third of the Night Watch App/Views/ContentView.swift`

## Quick Check

Run this in Terminal to verify files exist:
```bash
find . -name "WatchConnectivityManager.swift" -type f
find . -name "PrayerDetectionService.swift" -type f
```

Both should show files in the `Services/Watch/` directory.

## After Fixing

1. **Build** the project (⌘B)
2. **Verify** no red files in Project Navigator
3. **Test** that the code compiles

