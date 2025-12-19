# Remaining Features & Tasks

This document lists what's still left to implement after completing Address, Order, and Payment Management.

---

## ✅ Recently Completed (Just Now)

1. **Address Management** ✅
   - Model, Service, GraphQL integration
   - CRUD operations
   - Default address handling

2. **Order Management** ✅
   - OrderModel, OrderItemModel
   - GraphQL service for orders
   - Order history, status updates

3. **Payment Records** ✅
   - Payment service with GraphQL
   - Payment history integration
   - Payment status tracking

---

## ⚠️ Still Needs Implementation

### 🔴 High Priority (Critical for Production)

#### 1. **Transaction History (Wallet)** ⚠️
- **Status**: UI exists, needs backend
- **What's Missing**:
  - Transaction model in Hygraph (mentioned in schema design but not implemented)
  - Transaction service to create records
  - Transaction history fetching from GraphQL
  - Integration with wallet operations

- **Files to Update**:
  - `lib/screens/wallet/views/wallet_screen.dart` - Currently shows dummy data
  - Create `lib/services/transaction_service.dart`
  - Add transaction GraphQL queries/mutations

- **Backend Requirements**:
  - Add Transaction model to Hygraph schema
  - Create transaction records when:
    - Wallet top-up occurs
    - Purchase is made
    - Refund is processed
  - Query transaction history

**Estimated Effort**: 2-3 hours

---

#### 2. **MSG91 Backend API** 🔴 CRITICAL
- **Status**: Frontend ready, backend server needed
- **What's Missing**:
  - Node.js/Express backend server
  - MSG91 API integration
  - OTP session management (Redis)
  - Rate limiting

- **Documentation**: `MSG91_BACKEND_SETUP.md` (already created)

- **Required Endpoints**:
  - `POST /api/auth/send-otp`
  - `POST /api/auth/verify-otp`

- **Update**: `lib/config/msg91_config.dart` with backend URL

**Estimated Effort**: 4-6 hours (backend setup)

---

#### 3. **Razorpay Backend API** 🔴 CRITICAL
- **Status**: Frontend ready, backend verification needed
- **What's Missing**:
  - Backend server for payment order creation
  - Payment signature verification (HMAC-SHA256)
  - Webhook handling (optional)

- **Required Endpoints**:
  - `POST /api/payments/create-order` - Create Razorpay order
  - `POST /api/payments/verify-signature` - Verify payment
  - `POST /api/payments/webhook` - Handle webhooks (optional)

- **Update**: `lib/services/razorpay_service.dart` to use backend URLs

**Estimated Effort**: 3-4 hours (backend setup)

---

### 🟡 Medium Priority

#### 4. **Reviews & Ratings** ❌
- **Status**: Not implemented
- **What's Missing**:
  - Review model in Hygraph
  - Review service
  - Review UI components
  - Product reviews display
  - Review submission form

- **Files to Create**:
  - `lib/models/review_model.dart`
  - `lib/services/review_service.dart`
  - `lib/screens/reviews/views/product_reviews_screen.dart` (update existing)
  - Review components

- **Backend Requirements**:
  - Review model in Hygraph schema
  - GraphQL queries/mutations for reviews

**Estimated Effort**: 4-5 hours

---

#### 5. **User Profile Updates** ⚠️
- **Status**: UI exists, mutations needed
- **What's Missing**:
  - Update profile mutation in GraphQL
  - Profile picture upload (needs cloud storage)
  - Email/phone verification

- **Files to Update**:
  - `lib/services/user_service.dart` - Add update methods
  - `lib/screens/profile/views/profile_screen.dart`
  - `lib/screens/user_info/views/user_info_screen.dart`

- **Backend Requirements**:
  - `updateUserProfile` mutation in Hygraph
  - Profile picture storage (Cloudinary/AWS S3)
  - Store image URL in Hygraph

**Estimated Effort**: 2-3 hours

---

#### 6. **Returns & Refunds** ⚠️
- **Status**: UI exists, no functionality
- **What's Missing**:
  - Return request model in Hygraph
  - Return service
  - Refund processing (Razorpay integration)
  - Return status tracking

- **Files to Update**:
  - `lib/screens/returns/views/returns_screen.dart`
  - Create `lib/services/return_service.dart`
  - Create `lib/models/return_model.dart`

- **Backend Requirements**:
  - Return model in Hygraph schema
  - Refund processing via Razorpay backend
  - Return status updates

**Estimated Effort**: 5-6 hours

---

#### 7. **Order Cancellation with Refunds** ⚠️
- **Status**: Partial (local only)
- **What's Missing**:
  - Cancel order via GraphQL
  - Automatic refund to wallet
  - Cancellation reason tracking
  - Refund transaction record

