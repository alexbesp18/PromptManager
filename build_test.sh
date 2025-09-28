#!/bin/bash

echo "🔨 Testing PromptManager build..."
echo "📁 Project structure:"
find PromptManager -name "*.swift" | head -10

echo ""
echo "📊 Core Data model:"
ls -la PromptManager/PromptManager.xcdatamodeld/

echo ""
echo "🎯 Ready to build in Xcode!"
echo "👉 Open PromptManager.xcodeproj in Xcode and press ⌘R to run"