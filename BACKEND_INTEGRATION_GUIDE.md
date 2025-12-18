# Backend Integration Guide - Wishlist & Wallet Balance Persistence

## Overview

This guide explains how to integrate the frontend wallet and wishlist services with your backend. The frontend has been updated to support:

1. **WalletService** - Persistent wallet balance management with backend sync
2. **WishlistService** - Backend synchronization for wishlist items
3. **AuthService** - Enhanced to store wallet balance and auth token

## Configuration

### 1. Update Backend URL

In the following files, replace `https://your-backend.com` with your actual backend URL:

**Files to update:**
- `lib/services/auth_service.dart` (line 17)
- `lib/services/wallet_service.dart` (line 14)
- `lib/services/wishlist_service.dart` (line 9)

Example:
```dart
static const String _baseUrl = 'https://api.myapp.com';
```

## Backend API Endpoints Required

### Authentication Endpoints

#### 1. Login with OTP Verification
**Endpoint:** `POST /api/auth/login`

**Request:**
```json
{
  "phone": "+919876543210",
  "otp": "123456",
  "name": "User Name"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "user_123",
    "phone": "+919876543210",
    "name": "User Name",
    "walletBalance": 100.0,
    "wishlist": [
      {
        "id": "prod_1",
        "title": "Product Name",
        "price": 99.99,
        "image": "image_url"
      }
    ]
  },
  "token": "jwt_token_here"
}
```

### Wallet Endpoints

#### 1. Get User Wallet
**Endpoint:** `GET /api/users/wallet`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Response:**
```json
{
  "walletBalance": 100.0,
  "currency": "INR"
}
```

#### 2. Add Money to Wallet
**Endpoint:** `POST /api/users/wallet/add`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request:**
```json
{
  "amount": 500.0,
  "paymentId": "razorpay_payment_123"
}
```

**Response:**
```json
{
  "walletBalance": 600.0,
  "transaction": {
    "id": "txn_123",
    "type": "credit",
    "amount": 500.0,
    "timestamp": "2024-01-01T10:00:00Z"
  }
}
```

#### 3. Deduct from Wallet (for purchases)
**Endpoint:** `POST /api/users/wallet/deduct`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request:**
```json
{
  "amount": 100.0,
  "orderId": "order_123"
}
```

**Response:**
```json
{
  "walletBalance": 500.0,
  "transaction": {
    "id": "txn_124",
    "type": "debit",
    "amount": 100.0,
    "timestamp": "2024-01-01T10:05:00Z"
  }
}
```

### Wishlist Endpoints

#### 1. Get User Wishlist
**Endpoint:** `GET /api/users/wishlist`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Response:**
```json
{
  "wishlist": [
    {
      "id": "prod_1",
      "title": "Product Name",
      "price": 99.99,
      "image": "image_url",
      "category": "category"
    }
  ]
}
```

#### 2. Add to Wishlist
**Endpoint:** `POST /api/users/wishlist/add`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Request:**
```json
{
  "productId": "prod_123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Added to wishlist"
}
```

#### 3. Remove from Wishlist
**Endpoint:** `DELETE /api/users/wishlist/{productId}`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "message": "Removed from wishlist"
}
```

### User Profile Endpoint

#### Get Full User Profile
**Endpoint:** `GET /api/users/profile`

**Headers:**
```
Authorization: Bearer {auth_token}
Content-Type: application/json
```

**Response:**
```json
{
  "id": "user_123",
  "phone": "+919876543210",
  "name": "User Name",
  "email": "user@example.com",
  "walletBalance": 100.0,
  "wishlist": [
    {
      "id": "prod_1",
      "title": "Product Name",
      "price": 99.99,
      "image": "image_url"
    }
  ]
}
```

## Frontend Service Usage

### AuthService

```dart
import 'package:shop/services/auth_service.dart';

final authService = AuthService();

// Save login session with wallet balance
await authService.saveLoginSessionWithToken(
  phone: '+919876543210',
  name: 'User Name',
  phoneVerified: true,
  walletBalance: 100.0,
  authToken: 'jwt_token',
);

// Get wallet balance
final balance = await authService.getWalletBalance();

// Update wallet balance
await authService.updateWalletBalance(150.0);

// Fetch user profile from backend (updates local wallet balance)
final userProfile = await authService.fetchUserProfile();

