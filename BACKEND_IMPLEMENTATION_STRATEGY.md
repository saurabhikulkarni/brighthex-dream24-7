# Backend Implementation Strategy

This document clarifies what can be implemented in the Flutter codebase vs what requires a separate backend server, and how Hygraph can be utilized.

---

## 🎯 Quick Decision Matrix

| Feature | Flutter Direct | Hygraph GraphQL | Separate Backend Server | Why? |
|---------|---------------|-----------------|------------------------|------|
| **MSG91 OTP** | ❌ | ⚠️ Possible* | ✅ **REQUIRED** | API key security, rate limiting |
| **Razorpay Payments** | ❌ | ❌ | ✅ **REQUIRED** | Key Secret security, signature verification |
| **Order Storage** | ⚠️ Local only | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence across devices |
| **Address Management** | ⚠️ Local only | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence across devices |
| **Transaction History** | ⚠️ Local only | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence |
| **Payment History** | ⚠️ Local only | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence |
| **Cart Sync** | ⚠️ Local only | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence |
| **User Profile Updates** | ❌ | ✅ **RECOMMENDED** | ✅ Alternative | Needs persistence |
| **Returns/Refunds** | ❌ | ✅ **RECOMMENDED** | ✅ Alternative | Business logic + persistence |
| **Notifications** | ⚠️ Client-side only | ❌ | ✅ **REQUIRED** | FCM server setup needed |
| **Reviews** | ❌ | ✅ **RECOMMENDED** | ✅ Alternative | Simple CRUD |

*Hygraph Functions/Actions could theoretically handle MSG91, but it's complex and not recommended.

---

## ✅ Can Be Done in Flutter Codebase (Client-Side Only)

### What Works:
- **Local Data Storage**: SharedPreferences, Hive, SQLite
- **GraphQL Queries/Mutations**: Direct calls to Hygraph
- **UI Logic**: All UI operations
- **Client-Side Validation**: Input validation, formatting

### Limitations:
- ❌ Cannot securely store API keys
- ❌ Cannot verify payment signatures (HMAC-SHA256 requires secret key)
- ❌ Cannot implement rate limiting
- ❌ Cannot handle webhooks
- ❌ Data stored locally is lost when app is uninstalled
- ❌ No server-side business logic enforcement

---

## ✅ Can Be Done with Hygraph GraphQL (Recommended for Data)

### What Hygraph Excels At:
1. **Data Persistence & CRUD Operations**
   - Products ✅ (already implemented)
   - Categories ✅ (already implemented)
   - Users & User Profiles ✅ (partial)
   - Cart Items ✅ (mutations exist, need publishing)
   - Wishlist ✅ (already implemented)
   - Orders ✅ (can be added)
   - Addresses ✅ (can be added)
   - Reviews ✅ (can be added)
   - Transactions ✅ (can be added)
   - Payment Records ✅ (can be added)

### Hygraph Schema Requirements:

#### Order Model (for Hygraph)
```graphql
type Order {
  id: ID! @id
  orderNumber: String! @unique
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  items: [OrderItem!]!
  totalAmount: Float!
  status: OrderStatus!
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
  shippingAddress: Address
  trackingNumber: String
  courierName: String
  shiprocketOrderId: String
}

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

type OrderItem {
  id: ID! @id
  order: Order! @relation(fields: [orderId], references: [id])
  orderId: ID!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  size: Size @relation(fields: [sizeId], references: [id])
  sizeId: ID
  quantity: Int!
  pricePerUnit: Float!
  totalPrice: Float!
}
```

#### Address Model (for Hygraph)
```graphql
type Address {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  fullName: String!
  phoneNumber: String!
  pincode: String!
  addressLine1: String!
  addressLine2: String
  city: String!
  state: String!
  country: String! @default(value: "India")
  isDefault: Boolean! @default(value: false)
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}
```

#### Transaction Model (for Hygraph)
```graphql
type Transaction {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  type: TransactionType!
  amount: Float!
  description: String!
  referenceId: String # Order ID, Payment ID, etc.
  createdAt: DateTime! @createdAt
}

enum TransactionType {
  TOP_UP
  PURCHASE
  REFUND
  CANCELLATION_REFUND
}
```

#### Payment Record Model (for Hygraph)
```graphql
type Payment {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  razorpayOrderId: String!
  razorpayPaymentId: String
  amount: Float!
  currency: String! @default(value: "INR")
  status: PaymentStatus!
  method: String # card, upi, wallet, etc.
  order: Order @relation(fields: [orderId], references: [id])
  orderId: ID
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}

enum PaymentStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  CANCELLED
  REFUNDED
}
```

