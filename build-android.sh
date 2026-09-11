#!/bin/bash
# Script to build and test the Android app locally

set -e

echo "🔨 Building ChatAI Android App..."
echo ""

# Check prerequisites
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js."
    exit 1
fi

if ! command -v gradle &> /dev/null && [ ! -f "android/gradlew" ]; then
    echo "❌ Gradle not found. Please install Android Studio or Gradle."
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo "❌ Java not found. Please install JDK 17+."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Build web app
echo "📦 Building web app..."
npm install
npm run build

# Copy web build to Android assets
echo "📋 Copying web build to Android assets..."
mkdir -p android/app/src/main/assets/public
cp -r dist/* android/app/src/main/assets/public/

# Build APK
echo "🔨 Building debug APK..."
cd android
chmod +x gradlew
./gradlew assembleDebug

echo ""
echo "✅ Build complete!"
echo "📱 Debug APK location: android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "📲 To install on connected device:"
echo "   adb install -r android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
