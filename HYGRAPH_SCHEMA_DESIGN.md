# Hygraph Schema Design for Address, Order, and Payment Management

This document provides the complete Hygraph schema that needs to be added to your Hygraph project.

---

## 📋 Schema Overview

Add the following models to your Hygraph schema:

1. **Address** - User shipping/billing addresses
2. **Order** - Customer orders
3. **OrderItem** - Items within an order
4. **Payment** - Payment records

---

## 🔧 Schema Definitions

### 1. Address Model

```graphql
type Address @model {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  
  # Address fields
  fullName: String!
  phoneNumber: String!
  pincode: String!
  addressLine1: String!
  addressLine2: String
  city: String!
  state: String!
  country: String! @default(value: "India")
  isDefault: Boolean! @default(value: false)
  
  # Timestamps
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}

# Add relation to UserDetail
# In UserDetail model, add:
# addresses: [Address!]! @relation
```

### 2. Order Model

```graphql
enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

type Order @model {
  id: ID! @id
  orderNumber: String! @unique
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  
  # Order items
  items: [OrderItem!]! @relation
  
  # Amounts
  totalAmount: Float!
  
  # Status
  status: OrderStatus! @default(value: PENDING)
  
  # Shipping info
  shippingAddress: Address @relation(fields: [shippingAddressId], references: [id])
  shippingAddressId: ID
  
  # Tracking info
  trackingNumber: String
  courierName: String
  shiprocketOrderId: String
  
  # Timestamps
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}

# Add relation to UserDetail
# In UserDetail model, add:
# orders: [Order!]! @relation
```

### 3. OrderItem Model

```graphql
type OrderItem @model {
  id: ID! @id
  order: Order! @relation(fields: [orderId], references: [id])
  orderId: ID!
  
  # Product info
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  
  # Size (optional)
  size: Size @relation(fields: [sizeId], references: [id])
  sizeId: ID
  
  # Quantities and prices
  quantity: Int!
  pricePerUnit: Float!
  totalPrice: Float!
}
```

### 4. Payment Model

```graphql
enum PaymentStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  CANCELLED
  REFUNDED
}

type Payment @model {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  
  # Razorpay info
  razorpayOrderId: String!
  razorpayPaymentId: String
  
  # Payment details
  amount: Float!
  currency: String! @default(value: "INR")
  status: PaymentStatus! @default(value: PENDING)
  method: String # card, upi, wallet, netbanking, etc.
  
  # Related order (optional, for wallet top-ups this may be null)
  order: Order @relation(fields: [orderId], references: [id])
  orderId: ID
  
  # Timestamps
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}

# Add relation to UserDetail
# In UserDetail model, add:
# payments: [Payment!]! @relation

# Add relation to Order
# In Order model, add:
# payments: [Payment!]! @relation
```

---

## 🔄 Complete Schema with Relations

Here's how to add relations to existing models:

### Update UserDetail Model

Add these fields to your existing `UserDetail` model:

```graphql
type UserDetail @model {
  # ... existing fields ...
  
  # New relations
  addresses: [Address!]! @relation
  orders: [Order!]! @relation
  payments: [Payment!]! @relation
}
```

### Update Product Model (if not already connected)

Ensure Product model has relation for OrderItem:

```graphql
type Product @model {
  # ... existing fields ...
  
  # Add this if not present
  orderItems: [OrderItem!]! @relation
}
```

### Update Size Model (if not already connected)

Ensure Size model has relation for OrderItem:

```graphql
type Size @model {
  # ... existing fields ...
  
  # Add this if not present
  orderItems: [OrderItem!]! @relation
}
```

---

## 📝 Step-by-Step Setup in Hygraph Dashboard

### Step 1: Create Address Model

1. Go to **Schema** → **Models** → **Add Model**
2. Name: `Address`
3. Add fields:
   - `fullName` (Single line text, Required)
   - `phoneNumber` (Single line text, Required)
   - `pincode` (Single line text, Required)
   - `addressLine1` (Single line text, Required)
   - `addressLine2` (Single line text, Optional)
   - `city` (Single line text, Required)
   - `state` (Single line text, Required)
   - `country` (Single line text, Required, Default: "India")
   - `isDefault` (Boolean, Required, Default: false)
   - `createdAt` (DateTime, Auto-generated)
   - `updatedAt` (DateTime, Auto-generated)
4. Add Relation: `userDetail` → `UserDetail` (One-to-Many)

### Step 2: Create OrderItem Model

1. Add Model: `OrderItem`
2. Add fields:
   - `quantity` (Integer, Required)
   - `pricePerUnit` (Float, Required)
   - `totalPrice` (Float, Required)
3. Add Relations:
   - `order` → `Order` (Many-to-One)
   - `product` → `Product` (Many-to-One)
   - `size` → `Size` (Many-to-One, Optional)

### Step 3: Create Order Model

1. Add Model: `Order`
2. Add fields:
   - `orderNumber` (Single line text, Required, Unique)
   - `totalAmount` (Float, Required)
   - `status` (Enum, Required, Default: PENDING)
     - Values: PENDING, CONFIRMED, PROCESSING, SHIPPED, DELIVERED, CANCELLED, REFUNDED
   - `trackingNumber` (Single line text, Optional)
   - `courierName` (Single line text, Optional)
   - `shiprocketOrderId` (Single line text, Optional)
   - `createdAt` (DateTime, Auto-generated)
   - `updatedAt` (DateTime, Auto-generated)
