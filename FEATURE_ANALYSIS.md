# Feature Analysis & Backend Implementation Guide

This document provides a comprehensive analysis of implemented features, backend requirements, and missing features.

---

## ✅ Fully Implemented Features (Frontend + Backend)

### 1. **Product Management** ✅
- **Status**: Fully implemented with GraphQL/Hygraph
- **Frontend**: ✅ Complete
- **Backend**: ✅ Hygraph GraphQL API
- **Features**:
  - Fetch all products
  - Fetch product by ID
  - Fetch products by category
  - Search products
  - Product images, descriptions, pricing
  - Category management
  - Size management

**Files**:
- `lib/services/product_service.dart`
- `lib/services/graphql_queries.dart`
- `lib/models/product_model.dart`

---

### 2. **User Authentication (OTP-based)** ✅
- **Status**: Frontend ready, needs backend API
- **Frontend**: ✅ Complete (MSG91 integration ready)
- **Backend**: ⚠️ **REQUIRED** - MSG91 OTP API endpoints
- **Features**:
  - OTP sending via MSG91
  - OTP verification
  - User registration/login
  - Session management (SharedPreferences)
  - Mobile number validation

**Backend Requirements**:
- ✅ `POST /api/auth/send-otp` - Send OTP to mobile
- ✅ `POST /api/auth/verify-otp` - Verify OTP
- ⚠️ MSG91 API key integration
- ⚠️ OTP session storage (Redis recommended)

**Files**:
- `lib/services/msg91_service.dart`
- `lib/services/auth_service.dart`
- `lib/config/msg91_config.dart`
- `lib/screens/auth/views/`

**Documentation**: `MSG91_BACKEND_SETUP.md`

---

### 3. **User Wallet & Balance** ✅
- **Status**: Fully implemented with GraphQL
- **Frontend**: ✅ Complete
- **Backend**: ✅ Hygraph GraphQL mutations
- **Features**:
  - Get wallet balance
  - Add balance (via Razorpay)
  - Deduct balance (on purchase)
  - Update balance in GraphQL
  - Wallet UI with transaction display

**GraphQL Mutations**:
- `getUserWallet` - Get balance
- `addWalletBalance` - Increment balance
- `deductWalletBalance` - Decrement balance
- `updateWalletBalance` - Set balance

**Files**:
- `lib/services/user_service.dart`
- `lib/services/graphql_queries.dart`
- `lib/screens/wallet/views/wallet_screen.dart`

---

### 4. **Cart Management** ✅
- **Status**: Frontend + Local storage ready, GraphQL sync available
- **Frontend**: ✅ Complete
- **Backend**: ⚠️ GraphQL mutations exist but need publishing
- **Features**:
  - Add to cart (local + GraphQL)
  - Update quantity
  - Remove items
  - Cart total calculation
  - Local persistence (SharedPreferences)

**GraphQL Queries/Mutations**:
- ✅ `getCartByUser` - Fetch user cart
- ✅ `createCartItem` - Add item
- ✅ `updateCartItem` - Update quantity
- ✅ `deleteCartItem` - Remove item
- ⚠️ `publishCart` - Required for Hygraph

**Files**:
- `lib/services/cart_service.dart`
- `lib/screens/checkout/views/cart_screen.dart`

---

### 5. **Wishlist** ✅
- **Status**: Fully implemented with GraphQL
- **Frontend**: ✅ Complete
- **Backend**: ✅ Hygraph GraphQL
- **Features**:
  - Add to wishlist
  - Remove from wishlist
  - Sync with backend
  - Local cache

**GraphQL Queries/Mutations**:
- ✅ `getUserWishlist` - Fetch wishlist
- ✅ `addToWishlist` - Add item
- ✅ `removeFromWishlist` - Remove item

**Files**:
- `lib/services/wishlist_service.dart`
- `lib/screens/wishlist/views/wishlist_screen.dart`

---

### 6. **Order Management** ⚠️
- **Status**: Frontend ready, backend persistence needed
- **Frontend**: ✅ Complete
- **Backend**: ⚠️ **REQUIRED** - Order persistence & management
- **Features**:
  - Order creation
  - Order tracking (Shiprocket integration ready)
  - Order status management
  - Order history
  - Local in-memory storage (not persistent)

