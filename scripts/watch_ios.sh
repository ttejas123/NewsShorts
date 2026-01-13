#!/bin/bash

echo "👀 Watching Flutter changes for iOS device build..."

fswatch -o lib assets | while read; do
  flutter build ios --profile
  echo "🚀 Rebuild complete — open app on device"
done
