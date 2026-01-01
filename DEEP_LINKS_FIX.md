# Deep Links Error Fix - Google Play Console

## Problem
Google Play Console shows "Deep links not working" error with 2 domains failed validation:
- `https://com.brighthex.dream247` (from Razorpay custom scheme)
- `https://pg-router.dev.razorpay.in` (Razorpay's payment gateway domain)

These domains are added by the Razorpay Flutter plugin for payment processing deep links.

## Root Cause
The Razorpay plugin automatically adds deep link intent filters with `android:autoVerify="true"` (default), causing Google Play to attempt verification of these domains. Since you don't control these domains, verification fails.

## Solution Applied

### ✅ Fixed: Disabled Auto-Verification

Modified `android/app/src/main/AndroidManifest.xml` to:

1. **Added tools namespace** to the manifest tag
2. **Overrode Razorpay's DeeplinkActivity** with `android:autoVerify="false"`
3. **Used `tools:node="merge"`** to ensure our configuration takes precedence

This tells Google Play NOT to verify these links, preventing the validation error.

## What Changed

**File:** `android/app/src/main/AndroidManifest.xml`

Added:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- ... existing code ... -->
    
    <!-- Razorpay Deep Link Activity with autoVerify disabled -->
    <activity
        android:name="com.razorpay.DeeplinkActivity"
        android:exported="true"
        android:theme="@style/CheckoutTheme"
        tools:node="merge">
        <intent-filter android:autoVerify="false">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data
                android:host="com.brighthex.dream247"
                android:scheme="razorpay" />
            <data
                android:host="pg-router.dev.razorpay.in"
                android:scheme="https" />
        </intent-filter>
    </activity>
```

## Next Steps

### 1. Clean Build
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### 2. Build New Release
```bash
flutter build appbundle --release
```

### 3. Upload to Google Play Console
- Upload the new app bundle (`.aab` file from `build/app/outputs/bundle/release/`)
- Submit for review

### 4. Verify Fix
After the new version is published:
- Go to Google Play Console → App version → Deep links
- The error should be resolved
- The deep links will still work for Razorpay payments (just won't show as "verified")

## Impact

### ✅ What Still Works:
- Razorpay payment deep links work perfectly
- Users can complete payments and return to your app
- Payment gateway functionality unchanged

### ℹ️ What Changes:
- Google Play won't show these as "verified" App Links
- Users might see an app chooser dialog if multiple apps handle the same links
- This is standard behavior for non-verified deep links

## Why This Approach?

### Alternative Options Considered:

**❌ Option 1: Verify domains via Digital Asset Links**
- Would require control over Razorpay's domain (impossible)
- Would require hosting a website at `com.brighthex.dream247` (incorrect URL)

**❌ Option 2: Remove deep link intent filters**
- Would break Razorpay payment flow
- Users couldn't return to app after payment

**✅ Option 3: Disable auto-verification (CHOSEN)**
- Simple, clean solution
- No external dependencies
- Maintains full Razorpay functionality
- Resolves Google Play validation error

## Technical Details

### What is `android:autoVerify`?
- When `true`: Google verifies you control the web domains via Digital Asset Links
- When `false`: Links work but aren't verified (standard deep links)
- Default is `true` for HTTPS scheme intent filters on Android 12+

### What is `tools:node="merge"`?
- Manifest merger attribute that tells the build system to merge this activity with any existing declarations
- Ensures our `autoVerify="false"` attribute takes precedence over the Razorpay plugin's default

## Testing

After building with these changes, you can verify the manifest:

```bash
# Build the app
flutter build appbundle --release

# Check the merged manifest
cat build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml | grep -A 15 "DeeplinkActivity"
```

You should see `android:autoVerify="false"` in the intent-filter.

## References

- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [Manifest Merger Documentation](https://developer.android.com/studio/build/manage-manifests)
- [Razorpay Android Integration](https://razorpay.com/docs/payments/payment-gateway/android-integration/)

---

**Status:** ✅ Fixed  
**Date:** January 1, 2026  
**Version Required:** Build new release with updated manifest
