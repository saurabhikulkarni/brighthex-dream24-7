# Complete Hygraph Schema for Node.js Backend

## All Models and Enums

```graphql
# ==========================================
# ENUMS
# ==========================================

enum OrderStatus {
  PENDING
  CONFIRMED
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

enum PaymentStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  CANCELLED
  REFUNDED
}

# ==========================================
# MODELS
# ==========================================

# Product Model
type Product @model {
  id: ID! @id
  productName: String!
  slug: String
  description: String
  price: Float!
  image: Asset
  category: Category @relation(fields: [categoryId], references: [id])
  categoryId: ID
  sizes: [Size!]!  # Reverse relation from Size
  carts: [Cart!]!  # Reverse relation from Cart
  wishlists: [Wishlist!]!  # Reverse relation from Wishlist
  orderItems: [OrderItem!]!  # Reverse relation from OrderItem
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Category Model
type Category @model {
  id: ID! @id
  categoryName: String!
  slug: String
  products: [Product!]!  # Reverse relation from Product
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Size Model
type Size @model {
  id: ID! @id
  sizeName: String!
  quantity: Int!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  carts: [Cart!]!  # Reverse relation from Cart
  wishlists: [Wishlist!]!  # Reverse relation from Wishlist
  orderItems: [OrderItem!]!  # Reverse relation from OrderItem
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# UserDetail Model
type UserDetail @model {
  id: ID! @id
  firstName: String!
  lastName: String!
  username: String!
  mobileNumber: String!  # Note: Stored as String, not Integer
  walletBalance: Float! @default(value: 0.0)
  
  # Relations
  carts: [Cart!]!  # One-to-Many with Cart
  wishlists: [Wishlist!]!  # One-to-Many with Wishlist
  addresses: [Address!]!  # One-to-Many with Address
  orders: [Order!]!  # One-to-Many with Order
  payments: [Payment!]!  # One-to-Many with Payment
  
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Cart Model
type Cart @model {
  id: ID! @id
  quantity: String!  # Note: Stored as String in Hygraph (convert to/from Int in code)
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  size: Size @relation(fields: [sizeId], references: [id])
  sizeId: ID
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Wishlist Model
type Wishlist @model {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  size: Size @relation(fields: [sizeId], references: [id])
  sizeId: ID
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Address Model
type Address @model {
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

# OrderItem Model
type OrderItem @model {
  id: ID! @id
  order: Order! @relation(fields: [orderId], references: [id])
  orderId: ID!
  product: Product! @relation(fields: [productId], references: [id])
  productId: ID!
  size: Size @relation(fields: [sizeId], references: [id])
  sizeId: ID
  quantity: String!  # Note: Stored as String in Hygraph (convert to/from Int in code)
  pricePerUnit: Float!
  totalPrice: Float!
  createdAt: DateTime @createdAt
  updatedAt: DateTime @updatedAt
}

# Order Model
type Order @model {
  id: ID! @id
  orderNumber: String! @unique
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  items: [OrderItem!]!  # Reverse relation from OrderItem
  totalAmount: Float!
  orderStatus: OrderStatus! @default(value: PENDING)  # Note: Field name is 'orderStatus', not 'status'
  shippingAddress: Address @relation(fields: [shippingAddressId], references: [id])
  shippingAddressId: ID
  trackingNumber: String
  courierName: String
  shiprocketOrderId: String
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}

# Payment Model
type Payment @model {
  id: ID! @id
  userDetail: UserDetail! @relation(fields: [userId], references: [id])
  userId: ID!
  razorpayOrderId: String!
  razorpayPaymentId: String
  amount: Float!
  currency: String! @default(value: "INR")
  paymentStatus: PaymentStatus! @default(value: PENDING)  # Note: Field name is 'paymentStatus', not 'status'
  method: String  # e.g., "card", "upi", "wallet", "netbanking"
  order: Order @relation(fields: [orderId], references: [id])
  orderId: ID
  createdAt: DateTime! @createdAt
  updatedAt: DateTime! @updatedAt
}
```

## Important Notes for Node.js Backend

### 1. Field Name Differences
- **Order**: Use `orderStatus` (not `status`) in schema
- **Payment**: Use `paymentStatus` (not `status`) in schema
- However, some queries may reference these as `status` - check your actual Hygraph schema

### 2. Data Type Considerations
- **Cart.quantity**: Stored as `String` in Hygraph, but represents an integer. Convert `Int` ↔ `String` in your backend code.
- **OrderItem.quantity**: Stored as `String` in Hygraph, but represents an integer. Convert `Int` ↔ `String` in your backend code.
- **UserDetail.mobileNumber**: Stored as `String` (not Integer) - handles numbers with country codes, spaces, etc.

### 3. Enum Values
Always use exact enum values (case-sensitive):
- OrderStatus: `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`, `REFUNDED`
- PaymentStatus: `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED`, `CANCELLED`, `REFUNDED`

