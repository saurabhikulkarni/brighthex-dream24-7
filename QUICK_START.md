# Quick Start Checklist - Backend Integration

## ✅ Frontend Implementation - COMPLETE

### Services Created/Updated
- [x] **WalletService** - Full wallet management with SharedPreferences persistence
- [x] **AuthService** - Enhanced with wallet balance and auth token storage
- [x] **WishlistService** - Backend sync capabilities added
- [x] **CartScreen** - Updated to use WalletService instead of hardcoded 500
- [x] **ProductBuyNowScreen** - Updated to use WalletService instead of hardcoded 500
- [x] **WalletScreen** - Enhanced to persist balance changes

### Documentation
- [x] **BACKEND_INTEGRATION_GUIDE.md** - Complete API specifications
- [x] **IMPLEMENTATION_SUMMARY.md** - Summary of all changes

## ⚙️ Configuration Required (DO THIS FIRST)

### Step 1: Update Backend URLs

**File 1:** `lib/services/auth_service.dart` (line 17)
```dart
// BEFORE:
static const String _baseUrl = 'https://your-backend.com';

// AFTER:
static const String _baseUrl = 'https://your-actual-api.com';
```

**File 2:** `lib/services/wallet_service.dart` (line 14)
```dart
static const String _baseUrl = 'https://your-actual-api.com';
```

**File 3:** `lib/services/wishlist_service.dart` (line 9)
```dart
static const String _baseUrl = 'https://your-actual-api.com';
```

## 🔌 Backend Setup Required

### Create These API Endpoints

**Priority 1 (Critical for login):**
```
POST   /api/auth/login                    (returns token + user with walletBalance)
GET    /api/users/profile                 (returns full user profile)
```

**Priority 2 (Critical for wallet):**
```
GET    /api/users/wallet                  (get balance)
POST   /api/users/wallet/add              (add money via payment)
POST   /api/users/wallet/deduct           (deduct for purchase)
```

**Priority 3 (Critical for wishlist):**
```
GET    /api/users/wishlist                (get wishlist items)
POST   /api/users/wishlist/add            (add product to wishlist)
DELETE /api/users/wishlist/{productId}    (remove from wishlist)
```

See **BACKEND_INTEGRATION_GUIDE.md** for complete endpoint specifications.

## 🧪 Testing Sequence

### Test 1: Login Flow
```
1. Open app → Login screen
2. Enter valid phone number
3. Verify OTP
4. Backend returns JWT token + user with walletBalance
5. AuthService saves token + wallet to SharedPreferences
6. App navigates to home screen
7. Check: wallet balance displayed in header
```

### Test 2: Wallet Persistence
```
1. User logged in with wallet balance = 100
2. Open CartScreen → Verify wallet shows 100
3. Open ProductScreen → Verify wallet shows 100
4. Open WalletScreen → Verify wallet shows 100
5. Add money in WalletScreen (e.g., +50) → balance = 150
6. Close app completely
7. Reopen app → wallet still shows 150 ✓
```

### Test 3: Purchase with Wallet
```
1. User has wallet balance = 100
2. Add product (price: 30) to cart
3. Proceed to checkout
4. Check: shows insufficient tokens dialog if balance < price
5. Confirm purchase
6. Check: wallet deducts correctly = 70
7. Backend receives deduction request ✓
8. Order created successfully ✓
```

### Test 4: Wishlist Sync
```
1. User logged in
2. Backend has wishlist: [product_1, product_2]
3. On login, WishlistService.syncWithBackend() called
4. App loads wishlist items from SharedPreferences
5. Open product page, toggle wishlist
6. Check: item added/removed from both local + backend ✓
```

### Test 5: Logout
```
1. User logged in with wallet = 100 + wishlist items
2. Tap logout button
3. Check: all SharedPreferences keys cleared
4. Navigate to login screen
5. Login with different account
6. Check: new user's wallet/wishlist loaded ✓
```

## 📱 User Flow (How it Works)

### Login
```
User enters phone + OTP
       ↓
Backend verifies OTP
       ↓
Backend returns: {user, token, walletBalance, wishlist}
       ↓
Frontend saves to SharedPreferences
       ↓
WalletService initialized with balance
WishlistService synced with items
       ↓
User navigates to home
```

