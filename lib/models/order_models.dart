import 'package:shop/models/product_model.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/shiprocket_service.dart';

/// OrderStatus enum for order status
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

/// OrderItem represents an item in an order
class OrderItemModel {
  final String? id;
  final String productId;
  final ProductModel? product;
  final String? sizeId;
  final SizeModel? size;
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  OrderItemModel({
    this.id,
    required this.productId,
    this.product,
    this.sizeId,
    this.size,
    required this.quantity,
    required this.pricePerUnit,
    double? totalPrice,
  }) : totalPrice = totalPrice ?? (pricePerUnit * quantity);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString(),
      productId: json['productId']?.toString() ?? json['product']?['id']?.toString() ?? '',
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      sizeId: json['sizeId']?.toString() ?? json['size']?['id']?.toString(),
      size: json['size'] != null
          ? SizeModel.fromJson(json['size'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] ?? 1,
      pricePerUnit: (json['pricePerUnit'] ?? json['price_per_unit'] ?? json['product']?['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? json['total_price']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sizeId': sizeId,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
    };
  }
}

/// OrderModel represents an order
class OrderModel {
  final String? id;
  final String orderNumber;
  final String userId;
  final List<OrderItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? shippingAddressId;
  final AddressModel? shippingAddress;
  final String? trackingNumber;
  final String? courierName;
  final String? shiprocketOrderId;
  final ShiprocketOrderData? shiprocketData;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.shippingAddressId,
    this.shippingAddress,
    this.trackingNumber,
    this.courierName,
    this.shiprocketOrderId,
    this.shiprocketData,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse status string to enum
    OrderStatus parseStatus(String? statusStr) {
      if (statusStr == null) return OrderStatus.pending;
      final statusLower = statusStr.toLowerCase();
      if (statusLower == 'pending') return OrderStatus.pending;
      if (statusLower == 'confirmed') return OrderStatus.confirmed;
      if (statusLower == 'processing') return OrderStatus.processing;
      if (statusLower == 'shipped') return OrderStatus.shipped;
      if (statusLower == 'delivered') return OrderStatus.delivered;
      if (statusLower == 'cancelled') return OrderStatus.cancelled;
      if (statusLower == 'refunded') return OrderStatus.refunded;
      return OrderStatus.pending;
    }

    return OrderModel(
      id: json['id']?.toString(),
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      userId: json['userId']?.toString() ?? json['userDetail']?['id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      status: parseStatus(json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      shippingAddressId: json['shippingAddress']?['id']?.toString(),
      shippingAddress: json['shippingAddress'] != null
          ? AddressModel.fromJson(json['shippingAddress'] as Map<String, dynamic>)
          : null,
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      courierName: json['courierName'] ?? json['courier_name'],
      shiprocketOrderId: json['shiprocketOrderId'] ?? json['shiprocket_order_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'trackingNumber': trackingNumber,
      'courierName': courierName,
      'shiprocketOrderId': shiprocketOrderId,
    };
  }

  int get itemCount => items.length;

  String get statusString => status.toString().split('.').last;

  String get orderSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) {
      return '${items.first.product?.productName ?? 'Item'} x${items.first.quantity}';
    }
    return '${items.length} items';
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<OrderItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shippingAddressId,
    AddressModel? shippingAddress,
    String? trackingNumber,
    String? courierName,
    String? shiprocketOrderId,
    ShiprocketOrderData? shiprocketData,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippingAddressId: shippingAddressId ?? this.shippingAddressId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierName: courierName ?? this.courierName,
      shiprocketOrderId: shiprocketOrderId ?? this.shiprocketOrderId,
      shiprocketData: shiprocketData ?? this.shiprocketData,
    );
  }
}
