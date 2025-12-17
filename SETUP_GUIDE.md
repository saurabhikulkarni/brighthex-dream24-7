# Flutter E-Commerce App - Setup Guide

## Required Software

To run this Flutter e-commerce app, you need to install:

### 1. Flutter SDK
- **Download**: https://docs.flutter.dev/get-started/install/windows
- **Version Required**: SDK >=3.2.0 <4.0.0 (as specified in pubspec.yaml)

### 2. Git (for version control)
- **Download**: https://git-scm.com/download/win

### 3. Android Studio (for Android development)
- **Download**: https://developer.android.com/studio
- Includes Android SDK, Android Emulator, and other tools

### 4. VS Code (Optional but recommended)
- **Download**: https://code.visualstudio.com/
- Install Flutter and Dart extensions

## Installation Steps

### Step 1: Install Flutter

1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract the zip file to a location like `C:\src\flutter`
3. Add Flutter to your PATH:
   - Search for "Environment Variables" in Windows
   - Edit the "Path" variable
   - Add: `C:\src\flutter\bin` (or your Flutter installation path)

### Step 2: Install Git

1. Download Git from: https://git-scm.com/download/win
2. Run the installer with default settings
3. Git will be automatically added to PATH

### Step 3: Install Android Studio

1. Download Android Studio from: https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio and complete the setup wizard
4. Install Android SDK, Android SDK Platform-Tools, and Android Emulator

### Step 4: Verify Installation

After installing, run these commands in PowerShell:

```powershell
flutter doctor
```

This will check your Flutter installation and show what's missing.

### Step 5: Install Dependencies

Once Flutter is installed, navigate to the project directory and run:

```powershell
flutter pub get
```

### Step 6: Run the App

```powershell
flutter run
```

Or to see available devices:
```powershell
flutter devices
```

## Quick Installation Script

You can also use Chocolatey (Windows package manager) to install:

```powershell
# Install Chocolatey first (if not installed)
# Then run:
choco install flutter git androidstudio -y
```

## Troubleshooting

- **Flutter not recognized**: Make sure Flutter is added to your PATH and restart PowerShell
- **No devices found**: Make sure Android Studio is installed and an emulator is created
- **Build errors**: Run `flutter doctor -v` to see detailed information about issues