### Shopping
```
User adds product to cart
       ↓
Checkout screen loads wallet balance from WalletService
       ↓
User confirms purchase
       ↓
Frontend calls: walletService.deductBalance(amount)
       ↓
WalletService checks balance
       ↓
If sufficient: calls backend POST /api/users/wallet/deduct
              updates SharedPreferences
              creates order
       ↓
If insufficient: shows dialog to add more tokens
```

### Adding Funds
```
User in WalletScreen, enters amount
       ↓
Clicks "Add Money"
       ↓
Razorpay payment initiated
       ↓
Payment successful → razorpay returns paymentId
       ↓
Frontend calls: walletService.addMoneyViaPayment(amount, paymentId)
       ↓
Backend validates payment + adds to wallet
       ↓
Returns new balance
       ↓
WalletService updates SharedPreferences
       ↓
Balance displayed in UI
```

## 🐛 Debugging Tips

### Check if wallet is loading:
```dart
// In any screen:
final balance = await walletService.getBalance();
print('Wallet Balance: $balance');
```

### Check if auth token is saving:
```dart
final token = await authService.getAuthToken();
print('Auth Token: $token');
```

### Check SharedPreferences directly:
```dart
// In debug console:
final prefs = await SharedPreferences.getInstance();
print(prefs.getDouble('wallet_balance'));
print(prefs.getString('auth_token'));
print(prefs.getStringList('wishlist_items'));
```

### Monitor API calls:
```dart
// All services log errors:
// "Error fetching user profile: ..."
// "Error syncing wallet with backend: ..."
```

## 📋 Implementation Checklist

### Frontend (✓ Done)
- [x] WalletService created
- [x] AuthService enhanced
- [x] WishlistService enhanced
- [x] CartScreen fixed
- [x] ProductBuyNowScreen fixed
- [x] WalletScreen fixed
- [x] All files compile without errors
- [x] Documentation created

### Backend (⚠️ TODO)
- [ ] User schema includes walletBalance field
- [ ] User schema includes wishlist array
- [ ] POST /api/auth/login implemented
- [ ] GET /api/users/profile implemented
- [ ] GET /api/users/wallet implemented
- [ ] POST /api/users/wallet/add implemented
- [ ] POST /api/users/wallet/deduct implemented
- [ ] GET /api/users/wishlist implemented
- [ ] POST /api/users/wishlist/add implemented
- [ ] DELETE /api/users/wishlist/{id} implemented

### Configuration (⚠️ TODO)
- [ ] Update backend URL in auth_service.dart
- [ ] Update backend URL in wallet_service.dart
- [ ] Update backend URL in wishlist_service.dart

### Testing (⚠️ TODO)
- [ ] Test login flow
- [ ] Test wallet persistence
- [ ] Test purchase deduction
- [ ] Test wishlist sync
- [ ] Test logout
- [ ] Test offline mode (optional)

## 🚀 Ready to Deploy?

**Yes, if:**
- ✅ All backend endpoints are implemented
- ✅ Backend URLs are configured
- ✅ All tests pass
- ✅ Production backend is ready

**No, if:**
- ❌ Backend endpoints incomplete
- ❌ Backend URLs not configured
- ❌ Tests failing

## 📞 Support Resources

- **Backend Integration Guide:** `BACKEND_INTEGRATION_GUIDE.md`
- **Implementation Summary:** `IMPLEMENTATION_SUMMARY.md`
- **Service Examples:** See inline comments in service files

## Quick Code Examples

### Get wallet balance
```dart
import 'package:shop/services/wallet_service.dart';

final balance = await walletService.getBalance();
print('Balance: \$${balance.toStringAsFixed(2)}');
```

### Deduct from wallet
```dart
final success = await walletService.deductBalance(100.0);
if (success) {
  print('Purchase successful!');
} else {
  print('Insufficient balance');
}
```

### Check if logged in and get wallet
```dart
final isLoggedIn = await authService.isLoggedIn();
if (isLoggedIn) {
  final balance = await authService.getWalletBalance();
  print('User balance: $balance');
}
```

### Sync with backend
```dart
final success = await walletService.syncWithBackend();
if (success) {
  print('Synced with backend');
  final newBalance = await walletService.getBalance();
  print('New balance: $newBalance');
}
```

---

**Status:** ✅ Frontend Ready | ⚠️ Backend in Progress | ❌ Configuration Pending

**Next Action:** Implement backend endpoints according to BACKEND_INTEGRATION_GUIDE.md