3. Add Relations:
   - `userDetail` → `UserDetail` (Many-to-One)
   - `items` → `OrderItem` (One-to-Many)
   - `shippingAddress` → `Address` (Many-to-One, Optional)
   - `payments` → `Payment` (One-to-Many, Optional)

### Step 4: Create Payment Model

1. Add Model: `Payment`
2. Add fields:
   - `razorpayOrderId` (Single line text, Required)
   - `razorpayPaymentId` (Single line text, Optional)
   - `amount` (Float, Required)
   - `currency` (Single line text, Required, Default: "INR")
   - `status` (Enum, Required, Default: PENDING)
     - Values: PENDING, PROCESSING, COMPLETED, FAILED, CANCELLED, REFUNDED
   - `method` (Single line text, Optional)
   - `createdAt` (DateTime, Auto-generated)
   - `updatedAt` (DateTime, Auto-generated)
3. Add Relations:
   - `userDetail` → `UserDetail` (Many-to-One)
   - `order` → `Order` (Many-to-One, Optional)

### Step 5: Update Existing Models

#### Update UserDetail:
1. Go to **UserDetail** model
2. Add Relations:
   - `addresses` → `Address` (One-to-Many)
   - `orders` → `Order` (One-to-Many)
   - `payments` → `Payment` (One-to-Many)

#### Update Product (if needed):
1. Go to **Product** model
2. Add Relation:
   - `orderItems` → `OrderItem` (One-to-Many)

#### Update Size (if needed):
1. Go to **Size** model
2. Add Relation:
   - `orderItems` → `OrderItem` (One-to-Many)

---

## 🔐 Permissions Setup

### For Each Model, Enable:

1. **Public Content API** (for queries):
   - ✅ Read permissions for:
     - Address (filtered by userId)
     - Order (filtered by userId)
     - OrderItem (through Order)
     - Payment (filtered by userId)

2. **Content API** (for mutations):
   - ✅ Create, Update, Delete permissions for:
     - Address
     - Order
     - OrderItem (created through Order)
     - Payment

**Important**: Configure permission filters to ensure users can only access their own data:

- Address: `{ userDetail: { id: { equals: $userId } } }`
- Order: `{ userDetail: { id: { equals: $userId } } }`
- Payment: `{ userDetail: { id: { equals: $userId } } }`

---

## 📊 Schema Relationships Diagram

```
UserDetail
├── addresses: [Address]
├── orders: [Order]
└── payments: [Payment]

Order
├── userDetail: UserDetail
├── items: [OrderItem]
├── shippingAddress: Address?
└── payments: [Payment]?

OrderItem
├── order: Order
├── product: Product
└── size: Size?

Payment
├── userDetail: UserDetail
└── order: Order?

Address
└── userDetail: UserDetail
```

---

## ⚠️ Important Notes

1. **OrderItem Creation**: Orders are created in two steps:
   - First, create the Order (without items)
   - Then, create each OrderItem separately (linked to the order)
   - Finally, publish both Order and OrderItems
   
   This approach is used because Hygraph may not support nested array creates in all configurations.
   
   ```graphql
   # Step 1: Create order
   mutation {
     createOrder(data: {
       orderNumber: "ORD123456"
       userDetail: { connect: { id: "user-id" } }
       totalAmount: 1000.0
       status: CONFIRMED
     }) { id }
   }
   
   # Step 2: Create order items (repeat for each item)
   mutation {
     createOrderItem(data: {
       order: { connect: { id: "order-id" } }
       product: { connect: { id: "product-id" } }
       size: { connect: { id: "size-id" } }
       quantity: 2
       pricePerUnit: 100.0
       totalPrice: 200.0
     }) { id }
   }
   ```

2. **Publishing**: After creating/updating records, remember to publish them:
   ```graphql
   mutation PublishOrder($id: ID!) {
     publishOrder(where: { id: $id }) { id }
   }
   ```

3. **Unique Constraints**: `orderNumber` in Order should be unique.

4. **Defaults**: Set appropriate defaults for:
   - `country` in Address → "India"
   - `isDefault` in Address → false
   - `status` in Order → PENDING
   - `status` in Payment → PENDING
   - `currency` in Payment → "INR"

---

## ✅ Verification Checklist

After adding the schema:

- [ ] Address model created with all fields
- [ ] OrderItem model created with relations
- [ ] Order model created with enum and relations
- [ ] Payment model created with enum and relations
- [ ] UserDetail model updated with new relations
- [ ] Product model has orderItems relation (if needed)
- [ ] Size model has orderItems relation (if needed)
- [ ] Permissions configured for all models
- [ ] Test creating an address
- [ ] Test creating an order
- [ ] Test creating a payment record

---

## 🔄 Migration from In-Memory to GraphQL

If you're migrating from the existing in-memory `OrderService`:

1. Update `OrderService` to use `OrderServiceGraphQL` methods
2. Or create a hybrid service that syncs between local and GraphQL
3. Update screens to use the new GraphQL-based services

---

*This schema design ensures proper relationships, data integrity, and efficient queries while maintaining flexibility for future enhancements.*