- **Files to Update**:
  - `lib/services/order_service_graphql.dart` - Already has `cancelOrder()` but needs refund logic
  - Add refund processing

- **Backend Requirements**:
  - Update order status to CANCELLED
  - Refund wallet balance
  - Create refund transaction record

**Estimated Effort**: 2-3 hours

---

### 🟢 Low Priority

#### 8. **Notifications** ⚠️
- **Status**: UI exists, no backend
- **What's Missing**:
  - FCM (Firebase Cloud Messaging) setup
  - Notification storage in Hygraph
  - Notification service
  - Push notification sending

- **Files to Update**:
  - `lib/screens/notification/view/notificatios_screen.dart`
  - Create `lib/services/notification_service.dart`

- **Backend Requirements**:
  - FCM server setup (Node.js backend)
  - Notification model in Hygraph
  - Notification API endpoints

**Estimated Effort**: 6-8 hours

---

#### 9. **Search Enhancements** ⚠️
- **Status**: Basic search exists
- **What's Missing**:
  - Search filters (price range, size, brand)
  - Search history
  - Search suggestions
  - Advanced search UI

- **Files to Update**:
  - `lib/screens/search/views/search_screen.dart`
  - `lib/services/search_service.dart`

**Estimated Effort**: 3-4 hours

---

## 📋 Hygraph Schema Still Needed

### Already Added (Just Now):
- ✅ Address model
- ✅ Order model
- ✅ OrderItem model
- ✅ Payment model

### Still Needed:
- [ ] **Transaction model** - For wallet transaction history
- [ ] **Review model** - For product reviews
- [ ] **Return model** - For return requests
- [ ] **Notification model** - For push notifications (optional)

---

## 🎯 Recommended Implementation Order

### Phase 1: Critical Backend Services (1-2 weeks)
1. **MSG91 Backend API** - Required for authentication
2. **Razorpay Backend API** - Required for payments
3. **Transaction History** - Complete wallet feature

### Phase 2: Core Features (1 week)
4. **Order Cancellation with Refunds** - Complete order flow
5. **User Profile Updates** - Basic profile management
6. **Reviews & Ratings** - Product feedback

### Phase 3: Advanced Features (1-2 weeks)
7. **Returns & Refunds** - Return management
8. **Notifications** - Push notifications
9. **Search Enhancements** - Better search experience

---

## 📊 Summary Table

| Feature | Status | Priority | Estimated Time |
|---------|--------|----------|----------------|
| Transaction History | ⚠️ UI only | 🔴 High | 2-3 hours |
| MSG91 Backend | ❌ Missing | 🔴 Critical | 4-6 hours |
| Razorpay Backend | ❌ Missing | 🔴 Critical | 3-4 hours |
| Reviews & Ratings | ❌ Missing | 🟡 Medium | 4-5 hours |
| Profile Updates | ⚠️ Partial | 🟡 Medium | 2-3 hours |
| Returns & Refunds | ⚠️ UI only | 🟡 Medium | 5-6 hours |
| Order Cancellation | ⚠️ Partial | 🟡 Medium | 2-3 hours |
| Notifications | ⚠️ UI only | 🟢 Low | 6-8 hours |
| Search Enhancements | ⚠️ Basic | 🟢 Low | 3-4 hours |

**Total Estimated Time**: ~30-40 hours

---

## ✅ What's Already Complete

1. ✅ Product Management (GraphQL)
2. ✅ Category Management (GraphQL)
3. ✅ Cart Management (GraphQL + Local)
4. ✅ Wishlist (GraphQL)
5. ✅ Wallet Balance (GraphQL)
6. ✅ Shiprocket Integration
7. ✅ Address Management (GraphQL) - **Just completed**
8. ✅ Order Management (GraphQL) - **Just completed**
9. ✅ Payment Records (GraphQL) - **Just completed**

---

## 🚀 Next Immediate Steps

1. **Add Transaction model to Hygraph** (30 min)
   - Follow `HYGRAPH_SCHEMA_DESIGN.md` Transaction model section
   - Add GraphQL queries/mutations
   - Create transaction service
   - Update wallet screen

2. **Set up MSG91 Backend** (4-6 hours)
   - Follow `MSG91_BACKEND_SETUP.md`
   - Deploy backend server
   - Update `msg91_config.dart`

3. **Set up Razorpay Backend** (3-4 hours)
   - Create payment endpoints
   - Deploy backend server
   - Update Razorpay service

---

*This list will be updated as features are completed.*
