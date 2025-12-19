# Implementation Summary: Address, Order, and Payment Management

This document summarizes what has been implemented and what needs to be done next.

---

## ✅ What Has Been Implemented

### 1. **Address Model** ✅
- **File**: `lib/models/address_model.dart`
- **Features**:
  - Full address fields (name, phone, pincode, address lines, city, state, country)
  - Default address flag
  - Full address string getter
  - CopyWith method for updates

### 2. **Address Service** ✅
- **File**: `lib/services/address_service.dart`
- **Methods**:
  - `getUserAddresses()` - Get all addresses for user
  - `getAddressById()` - Get specific address
  - `createAddress()` - Create new address
  - `updateAddress()` - Update existing address
  - `deleteAddress()` - Delete address
  - `setDefaultAddress()` - Set address as default
  - `getDefaultAddress()` - Get user's default address

### 3. **Order Models** ✅
- **File**: `lib/models/order_models.dart`
- **Features**:
  - `OrderStatus` enum (pending, confirmed, processing, shipped, delivered, cancelled, refunded)
  - `OrderItemModel` - Items within an order
  - `OrderModel` - Complete order with items, address, tracking

### 4. **Order Service (GraphQL)** ✅
- **File**: `lib/services/order_service_graphql.dart`
- **Methods**:
  - `getUserOrders()` - Get all orders for user
  - `getOrderById()` - Get specific order
  - `createOrder()` - Create new order with items
  - `updateOrderStatus()` - Update order status
  - `updateOrderTracking()` - Update tracking info
  - `cancelOrder()` - Cancel order
  - `getOrdersByStatus()` - Filter orders by status

### 5. **Payment Service** ✅
- **File**: `lib/services/payment_service.dart`
- **Methods**:
  - `getUserPayments()` - Get all payments for user
  - `getPaymentById()` - Get specific payment
  - `getPaymentByRazorpayOrderId()` - Find payment by Razorpay order ID
  - `createPayment()` - Create payment record
  - `updatePaymentStatus()` - Update payment status
  - `updatePaymentWithRazorpayId()` - Update with Razorpay payment ID after success

### 6. **GraphQL Queries & Mutations** ✅
- **File**: `lib/services/graphql_queries.dart`
- **Added**:
  - Address queries and mutations (CRUD operations)
  - Order queries and mutations (CRUD operations)
  - OrderItem creation mutation
  - Payment queries and mutations (CRUD operations)

### 7. **Hygraph Schema Documentation** ✅
- **File**: `HYGRAPH_SCHEMA_DESIGN.md`
- **Contains**:
  - Complete schema definitions
  - Step-by-step setup instructions
  - Relationship diagrams
  - Permissions configuration guide

---

## 📋 What You Need to Do Next

### Step 1: Add Schema to Hygraph ⚠️ **REQUIRED**

Follow the instructions in `HYGRAPH_SCHEMA_DESIGN.md`:

1. **Create Address Model** in Hygraph dashboard
2. **Create OrderItem Model** in Hygraph dashboard
3. **Create Order Model** with enum and relations
4. **Create Payment Model** with enum and relations
5. **Update UserDetail Model** to add relations
6. **Configure Permissions** for all models

### Step 2: Update Flutter Code (Optional - for integration)

If you want to use the new GraphQL services instead of in-memory storage:

1. **Update OrderService usage**:
   - Option A: Replace `orderService` with `orderServiceGraphQL` in screens
   - Option B: Update existing `order_service.dart` to use GraphQL internally

2. **Update screens** to use new services:
   - `lib/screens/address/views/add_address_screen.dart` - Use `addressService.createAddress()`
   - `lib/screens/checkout/views/cart_screen.dart` - Use `orderServiceGraphQL.createOrder()`
   - `lib/screens/checkout/views/payment_history_screen.dart` - Use `paymentService.getUserPayments()`

3. **Example Integration**:
   ```dart
   // In cart_screen.dart or checkout screen
   import 'package:shop/services/order_service_graphql.dart';
   import 'package:shop/services/address_service.dart';
   
   // Get default address
   final defaultAddress = await addressService.getDefaultAddress();
   
   // Create order
   final order = await orderServiceGraphQL.createOrder(
     items: orderItems,
     totalAmount: cartTotal,
     shippingAddressId: defaultAddress?.id,
     status: OrderStatus.confirmed,
   );
   ```

---

## 🔄 Migration Guide

### From In-Memory Order to GraphQL Order

**Current code uses**:
```dart
final order = orderService.createOrderWithPayment(
  items: orderItems,
  totalTokens: totalPrice.toInt(),
);
```

