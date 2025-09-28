# Window Visibility Debug Guide

## Changes Made:

### 1. Window Configuration Fixed
- ✅ Added explicit window sizing (800x600 minimum, 1000x700 default)
- ✅ Added `NSApp.activate(ignoringOtherApps: true)` to force window to front
- ✅ Simplified UI structure to basic VStack/HStack layout
- ✅ Added debug print statements

### 2. UI Simplified
- ✅ Replaced complex NavigationSplitView with simple VStack/HStack
- ✅ This eliminates potential NavigationSplitView rendering issues
- ✅ Should show a clear "PromptManager" title and basic layout

## Debugging Steps:

### 1. Check if window is actually created but hidden:
```bash
# Run this while app is running:
osascript -e 'tell application "System Events" to get windows of application process "PromptManager"'
```

### 2. Force window to appear:
If app is running but no window, try:
- **⌘Tab** to PromptManager, then **⌘`** to cycle windows
- **⌘M** to minimize/restore
- Check **Window** menu in menu bar

### 3. Check Console output:
Should see:
```
PromptManager app launched successfully
ContentView appeared successfully
```

### 4. If still no window:

**Option A - Use TestWindow.swift:**
1. Rename `PromptManagerApp.swift` to `PromptManagerApp.swift.backup`
2. Rename `TestWindow.swift` to `PromptManagerApp.swift`
3. Build and run - should show simple test window
4. If test window works, issue is in main app logic

**Option B - Nuclear option:**
```bash
# Reset all app data
rm -rf ~/Library/Containers/com.promptmanager.PromptManager/
rm -rf ~/Library/Preferences/com.promptmanager.PromptManager.plist
```

## Expected Result:
You should now see:
- Window with "PromptManager" title at top
- Left side: "Prompts" section with sample prompts listed
- Right side: "Select a prompt to view details" message
- Window size: 1000x700 pixels

## If Window Still Missing:
The issue might be:
1. macOS window management hiding it offscreen
2. Display scaling issues
3. SwiftUI rendering bug
4. Try running from Xcode with debugger attached

Let me know what you see when you run it now!