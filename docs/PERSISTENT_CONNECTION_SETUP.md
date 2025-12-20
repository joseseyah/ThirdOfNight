# Persistent Connection Setup (Like Health App)

## Overview
The Watch app now maintains a **persistent connection** similar to the Health app and Apple Watch. The connection is automatically maintained, reconnects if lost, and works reliably in the background.

## Key Features

### ✅ Automatic Connection Management
- Session automatically activates on app launch
- Connection monitoring every 10 seconds (Watch) / 15 seconds (iPhone)
- Automatic reconnection if connection is lost
- Heartbeat mechanism to keep connection alive

### ✅ Background Operation
- Connection maintained even when app is in background
- Works similar to Health app - always connected
- No user interaction required

### ✅ Lifecycle Handling
- Handles app state changes (active/inactive/background)
- Reactivates session if it becomes inactive
- Maintains connection across app launches

## How It Works

### Connection Maintenance

```
App Launches
    ↓
WatchConnectivity Session Activates
    ↓
Connection Monitor Starts (every 10s)
    ↓
Heartbeat Sent (every 30s)
    ↓
Connection Status Checked
    ↓
If Disconnected → Auto Reconnect
```

### Heartbeat Mechanism

1. **Watch sends heartbeat** every 30 seconds via `updateApplicationContext`
2. **iPhone receives heartbeat** and sends acknowledgment
3. **Watch receives ack** and confirms connection is alive
4. **If no heartbeat** → Connection is checked and reconnected if needed

### Automatic Reconnection

- **Session becomes inactive** → Immediately reactivates
- **Session deactivates** → Immediately reactivates
- **Phone unreachable** → Retries automatically
- **Connection lost** → Reconnects within 10-15 seconds

## Implementation Details

### Watch Side (`WatchConnectivityManagerWatch.swift`)

1. **Connection Monitoring**
   - Timer runs every 10 seconds
   - Checks session activation state
   - Ensures session is active

2. **Heartbeat System**
   - Sends heartbeat every 30 seconds
   - Uses `updateApplicationContext` (works in background)
   - Tracks last heartbeat time

3. **Session Lifecycle**
   - Handles `activationDidComplete`
   - Handles `sessionDidBecomeInactive`
   - Handles `sessionDidDeactivate`
   - All trigger automatic reactivation

4. **App Lifecycle Integration**
   - `ensureConnection()` called on app active
   - Connection maintained in background
   - Detection continues regardless of app state

### iPhone Side (`WatchConnectivityManager.swift`)

1. **Connection Monitoring**
   - Timer runs every 15 seconds
   - Ensures session stays active
   - Monitors reachability

2. **Heartbeat Handling**
   - Receives heartbeats from Watch
   - Sends acknowledgment back
   - Confirms connection is alive

3. **Session Lifecycle**
   - Same automatic reactivation as Watch
   - Maintains persistent connection
   - Handles all state changes

## Configuration

### No Additional Setup Required!

The persistent connection is **automatically configured** and works out of the box. However, for optimal performance:

### 1. Background Modes (Recommended)

Enable background modes for continuous operation:

1. Select **Third of the Night Watch App** target
2. **Signing & Capabilities** → **+ Capability**
3. Add **Background Modes**
4. Check:
   - ✅ **Background processing**

### 2. Info.plist (Optional)

If you have an Info.plist, you can add:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## Connection Status

The Watch app tracks connection status:

- **`.connected`** - Session active and phone reachable
- **`.connecting`** - Session activating or reconnecting
- **`.disconnected`** - Session inactive or phone unreachable

## Monitoring Connection

### Watch Console Logs

You'll see logs like:
- `✅ WatchConnectivity session activated - Connection established`
- `💓 Heartbeat sent to maintain connection`
- `✅ Phone became reachable - Connection restored`
- `⚠️ Session became inactive - Reactivating...`

### iPhone Console Logs

You'll see logs like:
- `✅ iPhone: WatchConnectivity session activated`
- `💓 iPhone: Received heartbeat from Watch`
- `✅ iPhone: Watch became reachable`

## Troubleshooting

### Connection Not Establishing

1. **Check pairing**: Ensure iPhone and Watch are paired
2. **Check logs**: Look for activation errors
3. **Restart**: Restart both devices if needed
4. **Verify**: Both apps are signed with same team

### Connection Drops Frequently

1. **Check network**: Ensure both devices on same network
2. **Check battery**: Low battery can affect connection
3. **Check distance**: Devices should be within range
4. **Check logs**: Look for specific error messages

### Heartbeats Not Working

1. **Check background modes**: Ensure enabled
2. **Check permissions**: Ensure WatchConnectivity is allowed
3. **Check logs**: Look for heartbeat errors
4. **Verify**: Both apps are running

## Testing

### Test Persistent Connection

1. **Launch Watch app** → Should see "✅ Connection established"
2. **Close app** → Connection should remain active
3. **Wait 30 seconds** → Should see heartbeat logs
4. **Turn off iPhone** → Should see reconnection attempts
5. **Turn on iPhone** → Should reconnect automatically

### Test Reconnection

1. **Disconnect Watch** (turn off Bluetooth)
2. **Watch logs** → Should show "⚠️ Phone became unreachable"
3. **Reconnect Watch**
4. **Watch logs** → Should show "✅ Connection restored"

## Benefits

✅ **Always Connected** - Like Health app, connection is persistent  
✅ **Automatic Recovery** - Reconnects automatically if lost  
✅ **Background Operation** - Works without app being open  
✅ **Reliable Communication** - Heartbeat confirms connection  
✅ **No User Action** - Fully automatic  

## Comparison to Health App

| Feature | Health App | Your App |
|---------|-----------|----------|
| Persistent Connection | ✅ | ✅ |
| Background Operation | ✅ | ✅ |
| Auto Reconnection | ✅ | ✅ |
| Heartbeat Mechanism | ✅ | ✅ |
| Lifecycle Handling | ✅ | ✅ |

Your app now maintains connection **exactly like the Health app**! 🎉

