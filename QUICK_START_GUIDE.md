# Quick Start Guide: Address, Order, and Payment Management

This guide helps you quickly get started with the new Address, Order, and Payment management features.

---

## 🚀 Quick Setup Steps

### 1. Add Schema to Hygraph (15-20 minutes)

Follow `HYGRAPH_SCHEMA_DESIGN.md` or use `HYGRAPH_SCHEMA_COMPLETE.txt` as reference.

**Required Models:**
- Address ✅
- OrderItem ✅
- Order ✅
- Payment ✅

**Update Existing Models:**
- UserDetail (add relations) ✅
- Product (add orderItems relation if needed) ✅
- Size (add orderItems relation if needed) ✅

---

### 2. Test in Flutter (5 minutes)

```dart
import 'package:shop/services/address_service.dart';
import 'package:shop/services/order_service_graphql.dart';
import 'package:shop/services/payment_service.dart';

// Test address creation
final address = AddressModel(
  userId: 'your-user-id',
  fullName: 'Test User',
  phoneNumber: '9876543210',
  pincode: '400001',
  addressLine1: '123 Test Street',
  city: 'Mumbai',
  state: 'Maharashtra',
);

final createdAddress = await addressService.createAddress(address);
print('Address created: ${createdAddress.id}');

// Test fetching addresses
final addresses = await addressService.getUserAddresses();
print('Total addresses: ${addresses.length}');
```

---

## 📁 Files Created

### Models
- ✅ `lib/models/address_model.dart` - Address data model
- ✅ `lib/models/order_models.dart` - Order and OrderItem models

### Services
- ✅ `lib/services/address_service.dart` - Address CRUD operations
- ✅ `lib/services/order_service_graphql.dart` - Order CRUD operations
- ✅ `lib/services/payment_service.dart` - Payment record operations

### GraphQL Queries
- ✅ Updated `lib/services/graphql_queries.dart` with:
  - Address queries & mutations
  - Order queries & mutations
  - OrderItem mutations
  - Payment queries & mutations

### Documentation
- ✅ `HYGRAPH_SCHEMA_DESIGN.md` - Complete schema guide
- ✅ `HYGRAPH_SCHEMA_COMPLETE.txt` - Quick reference
- ✅ `IMPLEMENTATION_SUMMARY.md` - Implementation details

---

## 🔗 Integration Points

### Where to Use Address Service

1. **Add Address Screen** (`lib/screens/address/views/add_address_screen.dart`)
   ```dart
   final address = AddressModel(/* ... */);
   await addressService.createAddress(address);
   ```

2. **Checkout Screen** - Get default address
   ```dart
   final defaultAddress = await addressService.getDefaultAddress();
   ```

### Where to Use Order Service

1. **Cart Screen** (`lib/screens/checkout/views/cart_screen.dart`)
   ```dart
   final order = await orderServiceGraphQL.createOrder(
     items: orderItems,
     totalAmount: total,
     shippingAddressId: addressId,
   );
   ```

2. **Orders Screen** (`lib/screens/order/views/orders_screen.dart`)
   ```dart
   final orders = await orderServiceGraphQL.getUserOrders();
   ```

### Where to Use Payment Service

1. **After Razorpay Payment Success**
   ```dart
   await paymentService.createPayment(PaymentModel(
     orderId: order.id!,
     amount: amount,
     razorpayOrderId: razorpayOrderId,
     status: PaymentStatus.completed,
   ));
   ```

2. **Payment History Screen**
   ```dart
   final payments = await paymentService.getUserPayments();
   ```

---

## ⚠️ Important: Schema Field Names

Make sure your Hygraph schema uses these exact field names:

### Address
- `fullName` (not `full_name`)
- `phoneNumber` (not `phone_number`)
- `addressLine1` (not `address_line1`)
- `addressLine2` (not `address_line2`)
- `isDefault` (not `is_default`)

### Order
- `orderNumber` (not `order_number`)
- `totalAmount` (not `total_amount`)
- `trackingNumber` (not `tracking_number`)
- `courierName` (not `courier_name`)
- `shiprocketOrderId` (not `shiprocket_order_id`)

### Payment
- `razorpayOrderId` (not `razorpay_order_id`)
- `razorpayPaymentId` (not `razorpay_payment_id`)

### OrderItem
- `pricePerUnit` (not `price_per_unit`)
- `totalPrice` (not `total_price`)

---

## 🔄 Migration from In-Memory to GraphQL

### Current Code (In-Memory)
```dart
// Uses orderService (in-memory)
final order = orderService.createOrderWithPayment(
  items: orderItems,
  totalTokens: totalPrice.toInt(),
);
```

### New Code (GraphQL)
```dart
// Uses orderServiceGraphQL
final order = await orderServiceGraphQL.createOrder(
  items: orderItems.map((item) => OrderItemModel(
    productId: item.productId,
    sizeId: item.size?.id,
    quantity: item.quantity,
    pricePerUnit: item.pricePerUnit.toDouble(),
  )).toList(),
  totalAmount: totalPrice.toDouble(),
  shippingAddressId: addressId,
  status: OrderStatus.confirmed,
);

// Then create payment record
await paymentService.createPayment(PaymentModel(
  orderId: order.id!,
  amount: totalPrice,
  razorpayOrderId: razorpayOrderId,
  status: PaymentStatus.completed,
));
```

---

## ✅ Testing Checklist

- [ ] Schema added to Hygraph
- [ ] Permissions configured
- [ ] Test creating address
- [ ] Test creating order
- [ ] Test creating payment
- [ ] Test fetching orders
- [ ] Test fetching payments
- [ ] Test updating order status
- [ ] Verify data in Hygraph dashboard

---

## 🆘 Common Issues

### Issue: "Field X not found"
**Solution**: Check field names match exactly (case-sensitive)

### Issue: "Relation error"
**Solution**: Ensure relations are set up in Hygraph dashboard

### Issue: "Permission denied"
**Solution**: Configure Content API permissions in Hygraph

### Issue: "Order items not showing"
**Solution**: Ensure OrderItems are created and published after Order creation

---

## 📞 Next Steps

1. ✅ Add schema to Hygraph (use `HYGRAPH_SCHEMA_DESIGN.md`)
2. ✅ Test basic CRUD operations
3. ✅ Integrate into your screens
4. ✅ Test end-to-end order flow

---

*Everything is ready to use once the Hygraph schema is configured!*
