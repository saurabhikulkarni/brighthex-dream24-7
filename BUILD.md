# Building the App

This document explains how to build the Flutter app and generate APK files.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.24.3 or later)
- [Android SDK](https://developer.android.com/studio)
- Java JDK 17 or later

Alternatively, you can use Docker to build the app without installing Flutter locally.

## Building with Flutter (Local Installation)

### 1. Install Flutter

Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install) for your operating system.

### 2. Verify Installation

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

### 3. Get Dependencies

```bash
flutter pub get
```

### 4. Build Debug APK

```bash
flutter build apk --debug
```

The debug APK will be generated at: `build/app/outputs/flutter-apk/app-debug.apk`

### 5. Build Release APK

```bash
flutter build apk --release
```

The release APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Building with Docker

If you have Docker installed but don't want to set up Flutter locally, you can use the provided build script:

```bash
./build-apk.sh
```

This script will:
1. Pull the Flutter Docker image
2. Install dependencies
3. Build the debug APK

The APK will be available at: `build/app/outputs/flutter-apk/app-debug.apk`

## Building with GitHub Actions

This repository includes a GitHub Actions workflow that automatically builds the APK when you push to specific branches.

The workflow is defined in `.github/workflows/build-apk.yml` and will:
1. Set up Flutter environment
2. Install dependencies
3. Build debug APK
4. Upload the APK as an artifact

### To trigger the workflow:

1. Push changes to `main`, `master`, or `copilot/build-debug-apk-file` branches
2. Create a pull request targeting these branches
3. Manually trigger the workflow from the Actions tab

### To download the built APK:

1. Go to the "Actions" tab in your repository
2. Click on the latest workflow run
3. Download the "app-debug" artifact

## Troubleshooting

### Flutter command not found

Make sure Flutter is installed and added to your PATH:

```bash
export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
```

### Android licenses not accepted

Run the following command to accept Android SDK licenses:

```bash
flutter doctor --android-licenses
```

### Gradle build issues

If you encounter Gradle build errors, try:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

## APK Installation

Once the APK is built, you can install it on an Android device:

1. Enable "Unknown sources" in your device settings
2. Transfer the APK to your device
3. Open the APK file to install

Or use ADB:

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Additional Build Options

### Build for specific architectures

```bash
# ARM 64-bit only
flutter build apk --target-platform android-arm64

# ARM 32-bit only
flutter build apk --target-platform android-arm

# x86 64-bit only
flutter build apk --target-platform android-x64
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

The app bundle will be generated at: `build/app/outputs/bundle/release/app-release.aab`