**Backend Requirements**:
- ⚠️ Order persistence in database/GraphQL
- ⚠️ Order status updates
- ⚠️ Order history API
- ✅ Shiprocket tracking (API ready)

**Files**:
- `lib/services/order_service.dart`
- `lib/screens/order/views/orders_screen.dart`
- `lib/screens/order/views/order_tracking_screen.dart`

**Note**: Currently using in-memory storage. Orders are lost on app restart.

---

### 7. **Payment Gateway (Razorpay)** ⚠️
- **Status**: Frontend ready, backend verification needed
- **Frontend**: ✅ Complete
- **Backend**: ⚠️ **REQUIRED** - Payment order creation & signature verification
- **Features**:
  - Payment initiation
  - Payment success/error handling
  - Payment UI

**Backend Requirements**:
- ⚠️ `POST /api/payments/create-order` - Create Razorpay order
- ⚠️ `POST /api/payments/verify-signature` - Verify payment signature
- ⚠️ Store payment records
- ⚠️ Handle webhooks (optional but recommended)

**Files**:
- `lib/services/razorpay_service.dart`
- `lib/config/razorpay_config.dart`
- `lib/screens/checkout/views/payment_method_selection_screen.dart`

**Note**: Razorpay Key Secret should be on backend, not frontend.

---

### 8. **Shiprocket Integration** ✅
- **Status**: Fully implemented
- **Frontend**: ✅ Complete
- **Backend**: ✅ Direct API calls (credentials in config)
- **Features**:
  - Order tracking
  - Tracking by AWB
  - Delivery partner details
  - Tracking history
  - Mock fallback for testing

**Files**:
- `lib/services/shiprocket_service.dart`
- `lib/config/shiprocket_config.dart`
- `lib/screens/order/views/order_tracking_screen.dart`

---

## ⚠️ Partially Implemented Features

### 9. **Search Functionality** ⚠️
- **Status**: Basic implementation, needs enhancement
- **Frontend**: ✅ UI exists
- **Backend**: ✅ GraphQL query exists
- **Missing**:
  - Search filters (price, size, brand, etc.)
  - Search history
  - Search suggestions
  - Advanced search

**Files**:
- `lib/services/search_service.dart`
- `lib/screens/search/views/search_screen.dart`
- GraphQL: `searchProducts` query exists

---

### 10. **Address Management** ⚠️
- **Status**: UI exists, no backend integration
- **Frontend**: ✅ UI screens exist
- **Backend**: ❌ **REQUIRED**
- **Missing**:
  - Save addresses to backend
  - Address CRUD operations
  - Default address selection
  - Address validation

**Files**:
- `lib/screens/address/views/addresses_screen.dart`
- `lib/screens/address/views/add_address_screen.dart`

**Backend Requirements**:
- ⚠️ Address model in Hygraph/Backend
- ⚠️ CRUD APIs for addresses
- ⚠️ Address validation (pincode API integration)

---

### 11. **Payment History** ⚠️
- **Status**: UI exists, no backend data
- **Frontend**: ✅ UI screen exists
- **Backend**: ❌ **REQUIRED**
- **Missing**:
  - Payment record storage
  - Payment history API
  - Payment details view

**Files**:
- `lib/screens/checkout/views/payment_history_screen.dart`
- `lib/models/payment_model.dart`

**Backend Requirements**:
- ⚠️ Payment record storage
- ⚠️ `GET /api/payments/history` - Fetch payment history
- ⚠️ `GET /api/payments/:id` - Get payment details

---

### 12. **Transaction History (Wallet)** ⚠️
- **Status**: UI exists, no backend data
- **Frontend**: ✅ UI components exist (dummy data)
- **Backend**: ❌ **REQUIRED**
- **Missing**:
  - Transaction record storage
  - Transaction history API
  - Transaction types (top-up, purchase, refund)

**Files**:
- `lib/screens/wallet/views/wallet_screen.dart`
- `lib/screens/wallet/views/components/transaction_history_card.dart`

**Backend Requirements**:
- ⚠️ Transaction model in Hygraph/Backend
- ⚠️ `GET /api/wallet/transactions` - Fetch transaction history
- ⚠️ Transaction creation on wallet operations