// Logout
await authService.logout();
```

### WalletService

```dart
import 'package:shop/services/wallet_service.dart';

final walletService = WalletService();

// Get current balance
final balance = await walletService.getBalance();

// Set balance
await walletService.setBalance(100.0);

// Add balance
await walletService.addBalance(50.0);

// Deduct balance
final success = await walletService.deductBalance(30.0);

// Check sufficient balance
final hasSufficient = await walletService.hasSufficientBalance(50.0);

// Sync with backend
await walletService.syncWithBackend();

// Add money via payment
await walletService.addMoneyViaPayment(
  amount: 500.0,
  paymentId: 'razorpay_payment_123',
);

// Deduct for purchase
final success = await walletService.deductForPurchase(
  amount: 100.0,
  orderId: 'order_123',
);
```

### WishlistService

```dart
import 'package:shop/services/wishlist_service.dart';

final wishlistService = WishlistService();

// Initialize wishlist from local storage
await wishlistService.initialize();

// Get all wishlist items
final wishlist = wishlistService.getWishlist();

// Add to wishlist
await wishlistService.addToWishlist(product);

// Remove from wishlist
await wishlistService.removeFromWishlist(productId);

// Toggle wishlist
final added = await wishlistService.toggleWishlist(product);

// Check if in wishlist
final isInWishlist = wishlistService.isInWishlist(productId);

// Sync with backend
await wishlistService.syncWithBackend();

// Add to wishlist on backend
await wishlistService.addToWishlistOnBackend(productId);

// Remove from wishlist on backend
await wishlistService.removeFromWishlistOnBackend(productId);

// Clear wishlist (logout)
await wishlistService.clear();
```

## Login Flow Integration

Update your login screen to properly sync with backend:

```dart
// After OTP verification succeeds
Future<void> _handleLoginSuccess(String phone, String name, String otp) async {
  try {
    // Call backend login API
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      final token = data['token'];

      // Save session with wallet balance
      await authService.saveLoginSessionWithToken(
        phone: phone,
        name: name,
        phoneVerified: true,
        walletBalance: user['walletBalance']?.toDouble() ?? 0.0,
        authToken: token,
      );

      // Sync wishlist from backend
      if (user['wishlist'] != null) {
        // Load wishlist into WishlistService
        await wishlistService.syncWithBackend();
      }

      // Navigate to home
      Navigator.of(context).pushReplacementNamed(homeRoute);
    }
  } catch (e) {
    print('Login error: $e');
  }
}
```

## Logout Flow

```dart
Future<void> handleLogout() async {
  // Clear auth session
  await authService.logout();
  
  // Clear wallet
  await walletService.clear();
  
  // Clear wishlist
  await wishlistService.clear();
  
  // Navigate to login
  Navigator.of(context).pushReplacementNamed(loginRoute);
}
```

## Testing Checklist

- [ ] Update backend URL in all service files
- [ ] Implement all required API endpoints
- [ ] Test login flow with wallet balance sync
- [ ] Test wallet balance persistence after app restart
- [ ] Test wallet deduction for purchases
- [ ] Test wallet top-up via Razorpay integration
- [ ] Test wishlist sync on login
- [ ] Test add/remove wishlist items
- [ ] Test logout clears all local data
- [ ] Test network error handling
- [ ] Test insufficient wallet balance dialog

## Error Handling

All services have built-in error handling with logging:

```dart
try {
  final balance = await walletService.getBalance();
} catch (e) {
  print('Error getting balance: $e');
  // Handle error gracefully
}
```

## SharedPreferences Keys

The following keys are used for local persistence:

**AuthService:**
- `is_logged_in` - Boolean
- `user_phone` - String
- `user_name` - String
- `phone_verified` - Boolean
- `wallet_balance` - Double
- `auth_token` - String
- `last_login` - ISO DateTime string

**WalletService:**
- `wallet_balance` - Double
- `wallet_transactions` - String (JSON)

**WishlistService:**
- `wishlist_items` - List of JSON strings

## Data Synchronization Strategy

1. **On Login:** Fetch user profile with wallet balance and wishlist from backend
2. **On Logout:** Clear all local data
3. **On Wallet Update:** Sync immediately with backend
4. **On Wishlist Change:** Sync immediately with backend (optional - can batch updates)
5. **On App Restart:** Load from local storage, optionally refresh from backend

This ensures data consistency between frontend and backend while providing offline capability.
