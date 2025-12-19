# Razorpay Payment Integration Guide

Complete implementation guide for integrating Razorpay payment gateway into your Flutter e-commerce app for both Android and iOS devices.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup Instructions](#setup-instructions)
3. [File Structure](#file-structure)
4. [Implementation Details](#implementation-details)
5. [Android Setup](#android-setup)
6. [iOS Setup](#ios-setup)
7. [Backend Integration](#backend-integration)
8. [Testing](#testing)
9. [Go Live](#go-live)

---

## Prerequisites

- Razorpay account (sign up at https://razorpay.com)
- Flutter SDK installed
- Android Studio (for Android setup)
- Xcode (for iOS setup)
- Backend server (for payment verification)

---

## Setup Instructions

### Step 1: Create Razorpay Account

1. Visit https://razorpay.com
2. Sign up and create an account
3. Complete KYC verification
4. Go to Dashboard → Settings → API Keys
5. Copy your Key ID (public key) and Key Secret (private key)

### Step 2: Update Configuration

Edit `lib/config/razorpay_config.dart`:

```dart
static const String keyId = 'YOUR_RAZORPAY_KEY_ID';      // Paste your Key ID
static const String keySecret = 'YOUR_RAZORPAY_KEY_SECRET';  // Backend only!
```

### Step 3: Install Dependencies

All dependencies are already added to `pubspec.yaml`:
```yaml
razorpay_flutter: ^1.3.0
crypto: ^3.0.3
uuid: ^4.0.0
http: ^1.1.0
```

Run: `flutter pub get`

---

## File Structure

```
lib/
├── config/
│   └── razorpay_config.dart              # Razorpay API configuration
├── services/
│   └── razorpay_service.dart             # Razorpay SDK wrapper
├── models/
│   └── payment_model.dart                # Payment data models
└── screens/
    └── checkout/
        ├── components/
        │   └── payment_method_card.dart  # Payment UI components
        └── views/
            ├── payment_method_selection_screen.dart  # Select payment
            └── payment_history_screen.dart           # View payment history
```

---

## Implementation Details

### Payment Flow

```
User at Checkout Screen
    ↓
Tap "Pay Now" / "Proceed to Payment"
    ↓
Navigate to PaymentMethodSelectionScreen
    ↓
Select Payment Method (Card, UPI, NetBanking, etc)
    ↓
RazorpayService.startPayment()
    ↓
Razorpay Payment Modal Opens
    ↓
├─ Payment Successful → Show Success Dialog → Update Order
├─ Payment Failed → Show Error Dialog → Enable Retry
└─ User Cancels → Show Cancellation Message

Backend Verification:
├─ Generate Razorpay Order ID
├─ Verify Payment Signature (HMAC-SHA256)
├─ Update Payment Status in Database
└─ Return Success Response
```

### Supported Payment Methods

✅ **Cards**: Credit & Debit Cards
✅ **UPI**: Google Pay, PhonePe, PayTM, WhatsApp Pay
✅ **Net Banking**: All major banks
✅ **Wallets**: PayTM, AmazonPay, Mobikwik
✅ **EMI**: Flexible payment options

### Key Classes

**RazorpayService**
- `startPayment()` - Initiate payment
- `createOrder()` - Create order on backend
- `verifyPaymentSignature()` - Verify payment
- `getPaymentDetails()` - Fetch payment info
- `refundPayment()` - Process refunds

**PaymentModel**
- Stores payment information
- Enum: PaymentStatus (pending, processing, completed, failed, cancelled, refunded)
- Enum: PaymentMethod (creditCard, debitCard, upi, wallet, etc)

---

## Android Setup

### 1. Update AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application>
        <!-- ... existing code ... -->
        
        <!-- Add Razorpay Activity (if using older version) -->
        <activity
            android:name="com.razorpay.checkout.RazorpayActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="false" />
    </application>
</manifest>
```

### 2. Update build.gradle (App Level)

File: `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        
        // Add Razorpay dependency
        dependencies {
            implementation 'com.razorpay:checkout:1.6.40'
        }
    }
}
```

### 3. Proguard Rules (if using ProGuard)

Add to `android/app/proguard-rules.pro`:

```proguard
# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
```

---

## iOS Setup

### 1. Update Podfile

File: `ios/Podfile`

Uncomment and update platform:

```ruby
platform :ios, '12.0'
```

Add after `pod 'Flutter'`:

```ruby
pod 'razorpay_flutter'
```

Run: `cd ios && pod install && cd ..`

### 2. Update Info.plist

File: `ios/Runner/Info.plist`

Add these keys:

```xml
<dict>
    <!-- ... existing keys ... -->
    
    <!-- Razorpay URL Scheme -->
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
    
    <!-- Allow arbitrary loads for API calls -->
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
</dict>
```

### 3. Update iOS Runner Configuration

File: `ios/Runner.xcodeproj/project.pbxproj` (via Xcode is easier)

In Xcode:
1. Select Runner
2. Select Runner target
3. Build Settings → Search "URL Schemes"
4. Add: `razorapishop`

### 4. Update AppDelegate

File: `ios/Runner/GeneratedPluginRegistrant.h`

Should be auto-generated, but verify it includes:
```objc
#import <razorpay_flutter/RazorpayFlutterPlugin.h>
```

---

## Backend Integration

### Create Order (Backend API)

**Endpoint**: `POST /api/payments/create-order`

```javascript
// Node.js + Express Example
const crypto = require('crypto');
const axios = require('axios');

app.post('/api/payments/create-order', async (req, res) => {
  try {
    const { amount, receipt, notes } = req.body;
    
    const response = await axios.post(
      'https://api.razorpay.com/v1/orders',
      {
        amount: Math.round(amount * 100), // Convert to paise
        currency: 'INR',
        receipt: receipt,
        notes: notes,
      },
      {
        auth: {
          username: process.env.RAZORPAY_KEY_ID,
          password: process.env.RAZORPAY_KEY_SECRET,
        },
      }
    );

    res.json({
      success: true,
      data: response.data,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message,
    });
  }
});
```

### Verify Payment Signature (Backend API)

**Endpoint**: `POST /api/payments/verify-signature`

```javascript
app.post('/api/payments/verify-signature', (req, res) => {
  try {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;
    
    const message = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(message)
      .digest('hex');

    const isSignatureValid = expectedSignature === razorpay_signature;

    if (isSignatureValid) {
      // Update payment status in database
      // Create order/booking
      // Send confirmation email
      res.json({
        success: true,
        verified: true,
        message: 'Payment verified successfully',
      });
    } else {
      res.status(400).json({
        success: false,
        verified: false,
        message: 'Invalid signature',
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
```

### Webhook Handler (Receive Payment Updates)

**Endpoint**: `POST /api/webhooks/razorpay`

```javascript
app.post('/api/webhooks/razorpay', (req, res) => {
  try {
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
    const signature = req.headers['x-razorpay-signature'];
    
    // Verify webhook signature
    const message = JSON.stringify(req.body);
    const expectedSignature = crypto
      .createHmac('sha256', secret)
      .update(message)
      .digest('hex');

    if (signature !== expectedSignature) {
      return res.status(400).json({ error: 'Invalid signature' });
    }

    const event = req.body.event;
    const data = req.body.data.payment;

    switch (event) {
      case 'payment.authorized':
        // Handle authorized payment
        updatePaymentStatus(data.id, 'authorized');
        break;
      case 'payment.failed':
        // Handle failed payment
        updatePaymentStatus(data.id, 'failed');
        // Send failure notification
        break;
      case 'payment.captured':
        // Handle captured payment (funds received)
        updatePaymentStatus(data.id, 'captured');
        // Create order
        // Send success email
        break;
      case 'refund.created':
        // Handle refund
        updatePaymentStatus(data.id, 'refunded');
        break;
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});
```

### Setup Webhook in Razorpay Dashboard

1. Go to Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-backend.com/api/webhooks/razorpay`
3. Select events:
   - payment.authorized
   - payment.failed
   - payment.captured
   - refund.created
4. Copy Webhook Secret and add to `.env`

---

## Testing

### Test Card Numbers

**Visa**
- Number: 4111111111111111
- Expiry: Any future date
- CVV: Any 3 digits

**Mastercard**
- Number: 5555555555554444
- Expiry: Any future date
- CVV: Any 3 digits

**Failed Payment**
- Number: 4000000000000002
- Expiry: Any future date
- CVV: Any 3 digits

**UPI (Mock)**
- Enter: `success@razorpay` for successful payment
- Enter: `failure@razorpay` for failed payment

### Test on Emulator/Simulator

```bash
# Android
flutter run --debug

# iOS
flutter run -d 'iPhone 14 Pro' --debug
```

### Test Checklist

- [ ] Card payment successful
- [ ] UPI payment successful
- [ ] Net banking payment flow
- [ ] Payment failure handling
- [ ] Signature verification
- [ ] Success dialog display
- [ ] Error dialog with retry
- [ ] Payment history display
- [ ] Platform-specific behavior (Android)
- [ ] Platform-specific behavior (iOS)

---

## Go Live

### 1. Switch to Production

Update `lib/config/razorpay_config.dart`:

```dart
static const String environment = 'production';
static const String keyId = 'rzp_live_YOUR_LIVE_KEY_ID';
```

### 2. Security Checklist

- [ ] Never expose API Secret in frontend
- [ ] Always verify signatures on backend
- [ ] Use HTTPS for all API calls
- [ ] Enable webhook verification
- [ ] Implement proper error handling
- [ ] Add transaction logging
- [ ] Set up payment monitoring
- [ ] Configure alerts for failed payments

### 3. Backend Deployment

- [ ] Deploy backend with production credentials
- [ ] Update webhook URL to production
- [ ] Test webhook delivery
- [ ] Set up error logging
- [ ] Configure database backups
- [ ] Monitor API rate limits

### 4. App Store Submission

**iOS:**
1. Add `razorapishop` URL scheme to app
2. Submit to App Store
3. Verify payment testing on TestFlight

**Android:**
1. Generate release keystore
2. Sign APK/Bundle
3. Submit to Play Store
4. Test on Play Store internal testing

### 5. Post-Launch

- [ ] Monitor payment success rate
- [ ] Check for failed transactions
- [ ] Monitor webhook delivery
- [ ] Track customer support issues
- [ ] Analyze payment method preferences
- [ ] Optimize checkout flow

---

## API Reference

### RazorpayService Methods

#### startPayment()
```dart
await razorpayService.startPayment(
  orderId: '#12345',
  amount: 500.0,
  userEmail: 'user@example.com',
  userPhone: '+91 9876543210',
  userName: 'John Doe',
  onSuccess: (response) {
    // Handle success
  },
  onError: (error) {
    // Handle error
  },
  onDismiss: () {
    // Handle dismissal
  },
);
```

#### verifyPaymentSignature()
```dart
bool isVerified = await razorpayService.verifyPaymentSignature(
  paymentId: 'pay_123456',
  orderId: 'order_123456',
  signature: 'signature_hash',
);
```

#### getPaymentDetails()
```dart
PaymentModel? payment = await razorpayService.getPaymentDetails(
  paymentId: 'pay_123456',
);
```

#### refundPayment()
```dart
bool refundSuccess = await razorpayService.refundPayment(
  paymentId: 'pay_123456',
  amount: 500.0,
  reason: 'Customer requested refund',
);
```

---

## Troubleshooting

### Payment Modal Not Opening

**Solution:**
1. Verify Key ID is correct
2. Check internet connection
3. Ensure app is signed (Android)
4. Check URL scheme configuration (iOS)

### Signature Verification Failed

**Solution:**
1. Verify Key Secret on backend
2. Check order creation response
3. Ensure correct HMAC-SHA256 algorithm
4. Verify timestamp validity

### Webhook Not Received

**Solution:**
1. Check webhook URL in dashboard
2. Verify webhook secret
3. Check firewall/proxy settings
4. Review webhook logs in Razorpay dashboard

### iOS Build Fails

**Solution:**
1. Run `cd ios && pod install --repo-update && cd ..`
2. Update deployment target to iOS 12.0+
3. Clean build folder: `flutter clean`
4. Rebuild: `flutter pub get && flutter run`

### Android Build Fails

**Solution:**
1. Update Gradle: `flutter clean`
2. Check AndroidManifest.xml permissions
3. Verify build.gradle dependencies
4. Update compileSdkVersion to 34

---

## Support & Documentation

- **Razorpay Dashboard**: https://dashboard.razorpay.com
- **API Documentation**: https://razorpay.com/docs/api/
- **Flutter Plugin Repo**: https://github.com/razorpay/razorpay-flutter
- **Integration Guide**: https://razorpay.com/docs/payments/
- **Support Email**: support@razorpay.com

---

## Additional Resources

- [Razorpay Payment Gateway Overview](https://razorpay.com/docs/payments/)
- [Test Cases & Scenarios](https://razorpay.com/docs/payments/test-cases/)
- [Webhooks Documentation](https://razorpay.com/docs/webhooks/)
- [Payment Links](https://razorpay.com/docs/payment-links/)
- [Subscriptions](https://razorpay.com/docs/subscriptions/)

---

**Note**: Keep your API Secret and Webhook Secret secure. Never commit them to version control.
