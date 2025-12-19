#!/bin/bash
set -e

echo "=========================================="
echo "Flutter APK Build Script (Local System)"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ ERROR: Flutter is not installed or not in PATH"
    echo ""
    echo "Please install Flutter first:"
    echo "  https://docs.flutter.dev/get-started/install"
    echo ""
    echo "Or use the GitHub Actions workflow which will build automatically:"
    echo "  Push your changes and the workflow will build the APK"
    exit 1
fi

echo "✓ Flutter found: $(flutter --version | head -1)"
echo ""

# Run Flutter doctor to check setup
echo "Checking Flutter environment..."
flutter doctor

echo ""
echo "Installing dependencies..."
flutter pub get

echo ""
echo "Cleaning previous builds..."
flutter clean

echo ""
echo "Building debug APK..."
flutter build apk --debug

echo ""
echo "=========================================="
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✓ BUILD SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "APK Details:"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
    echo ""
    echo "APK Location:"
    echo "  $(pwd)/build/app/outputs/flutter-apk/app-debug.apk"
    echo ""
    echo "To install on device:"
    echo "  adb install build/app/outputs/flutter-apk/app-debug.apk"
    echo ""
else
    echo "❌ BUILD FAILED"
    echo "=========================================="
    echo "APK was not generated. Check the errors above."
    exit 1
fi