---

## ❌ Missing Features

### 13. **Reviews & Ratings** ❌
- **Status**: Not implemented
- **Frontend**: ❌ Missing
- **Backend**: ❌ Missing
- **Required**:
  - Product reviews UI
  - Rating system (1-5 stars)
  - Review submission
  - Review display on product page
  - Backend storage for reviews

**Files**: None (needs to be created)
- `lib/screens/reviews/view/product_reviews_screen.dart` (exists but not functional)

---

### 14. **User Profile Management** ⚠️
- **Status**: UI exists, partial backend
- **Frontend**: ✅ UI exists
- **Backend**: ⚠️ GraphQL queries exist, mutations needed
- **Missing**:
  - Update profile (name, email, etc.)
  - Profile picture upload
  - Email/phone verification
  - Profile settings

**Files**:
- `lib/screens/profile/views/profile_screen.dart`
- `lib/screens/user_info/views/user_info_screen.dart`

**Backend Requirements**:
- ⚠️ `updateUserProfile` mutation
- ⚠️ Profile picture storage (cloud storage)
- ⚠️ Email/phone verification

---

### 15. **Notifications** ⚠️
- **Status**: UI exists, no backend
- **Frontend**: ✅ UI screens exist
- **Backend**: ❌ **REQUIRED**
- **Missing**:
  - Push notification setup (FCM)
  - Notification storage
  - Notification preferences
  - Notification API

**Files**:
- `lib/screens/notification/view/notificatios_screen.dart`
- `lib/screens/notification/view/enable_notification_screen.dart`

**Backend Requirements**:
- ⚠️ FCM server setup
- ⚠️ Notification storage
- ⚠️ `GET /api/notifications` - Fetch notifications
- ⚠️ `POST /api/notifications/mark-read` - Mark as read

---

### 16. **Returns & Refunds** ❌
- **Status**: UI exists, no functionality
- **Frontend**: ✅ UI screens exist
- **Backend**: ❌ **REQUIRED**
- **Missing**:
  - Return request creation
  - Return status tracking
  - Refund processing
  - Return reason management

**Files**:
- `lib/screens/returns/views/returns_screen.dart`
- `lib/screens/product/views/product_returns_screen.dart`

**Backend Requirements**:
- ⚠️ Return request model
- ⚠️ Return request API
- ⚠️ Refund processing (Razorpay integration)
- ⚠️ Return status tracking

---

### 17. **Order Cancellation** ⚠️
- **Status**: UI exists, partial implementation
- **Frontend**: ✅ UI exists
- **Backend**: ⚠️ Needs backend confirmation
- **Missing**:
  - Cancel order API
  - Refund processing on cancellation
  - Cancellation reason tracking

**Files**:
- `lib/services/order_service.dart` (has `cancelOrder` method - local only)

**Backend Requirements**:
- ⚠️ `POST /api/orders/:id/cancel` - Cancel order
- ⚠️ Refund wallet balance on cancellation
- ⚠️ Cancellation reason storage

---

## 📋 Backend Implementation Summary

### ✅ Already Implemented (Hygraph GraphQL)
1. Product CRUD operations
2. Category management
3. Size management
4. User wallet balance (queries & mutations)
5. Cart operations (queries & mutations exist)
6. Wishlist operations (queries & mutations)

### ⚠️ Needs Backend API Implementation

#### High Priority
1. **MSG91 OTP Service** (Required for authentication)
   - `POST /api/auth/send-otp`
   - `POST /api/auth/verify-otp`
   - See: `MSG91_BACKEND_SETUP.md`

2. **Razorpay Payment Service** (Required for payments)
   - `POST /api/payments/create-order`
   - `POST /api/payments/verify-signature`
   - Payment record storage
   - Payment history API

3. **Order Management** (Required for order persistence)
   - Order storage in database/GraphQL
   - Order status updates
   - Order history API
   - Order cancellation API

4. **Address Management** (Required for checkout)
   - Address CRUD operations
   - Address validation
   - Default address selection

#### Medium Priority
5. **Transaction History** (Wallet)
   - Transaction record storage
   - Transaction history API

