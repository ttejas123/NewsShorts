#!/bin/bash

echo "🔄 Change detected — rebuilding iOS app..."

flutter build ios --release

echo "📱 Installing on device..."
open ios/Runner.xcworkspace

echo "✅ Build done. Press ⌘R in Xcode to run."