#### Review Model (for Hygraph)
```graphql
type Review {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  rating: Int! # 1-5
  title: String
  comment: String
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
  isPublished: Boolean! @default(value: false)
}
```

### Hygraph Limitations:
- ❌ Cannot directly call external APIs (MSG91, Razorpay) - Need Functions/Actions*
- ❌ Cannot verify payment signatures server-side
- ❌ Complex business logic is better in backend
- ⚠️ Webhooks handling is limited

*Hygraph Functions/Actions exist but are complex for production OTP/payment flows.

---

## ❌ REQUIRES Separate Backend Server (Node.js/Python/Express/Flask)

### Critical Features (Must Have Backend):

#### 1. **MSG91 OTP Service** 🔴 CRITICAL
**Why Backend Required:**
- MSG91 API key **MUST** be kept secret (never in frontend)
- Rate limiting needed (prevent abuse)
- Session management (Redis)
- Input validation & security

**Implementation**: Node.js/Express recommended
- See: `MSG91_BACKEND_SETUP.md`

#### 2. **Razorpay Payment Processing** 🔴 CRITICAL
**Why Backend Required:**
- Razorpay Key Secret **MUST** be kept secret
- Payment signature verification (HMAC-SHA256) requires secret key
- Order creation should be server-side for security
- Webhook handling for payment status updates
- Refund processing

**Implementation**: Node.js/Express recommended

**Required Endpoints:**
```
POST /api/payments/create-order
POST /api/payments/verify-signature
POST /api/payments/webhook (Razorpay webhook endpoint)
POST /api/payments/refund
GET  /api/payments/:id
GET  /api/payments/history
```

#### 3. **Push Notifications (FCM)** 🔴 CRITICAL
**Why Backend Required:**
- Firebase Cloud Messaging server key must be secret
- Notification storage & management
- Sending notifications to devices
- Token management

**Implementation**: Node.js/Express with Firebase Admin SDK

---

## ⚠️ Can Use Either Hygraph OR Backend (Recommended: Hygraph)

These features can work with either approach, but **Hygraph is recommended** for simplicity:

### 1. **Order Management** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- Store orders in Hygraph
- Update status via mutations
- Query order history

**Hygraph Benefits:**
- No additional backend needed
- Direct Flutter integration
- Built-in versioning & publishing

**Backend Alternative:**
- More control
- Can add complex business logic
- But requires separate server

### 2. **Address Management** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- CRUD operations via mutations
- Store addresses per user

**Hygraph Benefits:**
- Simple schema
- Easy integration
- No backend needed

### 3. **Transaction History** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- Store transactions when wallet operations occur
- Query transaction history

**Hygraph Benefits:**
- Historical data persistence
- Easy queries
- No backend needed

### 4. **Payment History** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- Store payment records after Razorpay verification
- Query payment history

**Flow**:
1. Razorpay payment happens (backend verifies)
2. Backend creates payment record in Hygraph
3. Flutter queries from Hygraph

### 5. **Reviews & Ratings** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- Store reviews in Hygraph
- Query reviews for products

**Hygraph Benefits:**
- Simple CRUD
- No complex logic needed
- Easy integration

### 6. **User Profile Updates** ✅ Use Hygraph
- **Recommended**: Hygraph GraphQL
- Update mutations for user fields
- Profile picture: Use cloud storage (Cloudinary, AWS S3) + store URL in Hygraph

---

## 🏗️ Recommended Architecture

### Hybrid Approach (Best Balance)

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
               │                          │
    ┌──────────▼──────────┐    ┌─────────▼──────────┐
    │   Hygraph GraphQL   │    │  Backend Server    │
    │   (Data Storage)    │    │  (Node.js/Express) │
    ├─────────────────────┤    ├────────────────────┤
    │ • Products          │    │ • MSG91 OTP        │
    │ • Categories        │    │ • Razorpay         │
    │ • Users             │    │   - Create Order   │
    │ • Orders            │    │   - Verify Sig     │
    │ • Addresses         │    │   - Webhooks       │
    │ • Cart              │    │ • FCM Notifications│
    │ • Wishlist          │    │ • Rate Limiting    │
    │ • Transactions      │    │ • Security         │
    │ • Payments (records)│    │                    │
    │ • Reviews           │    │                    │
    └─────────────────────┘    └────────────────────┘
```

### Data Flow Examples:

#### Order Creation Flow:
```
1. User places order (Flutter)
   ↓
2. Create order in Hygraph (Flutter → Hygraph)
   ↓
3. Process payment (Flutter → Backend → Razorpay)
   ↓
4. Backend verifies payment signature
   ↓
