# Razorpay Integration - Quick Platform Setup

## Android Setup (Quick Reference)

### 1. AndroidManifest.xml Updates

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher">
        <!-- Existing activities -->
        
        <!-- Razorpay Activity (optional for older versions) -->
        <activity
            android:name="com.razorpay.checkout.RazorpayActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="false" />
    </application>
</manifest>
```

### 2. build.gradle (Module: app)

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.dream247.shop"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. ProGuard Rules (if minifying)

File: `android/app/proguard-rules.pro`

```proguard
# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keep class com.squareup.okhttp.** { *; }
-keep class com.squareup.okhttp3.** { *; }

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep generic signatures
-keepattributes Signature
-keepattributes *Annotation*
```

### 4. Verify Setup

Run in terminal:
```bash
cd android
./gradlew assembleDebug
cd ..
```

If successful, APK will be generated in: `android/app/build/outputs/apk/debug/`

---

## iOS Setup (Quick Reference)

### 1. Update Podfile

File: `ios/Podfile`

```ruby
platform :ios, '12.0'  # Uncomment and set to 12.0 minimum

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_root = File.expand_path(File.join(packages_path, 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')

  flutter_ios_podfile_setup

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

Install pods:
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### 2. Update Info.plist

File: `ios/Runner/Info.plist`

Add after existing properties:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>razorpay</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>razorapishop</string>
        </array>
    </dict>
</array>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.razorpay.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

### 3. Update Build Settings in Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner project
3. Select Runner target
4. Go to Build Settings
5. Search for "URL Schemes"
6. Add: `razorapishop`

### 4. Verify Setup

In Xcode, build for iOS Simulator:
```bash
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -simulator
cd ..
```

Or use Flutter:
```bash
flutter run -d 'iPhone 14 Pro'
```

---

## Configuration Checklist

### Before Development

- [ ] Add Razorpay dependencies to pubspec.yaml
- [ ] Update `lib/config/razorpay_config.dart` with Key ID (from Razorpay Dashboard)
- [ ] Create backend API endpoints for order creation
- [ ] Test with Razorpay sandbox credentials

### Before Testing on Device

**Android:**
- [ ] Set `android:exported="false"` on activities
- [ ] Add INTERNET permission in AndroidManifest.xml
- [ ] Ensure minSdkVersion is 21 or higher
- [ ] Test on actual Android device (emulator has limitations)

**iOS:**
- [ ] Set platform minimum to iOS 12.0
- [ ] Add URL scheme in Info.plist
- [ ] Update build settings with URL schemes in Xcode
- [ ] Test on actual iOS device (simulator has limitations)

### Before Going Live

- [ ] Switch from sandbox to production credentials
- [ ] Update Key ID to live key
- [ ] Backend API secret configured
- [ ] Webhook URL registered in Razorpay dashboard
- [ ] Test payment flow end-to-end
- [ ] Monitor payment success rate

---

## Troubleshooting

### Android Issues

**Issue: "razorpay_flutter" plugin not found**
```bash
flutter clean
flutter pub get
flutter run
```

**Issue: INTERNET permission error**
- Add to AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**Issue: Razorpay Activity not exported error**
- Ensure `android:exported="false"` is set on the activity

### iOS Issues

**Issue: Pod installation fails**
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install --repo-update
cd ..
```

**Issue: URL scheme not working**
1. Go to Xcode → Runner → Targets → Runner → Info
2. Add custom URL scheme: `razorapishop`

**Issue: Build fails with "module not found"**
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run
```

### General Issues

**Issue: Payment modal doesn't open**
- Verify Key ID is correct and from Razorpay dashboard
- Check internet connectivity
- Ensure app has INTERNET permission
- For iOS: Verify URL scheme is added

**Issue: "X-Razorpay-Signature" error**
- Signature verification on backend is failing
- Check that Key Secret is correct
- Verify HMAC-SHA256 algorithm usage
- Ensure order ID matches

---

## Environment Setup Commands

### Initialize Razorpay for Android

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on Android
flutter run -d <device-id>
```

### Initialize Razorpay for iOS

```bash
# Install pods
cd ios && pod install --repo-update && cd ..

# Clean and rebuild
flutter clean
flutter pub get

# Run on iOS
flutter run -d 'iPhone 14 Pro'
```

### Build Release APK (Android)

```bash
# Generate signed APK for Play Store
flutter build apk --release

# Output location
# build/app/outputs/apk/release/app-release.apk
```

### Build Release App (iOS)

```bash
# Build for App Store
flutter build ios --release

# Then use Xcode to upload to App Store Connect
# Or use:
flutter build ipa --release
```

---

## Testing Payment Flow

1. **Sandbox Testing**: Use test card numbers provided in RAZORPAY_INTEGRATION.md
2. **Device Testing**: 
   - Android: Physical device recommended
   - iOS: Physical device recommended (simulator limitations)
3. **Backend Testing**: Verify signature verification works
4. **Webhook Testing**: Use Razorpay webhook test tool

---

## Production Deployment

### Step-by-Step

1. **Switch Credentials**
   - Update `razorpay_config.dart` with live Key ID
   - Update backend with live Key Secret

2. **Backend Deployment**
   - Deploy API endpoints to production server
   - Verify webhook URL in Razorpay dashboard
   - Test webhook delivery

3. **Build & Sign**
   - Android: `flutter build appbundle --release`
   - iOS: `flutter build ipa --release`

4. **App Store Submission**
   - Android: Upload to Google Play Console
   - iOS: Upload to App Store Connect

5. **Monitor**
   - Track payment success rates
   - Monitor failed transactions
   - Check webhook delivery logs

---

## Support Resources

- **Razorpay Docs**: https://razorpay.com/docs
- **Flutter Plugin**: https://github.com/razorpay/razorpay-flutter
- **Test Cases**: https://razorpay.com/docs/payments/test-cases/
- **API Reference**: https://razorpay.com/docs/api/orders/

---

**Note**: Always keep API Keys secure. Never commit them to version control. Use environment variables in production.
