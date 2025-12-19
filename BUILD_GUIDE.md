# Complete Build Guide for Flutter Shop App

## ⚠️ Important: Why Standalone Gradle Won't Work

**DO NOT attempt to build this app using standalone Gradle configuration without Flutter.**

Flutter apps require:
1. **Flutter Engine**: C++ runtime that executes Dart code
2. **Compiled Dart Code**: Your app logic compiled to native ARM/x86 code
3. **Flutter Framework**: UI rendering, widgets, etc.
4. **Plugin Native Code**: Android implementations of Flutter plugins
5. **Assets**: Images, fonts, and other resources processed by Flutter build

A standalone Gradle build will create an APK, but it will:
- ❌ Crash immediately on launch
- ❌ Missing all app functionality
- ❌ Missing all UI components
- ❌ Be essentially useless

## ✅ Proper Build Methods

### Method 1: Local Build (Recommended for Development)

**Prerequisites:**
- Flutter SDK 3.24.3 or later
- Android SDK
- Java JDK 17

**Steps:**

1. **Install Flutter** (if not already installed):
   ```bash
   # macOS
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Linux
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Windows (PowerShell)
   cd C:\src
   git clone https://github.com/flutter/flutter.git -b stable
   $env:Path += ";C:\src\flutter\bin"
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```
   Fix any issues reported by Flutter Doctor.

3. **Build the APK**:
   ```bash
   cd /path/to/brighthex-dream24-7
   chmod +x build-apk-local.sh
   ./build-apk-local.sh
   ```
   
   Or manually:
   ```bash
   flutter pub get
   flutter build apk --debug
   ```

4. **Output Location**:
   ```
   build/app/outputs/flutter-apk/app-debug.apk
   ```

### Method 2: GitHub Actions (Recommended for CI/CD)

**This is the EASIEST method - no local setup required!**

1. **Push your code** to the repository:
   ```bash
   git push origin your-branch
   ```

2. **GitHub Actions will automatically**:
   - Set up Flutter environment
   - Install dependencies
   - Build the debug APK
   - Upload as artifact

3. **Download the APK**:
   - Go to repository → Actions tab
   - Click on latest workflow run
   - Download the "app-debug" artifact

### Method 3: Docker Build (Advanced)

**Note**: This method has SSL certificate issues in restricted network environments.

If your system has proper SSL certificates configured:

```bash
chmod +x build-apk.sh
./build-apk.sh
```

This will:
- Pull Flutter Docker image
- Build the APK in a container
- Output to standard location

## 🔧 Troubleshooting

### "Flutter not found"
Install Flutter SDK following the official guide: https://docs.flutter.dev/get-started/install

### "Android licenses not accepted"
```bash
flutter doctor --android-licenses
```
Accept all licenses when prompted.

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --debug
```

### "Plugin version conflict"
Update plugins in `pubspec.yaml` and run:
```bash
flutter pub upgrade
```

## 📦 Build Variants

### Debug APK (Default)
```bash
flutter build apk --debug
```
- Larger file size
- Includes debug symbols
- Hot reload support
- Good for testing

### Release APK
```bash
flutter build apk --release
```
- Smaller file size
- Optimized performance
- Obfuscated code
- Ready for distribution

### Split APKs (Smaller size)
```bash
flutter build apk --split-per-abi --release
```
Generates separate APKs for each CPU architecture:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### App Bundle (For Play Store)
```bash
flutter build appbundle --release
```
- Best for Google Play Store
- Smallest download size for users
- Play Store generates optimized APKs

## 🚀 Installing the APK

### On Physical Device

1. Enable "Unknown Sources" in device settings
2. Transfer APK to device
3. Open APK file to install

### Using ADB

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Replace Existing App

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 📊 APK Size Optimization

To reduce APK size:

1. **Use split APKs**: Build separate APKs for different architectures
2. **Enable ProGuard**: Minifies and obfuscates code
3. **Compress images**: Optimize PNG and JPEG assets
4. **Remove unused code**: Run `flutter build --analyze-size`

## 🔐 Signing for Release

For production releases, you need to sign the APK:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=my-key-alias
   storeFile=/path/to/my-release-key.jks
   ```

3. Update `android/app/build.gradle` to use the keystore

4. Build release APK:
   ```bash
   flutter build apk --release
   ```

## ✅ Verification Checklist

After building, verify:
- [ ] APK file exists at expected location
- [ ] APK size is reasonable (typically 20-50 MB for debug)
- [ ] APK can be installed on test device
- [ ] App launches without crashing
- [ ] Main features work correctly

## 📚 Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
