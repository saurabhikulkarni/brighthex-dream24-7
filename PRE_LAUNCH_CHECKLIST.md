# 🚀 DREAM 247 - Pre-Launch Checklist

## ✅ COMPLETED FIXES

### Security & Configuration
- [x] Fixed Android Application ID mismatch
- [x] Added .gitignore for sensitive files (key.properties, keystores)
- [x] Created ProGuard rules for release builds
- [x] Enabled minification for Android release
- [x] Added signing instructions (SIGNING_README.txt)

### iOS Privacy
- [x] Added NSPhotoLibraryUsageDescription
- [x] Added NSCameraUsageDescription
- [x] Added NSLocationWhenInUseUsageDescription
- [x] Added NSUserTrackingUsageDescription (iOS 14+)

### Code Quality
- [x] Wrapped all print() statements with kDebugMode checks
- [x] Removed user-visible debug messages
- [x] Cleaned up debug UI elements in orders screen

### Legal Documents
- [x] Created PRIVACY_POLICY.md
- [x] Created TERMS_OF_SERVICE.md

---

## ⚠️ BEFORE PRODUCTION DEPLOYMENT

### 1. Payments (Razorpay)
- [ ] **Switch to production keys when approved**
  - Update `lib/config/razorpay_config.dart`
  - Change `keyId` from `rzp_test_*` to `rzp_live_*`
  - Update backend with production secret
  - Test real payment flow with small amount

### 2. Host Legal Documents
- [ ] **Upload PRIVACY_POLICY.md to your website**
  - Recommended URL: https://dream247.shop/privacy-policy
  - Update link in app stores
  - Add link in app settings/profile

- [ ] **Upload TERMS_OF_SERVICE.md to your website**
  - Recommended URL: https://dream247.shop/terms
  - Add link in app footer/settings

### 3. Shiprocket Integration
- [ ] Verify Shiprocket test credentials work
- [ ] Test order creation and tracking
- [ ] Update to production Shiprocket account when ready
- [ ] Configure pickup locations in Shiprocket dashboard

### 4. Android Release Build
```bash
# Clean build
flutter clean
cd android
./gradlew clean
cd ..

# Build release bundle
flutter build appbundle --release

# Test release build
flutter install --release
```

### 5. iOS Release Build
```bash
# Clean build
flutter clean

# Build iOS release
flutter build ios --release

# Archive in Xcode for App Store submission
```

### 6. Testing Checklist
- [ ] Test on physical Android device (not just emulator)
- [ ] Test on physical iOS device (not just simulator)
- [ ] Test payment flow end-to-end
- [ ] Test order creation and tracking
- [ ] Verify wallet top-up works
- [ ] Test cart and checkout flow
- [ ] Verify wishlist functionality
- [ ] Test address management
- [ ] Check all permissions work correctly
- [ ] Test offline behavior
- [ ] Verify app doesn't crash on network errors

### 7. Store Listing Preparation

#### Google Play Store
- [ ] Create store listing
- [ ] Upload screenshots (min 2, recommended 8)
- [ ] Write app description (4000 char max)
- [ ] Set short description (80 char max)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload app icon (512x512)
- [ ] Complete Data Safety form
- [ ] Set content rating
- [ ] Set pricing (Free)
- [ ] Select countries
- [ ] Add privacy policy URL
- [ ] Add terms of service URL

#### Apple App Store
- [ ] Create App Store Connect listing
- [ ] Upload screenshots for all device sizes
  - iPhone 6.7" (1290x2796)
  - iPhone 6.5" (1284x2778)
  - iPhone 5.5" (1242x2208)
  - iPad Pro 12.9" (2048x2732)
- [ ] Write app description
- [ ] Add keywords
- [ ] Upload preview video (optional)
- [ ] Set age rating
- [ ] Add privacy policy URL
- [ ] Complete App Privacy section
- [ ] Set pricing (Free)
- [ ] Select territories

### 8. Backend Configuration
- [ ] Verify Hygraph API endpoint is production-ready
- [ ] Confirm backend API is deployed and accessible
- [ ] Test all API endpoints
- [ ] Set up error monitoring (optional: Sentry, Firebase)
- [ ] Set up analytics (optional: Firebase Analytics)

### 9. Security Audit
- [ ] Verify key.properties is in .gitignore
- [ ] Confirm no hardcoded secrets in code
- [ ] Check ProGuard rules are working
- [ ] Verify SSL/TLS for all API calls
- [ ] Test deep link security

### 10. Final Checks
- [ ] App version updated in pubspec.yaml
- [ ] Build number incremented
- [ ] Release notes prepared
- [ ] Tested on different screen sizes
- [ ] Verified both light and dark themes
- [ ] All placeholder text removed
- [ ] All debug logs removed/gated
- [ ] Crash reporting configured (recommended)

---

## 📝 NOTES

### Current Configuration Status
- **Razorpay**: TEST mode (waiting for production approval)
- **Shiprocket**: TEST credentials configured
- **Payment Gateway**: Backend integration ready
- **App Signing**: Configured for Android
- **iOS Signing**: Needs Xcode configuration

### Known Limitations
1. Using test payment gateway - will be updated upon Razorpay approval
2. Shiprocket using test environment
3. Privacy Policy and Terms need to be hosted on actual domain

### Contact Information to Update
Before launch, update these placeholders:
- Support email: support@dream247.shop
- Privacy email: privacy@dream247.shop
- Support phone: +91 9876543210
- Website URL: https://dream247.shop

---

## 🎯 ESTIMATED TIMELINE

- **Testing Phase**: 3-5 days
- **Store Submission Prep**: 2-3 days
- **Store Review Wait**: 1-7 days (Google), 1-3 days (Apple)
- **Total to Launch**: ~2 weeks

---

## 🆘 SUPPORT RESOURCES

- Flutter Deployment Docs: https://docs.flutter.dev/deployment
- Play Console Help: https://support.google.com/googleplay/android-developer
- App Store Connect Help: https://developer.apple.com/app-store-connect/
- Razorpay Docs: https://razorpay.com/docs/
- Shiprocket API Docs: https://apidocs.shiprocket.in/

---

**Last Updated**: January 3, 2026
**App Version**: 2.0.0+2