### 4. Required Relations
When creating records, ensure related records exist:
- Cart requires: `userId`, `productId` (sizeId is optional)
- Wishlist requires: `userId`, `productId` (sizeId is optional)
- Order requires: `userId`
- OrderItem requires: `orderId`, `productId` (sizeId is optional)
- Address requires: `userId`
- Payment requires: `userId`, `razorpayOrderId` (orderId is optional)

### 5. Publishing Requirements
Hygraph requires publishing records after creation. Always call publish mutations after create operations:
- `publishCart`
- `publishWishlist`
- `publishAddress`
- `publishOrder`
- `publishOrderItem`
- `publishPayment`
- `publishUserDetail`

### 6. Unique Constraints
- `Order.orderNumber` must be unique
- Consider adding unique constraints for:
  - `UserDetail.username`
  - `UserDetail.mobileNumber`
  - `Category.slug` (if used)
  - `Product.slug` (if used)

### 7. Default Values
- `UserDetail.walletBalance`: Defaults to `0.0`
- `Address.country`: Defaults to `"India"`
- `Address.isDefault`: Defaults to `false`
- `Order.orderStatus`: Defaults to `PENDING`
- `Payment.paymentStatus`: Defaults to `PENDING`
- `Payment.currency`: Defaults to `"INR"`

## Example GraphQL Mutations for Backend

### Create Cart Item
```graphql
mutation CreateCartItem($quantity: String!, $userId: ID!, $productId: ID!, $sizeId: ID) {
  createCart(
    data: {
      quantity: $quantity
      userDetail: {connect: {id: $userId}}
      product: {connect: {id: $productId}}
      size: {connect: {id: $sizeId}}
    }
  ) {
    id
    quantity
  }
  publishCart(where: {id: $cartId}) {
    id
  }
}
```

### Create Order with Items
```graphql
# Step 1: Create Order
mutation CreateOrder(
  $userId: ID!,
  $orderNumber: String!,
  $totalAmount: Float!,
  $orderStatus: OrderStatus!,
  $shippingAddressId: ID
) {
  createOrder(
    data: {
      orderNumber: $orderNumber
      userDetail: {connect: {id: $userId}}
      totalAmount: $totalAmount
      orderStatus: $orderStatus
      shippingAddress: {connect: {id: $shippingAddressId}}
    }
  ) {
    id
    orderNumber
  }
}

# Step 2: Create Order Items (repeat for each item)
mutation CreateOrderItem(
  $orderId: ID!,
  $productId: ID!,
  $sizeId: ID,
  $quantity: String!,
  $pricePerUnit: Float!,
  $totalPrice: Float!
) {
  createOrderItem(
    data: {
      order: {connect: {id: $orderId}}
      product: {connect: {id: $productId}}
      size: {connect: {id: $sizeId}}
      quantity: $quantity
      pricePerUnit: $pricePerUnit
      totalPrice: $totalPrice
    }
  ) {
    id
  }
  publishOrderItem(where: {id: $orderItemId}) {
    id
  }
}
```

### Create Payment
```graphql
mutation CreatePayment(
  $userId: ID!,
  $razorpayOrderId: String!,
  $razorpayPaymentId: String,
  $amount: Float!,
  $currency: String!,
  $paymentStatus: PaymentStatus!,
  $method: String,
  $orderId: ID
) {
  createPayment(
    data: {
      userDetail: {connect: {id: $userId}}
      razorpayOrderId: $razorpayOrderId
      razorpayPaymentId: $razorpayPaymentId
      amount: $amount
      currency: $currency
      paymentStatus: $paymentStatus
      method: $method
      order: {connect: {id: $orderId}}
    }
  ) {
    id
    razorpayOrderId
    paymentStatus
  }
  publishPayment(where: {id: $paymentId}) {
    id
  }
}
```

### Update Wallet Balance
```graphql
# Add to wallet
mutation AddWalletBalance($userId: ID!, $amount: Float!) {
  updateUserDetail(
    where: {id: $userId}
    data: {walletBalance: {increment: $amount}}
  ) {
    id
    walletBalance
  }
}

# Deduct from wallet
mutation DeductWalletBalance($userId: ID!, $amount: Float!) {
  updateUserDetail(
    where: {id: $userId}
    data: {walletBalance: {decrement: $amount}}
  ) {
    id
    walletBalance
  }
}
```

## Permissions Configuration

### Public Content API (Read)
- Enable for all models with appropriate filters:
  - Filter by `userId` for user-specific data (Cart, Wishlist, Address, Order, Payment)
  - OrderItems accessible through Order relation
  - Products, Categories, Sizes: Public read access

### Content API (Write)
- Enable Create, Update, Delete for all models
- Application logic should handle authorization (ensuring users can only modify their own data)

---

**This schema is ready to be used in your Node.js backend for GraphQL operations with Hygraph.**
