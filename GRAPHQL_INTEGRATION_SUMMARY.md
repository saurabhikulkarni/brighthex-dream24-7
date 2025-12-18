# GraphQL Integration Summary - Wallet & Wishlist Services

## ✅ Completed Tasks

### 1. **WalletService Conversion to GraphQL** ✅
**File:** [lib/services/wallet_service.dart](lib/services/wallet_service.dart)

**Changes Made:**
- Removed all REST API dependencies (`http`, `dart:convert`)
- Added GraphQL client initialization: `final GraphQLClient _graphQLClient = GraphQLService.getClient();`
- Replaced token-based authentication with user ID stored in SharedPreferences
- Converted all wallet operations to GraphQL mutations:

| Method | GraphQL Query/Mutation | Status |
|--------|------------------------|--------|
| `getBalance()` | Uses local cache + `getUserWallet` query for sync | ✅ |
| `setBalance(amount)` | Local cache only | ✅ |
| `addBalance(amount)` | `updateUserWallet` mutation | ✅ |
| `deductBalance(amount)` | `updateUserWallet` mutation | ✅ |
| `syncWithBackend()` | `getUserWallet` query | ✅ |
| `addMoneyViaPayment()` | `updateUserWallet` mutation | ✅ |
| `deductForPurchase()` | `updateUserWallet` mutation | ✅ |
| `setUserId(userId)` | Stores userId in SharedPreferences | ✅ |
| `clear()` | Clears all wallet data on logout | ✅ |

**New Features:**
- User ID storage in SharedPreferences for backend sync
- Automatic cache sync with `getBalance()`
- GraphQL error handling with `result.hasException`
- Proper variable mapping to Hygraph schema (`walletBalance` parameter)

---

### 2. **WishlistService Conversion to GraphQL** ✅
**File:** [lib/services/wishlist_service.dart](lib/services/wishlist_service.dart)

**Changes Made:**
- Removed all REST API dependencies (`http`, `dart:convert`, `auth_service`)
- Added GraphQL client initialization: `final GraphQLClient _graphQLClient = GraphQLService.getClient();`
- Replaced token-based authentication with user ID
- Converted backend sync operations to GraphQL queries/mutations:

| Method | GraphQL Query/Mutation | Status |
|--------|------------------------|--------|
| `addToWishlist(product)` | Local cache only | ✅ |
| `removeFromWishlist(productId)` | Local cache only | ✅ |
| `isInWishlist(productId)` | In-memory check | ✅ |
| `getWishlist()` | Local in-memory list | ✅ |
| `toggleWishlist(product)` | Toggles local cache | ✅ |
| `syncWithBackend()` | `getUserWishlist` query | ✅ |
| `addToWishlistOnBackend(productId)` | `addToWishlist` mutation | ✅ |
| `removeFromWishlistOnBackend(productId)` | `removeFromWishlist` mutation | ✅ |
| `setUserId(userId)` | Stores userId in SharedPreferences | ✅ |
| `clear()` | Clears wishlist on logout | ✅ |

**Architecture Preserved:**
- Maintains in-memory caching of wishlist items
- Keeps local SharedPreferences synchronization
- Hybrid approach: Local operations + Backend sync

---

### 3. **GraphQL Queries Added** ✅
**File:** [lib/services/graphql_queries.dart](lib/services/graphql_queries.dart)

**New Queries & Mutations:**

```graphql
# Query: Get user wallet balance
query GetUserWallet($userId: ID!) {
  userDetail(where: {id: $userId}) {
    id
    walletBalance
  }
}

# Mutation: Update wallet balance
mutation UpdateUserWallet($userId: ID!, $walletBalance: Float!) {
  updateUserDetail(
    where: {id: $userId}
    data: {walletBalance: $walletBalance}
  ) {
    id
    walletBalance
  }
}

# Query: Get user wishlist
query GetUserWishlist($userId: ID!) {
  userDetail(where: {id: $userId}) {
    id
    wishlist {
      id
      title
      slug
      description
      price
      discountPercent
      rating
      isInStock
      productImage { url }
    }
  }
}

# Mutation: Add to wishlist
mutation AddToWishlist($userId: ID!, $productId: ID!) {
  updateUserDetail(
    where: {id: $userId}
    data: {wishlist: {connect: {id: $productId}}}
  ) {
    id
    wishlist { id }
  }
}

# Mutation: Remove from wishlist
mutation RemoveFromWishlist($userId: ID!, $productId: ID!) {
  updateUserDetail(
    where: {id: $userId}
    data: {wishlist: {disconnect: {id: $productId}}}
  ) {
    id
    wishlist { id }
  }
}

# Query: Get complete user profile with wallet & wishlist
query GetUserProfile($userId: ID!) {
  userDetail(where: {id: $userId}) {
    id
    firstName
    lastName
    email
    username
    phone
    walletBalance
    wishlist {
      id
      title
      price
      productImage { url }
    }
  }
}
```

