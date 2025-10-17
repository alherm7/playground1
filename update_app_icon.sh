#!/bin/bash

# Script to update app icon and rebuild iOS app

echo "🔄 Updating app icon and rebuilding iOS app..."

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build iOS app
echo "🏗️  Building iOS app..."
flutter build ios

echo ""
echo "✅ App icon updated and iOS app built!"
echo ""
echo "📱 To see the new icon:"
echo "   1. Open ios/Runner.xcworkspace in Xcode"
echo "   2. Run the app on your device or simulator"
echo "   3. The new workout timer icon should appear on your home screen"
echo ""
echo "🎨 Your new icon features:"
echo "   • Purple background matching your app theme"
echo "   • Clock design representing timing"
echo "   • Work (orange) and Rest (green) indicators"
echo "   • Clean, professional look"