**New GraphQL approach**:
```dart
// 1. Create order in Hygraph
final order = await orderServiceGraphQL.createOrder(
  items: orderItems.map((item) => OrderItemModel(
    productId: item.productId,
    sizeId: item.size?.id,
    quantity: item.quantity,
    pricePerUnit: item.pricePerUnit.toDouble(),
  )).toList(),
  totalAmount: totalPrice.toDouble(),
  shippingAddressId: selectedAddressId,
  status: OrderStatus.confirmed,
);

// 2. Create payment record
await paymentService.createPayment(PaymentModel(
  orderId: order.id!,
  amount: totalPrice.toDouble(),
  razorpayOrderId: razorpayOrderId,
  status: PaymentStatus.completed,
));

// 3. Deduct wallet balance (existing service)
await walletService.deductBalance(totalPrice);
```

---

## 📝 Usage Examples

### Address Management

```dart
import 'package:shop/services/address_service.dart';
import 'package:shop/models/address_model.dart';

// Create address
final address = AddressModel(
  userId: currentUserId,
  fullName: 'John Doe',
  phoneNumber: '9876543210',
  pincode: '400001',
  addressLine1: '123 Main Street',
  city: 'Mumbai',
  state: 'Maharashtra',
  isDefault: true,
);

final createdAddress = await addressService.createAddress(address);

// Get all addresses
final addresses = await addressService.getUserAddresses();

// Get default address
final defaultAddress = await addressService.getDefaultAddress();

// Update address
final updated = await addressService.updateAddress(address.copyWith(city: 'Delhi'));

// Delete address
await addressService.deleteAddress(addressId);
```

### Order Management

```dart
import 'package:shop/services/order_service_graphql.dart';
import 'package:shop/models/order_models.dart';

// Create order
final order = await orderServiceGraphQL.createOrder(
  items: [
    OrderItemModel(
      productId: product.id!,
      sizeId: selectedSize?.id,
      quantity: quantity,
      pricePerUnit: product.price,
    ),
  ],
  totalAmount: totalPrice,
  shippingAddressId: addressId,
  status: OrderStatus.confirmed,
);

// Get all orders
final orders = await orderServiceGraphQL.getUserOrders();

// Get order by ID
final order = await orderServiceGraphQL.getOrderById(orderId);

// Update order status
await orderServiceGraphQL.updateOrderStatus(orderId, OrderStatus.shipped);

// Update tracking info
await orderServiceGraphQL.updateOrderTracking(
  orderId: orderId,
  trackingNumber: 'TRACK123',
  courierName: 'Delhivery',
);

// Cancel order
await orderServiceGraphQL.cancelOrder(orderId);
```

### Payment Management

```dart
import 'package:shop/services/payment_service.dart';
import 'package:shop/models/payment_model.dart';

// Create payment record
final payment = await paymentService.createPayment(PaymentModel(
  orderId: order.id!,
  amount: 1000.0,
  razorpayOrderId: razorpayOrderId,
  status: PaymentStatus.pending,
));

// After Razorpay payment success
await paymentService.updatePaymentWithRazorpayId(
  payment.paymentId,
  razorpayPaymentId,
  PaymentStatus.completed,
);

// Get payment history
final payments = await paymentService.getUserPayments(newestFirst: true);

// Get payment by Razorpay order ID
final payment = await paymentService.getPaymentByRazorpayOrderId(razorpayOrderId);
```

---

## ⚠️ Important Notes

### GraphQL Mutation Issues

The `createOrder` mutation in `graphql_queries.dart` has been simplified because Hygraph may not support nested array creates directly. Instead:

1. **Create the Order first** (without items)
2. **Create each OrderItem separately** (linked to the order)
3. **Publish both** Order and OrderItems

This is handled automatically in `OrderServiceGraphQL.createOrder()`.

### Required Hygraph Schema Updates

Make sure to add these relations:

**In UserDetail model**:
- `addresses: [Address!]! @relation`
- `orders: [Order!]! @relation`
- `payments: [Payment!]! @relation`

**In Product model** (if not present):
- `orderItems: [OrderItem!]! @relation`

**In Size model** (if not present):
- `orderItems: [OrderItem!]! @relation`

---

## ✅ Testing Checklist

After adding the Hygraph schema:

- [ ] Test creating an address
- [ ] Test updating an address
- [ ] Test setting default address
- [ ] Test creating an order with items
- [ ] Test fetching orders
- [ ] Test updating order status
- [ ] Test creating a payment record
- [ ] Test fetching payment history
- [ ] Verify data appears in Hygraph dashboard

---

## 🐛 Troubleshooting

### "Field not found" errors
- Ensure schema is published in Hygraph
- Check field names match exactly (case-sensitive)
- Verify relations are properly set up

### "Permission denied" errors
- Configure permissions in Hygraph dashboard
- Ensure user ID filtering is set up
- Check Content API permissions

### Order items not showing
- Verify OrderItem model has proper relations
- Check that items are being created and published
- Ensure orderId is correctly linked

---

## 📚 Related Files

- `HYGRAPH_SCHEMA_DESIGN.md` - Complete schema documentation
- `BACKEND_IMPLEMENTATION_STRATEGY.md` - Architecture decisions
- `FEATURE_ANALYSIS.md` - Feature status overview

---

*All code has been implemented and is ready to use once the Hygraph schema is added.*
