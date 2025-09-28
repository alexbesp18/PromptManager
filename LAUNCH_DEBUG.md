# PromptManager Launch Debug Guide

## Issues Fixed:

### 1. Core Data Initialization
- ✅ Removed `fatalError` that could crash the app
- ✅ Added fallback to in-memory store if file-based store fails
- ✅ Better error handling and logging

### 2. App Structure
- ✅ Simplified app initialization
- ✅ Removed potentially problematic `@StateObject` in App struct
- ✅ Fixed environment object dependencies

### 3. Sandboxing
- ✅ Temporarily disabled app sandboxing to rule out permission issues

## Debugging Steps:

### If App Still Won't Launch:

1. **Check Console Logs:**
   ```bash
   # Open Console.app and filter for "PromptManager"
   # OR run in Terminal:
   log stream --predicate 'process == "PromptManager"' --level debug
   ```

2. **Try Running from Xcode:**
   - Open project in Xcode
   - Press ⌘R to run with debugger attached
   - Check Xcode console for error messages

3. **Check Activity Monitor:**
   - Open Activity Monitor
   - Look for PromptManager process
   - Check if it's consuming high CPU or memory

### Quick Test Commands:

Run these in Terminal to check for issues:

```bash
# Check if app bundle is valid
codesign -vv "/path/to/PromptManager.app"

# Check for missing frameworks
otool -L "/path/to/PromptManager.app/Contents/MacOS/PromptManager"

# Reset app sandbox container (if needed)
rm -rf ~/Library/Containers/com.promptmanager.PromptManager/
```

## Expected Behavior:
After these fixes, the app should:
1. Launch without bouncing indefinitely
2. Show a window with "Select a prompt to view details"
3. Display sample prompts in the sidebar
4. Print "PromptManager app launched successfully" in logs

## Next Steps if Still Failing:
1. Run from Xcode with debugger
2. Check Console.app for crash logs
3. Try building for Release configuration
4. Verify Xcode command line tools are current: `xcode-select --install`