6. **Payment History**
   - Payment record storage
   - Payment history API

7. **User Profile Updates**
   - Update profile mutations
   - Profile picture upload

8. **Returns & Refunds**
   - Return request API
   - Refund processing

#### Low Priority
9. **Notifications**
   - FCM setup
   - Notification storage & API

10. **Reviews & Ratings**
    - Review submission API
    - Review storage

---

## 🔧 Backend Architecture Recommendations

### Option 1: Hybrid (Recommended)
- **Hygraph GraphQL** for:
  - Products, Categories, Sizes
  - User data (name, email, wallet balance)
  - Cart, Wishlist
- **Custom Backend API** (Node.js/Express or Python/Flask) for:
  - OTP services (MSG91)
  - Payment processing (Razorpay)
  - Order management
  - Address management
  - Notifications
  - Transaction history

### Option 2: Full GraphQL Backend
- Use Hygraph Functions/Actions for:
  - OTP services
  - Payment processing
  - External API integrations

### Option 3: Full Custom Backend
- Replace Hygraph with custom GraphQL/REST API
- More control but more development time

---

## 📝 Next Steps Checklist

### Immediate (Critical)
- [ ] Set up MSG91 backend API (see `MSG91_BACKEND_SETUP.md`)
- [ ] Update `lib/config/msg91_config.dart` with backend URL
- [ ] Update Hygraph schema: Add `mobileNumber` field, remove `password`
- [ ] Set up Razorpay backend API for order creation & signature verification
- [ ] Update `lib/services/razorpay_service.dart` with backend URLs

### Short Term
- [ ] Implement order persistence (database/GraphQL)
- [ ] Create address management APIs
- [ ] Implement transaction history storage
- [ ] Add payment history storage

### Medium Term
- [ ] User profile update APIs
- [ ] Returns & refunds APIs
- [ ] Notification service setup
- [ ] Review & rating system

### Long Term
- [ ] Advanced search with filters
- [ ] Analytics & reporting
- [ ] Admin dashboard
- [ ] Email notifications
- [ ] SMS notifications (beyond OTP)

---

## 📚 Documentation References

- `MSG91_BACKEND_SETUP.md` - MSG91 OTP backend setup
- `SHIPROCKET_SETUP.md` - Shiprocket integration guide
- `GRAPHQL_SETUP.md` - Hygraph GraphQL setup
- `RAZORPAY_INTEGRATION.md` - Razorpay integration (if exists)

---

## 🔐 Security Considerations

### Frontend (Flutter)
- ✅ No API keys stored (except Razorpay Key ID which is safe)
- ✅ API calls go through backend
- ✅ Input validation implemented

### Backend (To Implement)
- ⚠️ Store MSG91 API key securely (environment variables)
- ⚠️ Store Razorpay Key Secret securely
- ⚠️ Implement rate limiting on OTP endpoints
- ⚠️ Validate all inputs
- ⚠️ Use HTTPS only in production
- ⚠️ Implement proper error handling
- ⚠️ Log security events
- ⚠️ Verify payment signatures server-side

---

## 📊 Implementation Status Summary

| Feature | Frontend | Backend | Status |
|---------|----------|---------|--------|
| Products | ✅ | ✅ | Complete |
| Authentication | ✅ | ⚠️ | Needs MSG91 backend |
| Wallet | ✅ | ✅ | Complete |
| Cart | ✅ | ⚠️ | Needs publishing |
| Wishlist | ✅ | ✅ | Complete |
| Orders | ✅ | ❌ | Needs persistence |
| Razorpay | ✅ | ❌ | Needs backend API |
| Shiprocket | ✅ | ✅ | Complete |
| Address | ✅ | ❌ | Needs backend |
| Search | ⚠️ | ✅ | Basic only |
| Reviews | ❌ | ❌ | Not implemented |
| Notifications | ✅ | ❌ | Needs backend |
| Returns | ✅ | ❌ | Needs backend |
| Profile | ✅ | ⚠️ | Needs mutations |
| Transactions | ✅ | ❌ | Needs backend |

**Legend**:
- ✅ Complete
- ⚠️ Partial
- ❌ Missing

---

*Last Updated: Based on current codebase analysis*