---

## 🔧 Integration Architecture

### Service Flow
```
Login Screen
    ↓
AuthService (stores userId in SharedPreferences)
    ↓
WalletService.setUserId(userId) + WishlistService.setUserId(userId)
    ↓
CartScreen/ProductScreen/WalletScreen
    ↓
Services use userId to call GraphQL mutations
    ↓
Hygraph Backend (GraphQL API)
```

### Data Flow
```
Frontend (Flutter)
    ↓
SharedPreferences (cache: wallet_balance, wishlist_items, user_id)
    ↓
WalletService/WishlistService (GraphQL mutations)
    ↓
Hygraph GraphQL Endpoint
    ↓
UserDetail Collection (walletBalance, wishlist relationship)
```

---

## ⚙️ Configuration

### GraphQL Client
- **Endpoint:** `https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master`
- **Package:** `graphql_flutter: ^5.1.2`
- **Client File:** [lib/services/graphql_client.dart](lib/services/graphql_client.dart)
- **Config File:** [lib/services/graphql_config.dart](lib/services/graphql_config.dart)

### SharedPreferences Keys
```dart
// WalletService
_walletBalanceKey = 'wallet_balance'
_walletTransactionsKey = 'wallet_transactions'
_userIdKey = 'user_id'

// WishlistService
_wishlistKey = 'wishlist_items'
_userIdKey = 'user_id'
```

---

## 📋 Required Hygraph Schema Updates

⚠️ **These changes must be made in Hygraph Dashboard:**

1. **Add `walletBalance` field to UserDetail model**
   - Type: Float
   - Default: 0
   - Required: No (optional)

2. **Add `wishlist` field to UserDetail model**
   - Type: Relation
   - Related Model: Product
   - Cardinality: Many-to-many
   - Display Name: "Wishlist"

3. **Verify Product Model has these fields** (should already exist):
   - `id`, `title`, `slug`, `description`, `price`
   - `discountPercent`, `rating`, `isInStock`, `productImage`

---

## 🧪 Testing Checklist

Before deploying, verify:

- [ ] User can login and userId is stored in SharedPreferences
- [ ] Wallet balance syncs from Hygraph backend
- [ ] Adding to wallet updates both local cache and GraphQL backend
- [ ] Deducting from wallet works correctly
- [ ] Wishlist items sync from Hygraph
- [ ] Adding/removing wishlist items updates backend
- [ ] Logout clears all wallet and wishlist data
- [ ] No "User ID not found" errors appear in logs
- [ ] GraphQL queries return valid data from Hygraph

---

## ⚠️ Important Notes

1. **User ID Storage:** Services require userId stored in SharedPreferences. This must be set during login:
   ```dart
   final userId = authService.getCurrentUserId();
   await walletService.setUserId(userId);
   await wishlistService.setUserId(userId);
   ```

2. **Hygraph Schema:** Wallet and wishlist features will fail without the schema updates in Hygraph.

3. **Error Handling:** All GraphQL errors are logged to console. Check logs for debugging.

4. **Local Cache:** WalletService and WishlistService maintain local caches for offline support.

5. **Removed Dependencies:** 
   - No longer uses `http` package for auth/wallet/wishlist
   - No longer uses REST API pattern
   - Uses GraphQL for all backend operations

---

## 📁 Files Modified

| File | Changes |
|------|---------|
| [lib/services/wallet_service.dart](lib/services/wallet_service.dart) | Complete GraphQL conversion |
| [lib/services/wishlist_service.dart](lib/services/wishlist_service.dart) | Complete GraphQL conversion |
| [lib/services/graphql_queries.dart](lib/services/graphql_queries.dart) | Added 6 wallet/wishlist queries |
| [lib/services/auth_service.dart](lib/services/auth_service.dart) | Added GraphQL client, updated fetchUserProfile() |
| [lib/services/graphql_client.dart](lib/services/graphql_client.dart) | Pre-existing, verified working |

---

## 🚀 Next Steps

1. **Update Hygraph Schema** (done in Hygraph dashboard)
2. **Implement Login Flow** with userId storage
3. **Update Login Screens** to work with new Hygraph user structure
4. **Create Mutation for OTP/Login** in Hygraph
5. **Test all wallet/wishlist operations**

---

**Status:** ✅ GraphQL Integration Complete - Awaiting Hygraph Schema Updates