5. Backend updates order status in Hygraph (Backend → Hygraph)
   OR
   Backend stores payment record in Hygraph (Backend → Hygraph)
   ↓
6. Flutter queries updated order (Flutter → Hygraph)
```

#### Wallet Top-up Flow:
```
1. User initiates top-up (Flutter)
   ↓
2. Create payment in backend (Flutter → Backend → Razorpay)
   ↓
3. Payment successful, backend verifies
   ↓
4. Backend adds balance to Hygraph (Backend → Hygraph mutation)
   ↓
5. Backend creates transaction record in Hygraph (Backend → Hygraph)
   ↓
6. Flutter refreshes wallet (Flutter → Hygraph query)
```

---

## 📋 Implementation Plan

### Phase 1: Use Hygraph (No Separate Backend Needed)
**Can be done immediately:**
- [ ] Add Order model to Hygraph schema
- [ ] Add Address model to Hygraph schema
- [ ] Add Transaction model to Hygraph schema
- [ ] Add Payment model to Hygraph schema (records only)
- [ ] Add Review model to Hygraph schema
- [ ] Create GraphQL mutations for all CRUD operations
- [ ] Update Flutter services to use Hygraph

### Phase 2: Minimal Backend Server (Critical Only)
**Must have for production:**
- [ ] Set up Node.js/Express server
- [ ] Implement MSG91 OTP endpoints
- [ ] Implement Razorpay payment endpoints
- [ ] Deploy backend server (Heroku, AWS, DigitalOcean, etc.)

### Phase 3: Enhanced Backend (Optional)
**If needed:**
- [ ] FCM notification service
- [ ] Advanced rate limiting
- [ ] Analytics & logging
- [ ] Webhook handlers
- [ ] Email services

---

## 🎯 Decision Guide

### Use Hygraph When:
✅ Simple CRUD operations
✅ Data persistence needed
✅ No external API keys required
✅ No complex server-side logic
✅ Want to avoid backend maintenance

### Use Backend Server When:
✅ External API integration (MSG91, Razorpay)
✅ API keys need to be kept secret
✅ Payment signature verification
✅ Rate limiting needed
✅ Complex business logic
✅ Webhooks handling
✅ Push notifications

### Use Both When:
✅ Hybrid approach (recommended)
✅ Backend handles secure operations
✅ Hygraph stores data
✅ Best of both worlds

---

## 💡 Practical Recommendations

### For Your Current Codebase:

1. **Immediate (Can Do Now with Hygraph):**
   - Add Order, Address, Transaction, Payment, Review models to Hygraph
   - Update Flutter services to use Hygraph mutations
   - Keep using Hygraph for all data storage

2. **Short Term (Need Backend Server):**
   - Set up minimal Node.js backend for MSG91 OTP
   - Set up Razorpay payment endpoints
   - Deploy backend (can use free tier: Heroku, Railway, Render)

3. **Long Term (Enhancement):**
   - Add FCM notifications
   - Add advanced features
   - Scale as needed

---

## 🔐 Security Best Practices

### What Goes Where:

**Flutter (Frontend):**
- ✅ Razorpay Key ID (safe to expose)
- ✅ GraphQL queries/mutations
- ✅ UI logic
- ❌ API keys/secrets
- ❌ Payment signature verification

**Hygraph:**
- ✅ Data storage
- ✅ GraphQL API
- ❌ External API calls (without Functions)
- ❌ Secret keys

**Backend Server:**
- ✅ MSG91 API key
- ✅ Razorpay Key Secret
- ✅ Payment signature verification
- ✅ Rate limiting
- ✅ Security logic

---

## 📊 Cost Considerations

### Hygraph:
- ✅ Free tier available
- ✅ Pay per API call
- ✅ No server maintenance

### Backend Server:
- ⚠️ Server hosting costs ($5-20/month)
- ⚠️ Maintenance required
- ✅ More control

### Recommendation:
- Start with Hygraph for data (free tier)
- Minimal backend for OTP/payments only (free tier hosting: Railway, Render)
- Scale as needed

---

## ✅ Final Recommendation

**Use Hybrid Approach:**
1. **Hygraph** for all data storage (Orders, Addresses, Transactions, Payments, Reviews)
2. **Minimal Backend Server** (Node.js/Express) for:
   - MSG91 OTP service
   - Razorpay payment processing
   - Payment verification

**Benefits:**
- ✅ Minimal backend code (easier to maintain)
- ✅ Leverage Hygraph's GraphQL features
- ✅ Secure API key handling
- ✅ Scalable architecture
- ✅ Cost-effective

---

*This strategy allows you to maximize Hygraph usage while keeping security-critical operations on your backend server.*
