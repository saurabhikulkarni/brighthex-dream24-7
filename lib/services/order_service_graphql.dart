import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/order_models.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/user_service.dart';
import 'package:uuid/uuid.dart';

/// OrderService with GraphQL integration
class OrderServiceGraphQL {
  static final OrderServiceGraphQL _instance = OrderServiceGraphQL._internal();
  
  factory OrderServiceGraphQL() {
    return _instance;
  }
  
  OrderServiceGraphQL._internal();

  final GraphQLClient _client = GraphQLService.getClient();

  // Convert OrderStatus enum to string
  String _orderStatusToString(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }

  // Convert string to OrderStatus enum
  OrderStatus _stringToOrderStatus(String statusStr) {
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

  // Generate unique order number
  String _generateOrderNumber() {
    const uuid = Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD${timestamp.toString().substring(7)}${uuid.v4().substring(0, 6).toUpperCase()}';
  }

  // Get all orders for current user
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserOrders),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['orders'] == null) {
        return [];
      }

      final List<dynamic> ordersJson = result.data!['orders'] as List<dynamic>;
      return ordersJson
          .map((json) => _orderFromGraphQL(json as Map<String, dynamic>, userId))
          .toList();
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getOrderById),
          variables: {'id': orderId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['order'] == null) {
        return null;
      }

      return _orderFromGraphQL(result.data!['order'] as Map<String, dynamic>, userId);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required double totalAmount,
    String? shippingAddressId,
    OrderStatus status = OrderStatus.pending,
  }) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final orderNumber = _generateOrderNumber();

      // Create order first
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.createOrder),
        variables: {
          'userId': userId,
          'orderNumber': orderNumber,
          'totalAmount': totalAmount,
          'status': _orderStatusToString(status),
          'shippingAddressId': shippingAddressId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final createdOrder = result.data?['createOrder'];
      if (createdOrder == null) {
        throw Exception('Failed to create order');
      }

      // Create order items
      final orderId = createdOrder['id']?.toString();
      if (orderId == null) {
        throw Exception('Failed to get order ID after creation');
      }

      // Create each order item
      for (final item in items) {
        final itemId = await _createOrderItem(
          orderId: orderId,
          productId: item.productId,
          sizeId: item.sizeId,
          quantity: item.quantity,
          pricePerUnit: item.pricePerUnit,
          totalPrice: item.totalPrice,
        );
        // Publish order item
        if (itemId != null) {
          await _publishOrderItem(itemId);
        }
      }

      // Publish order
      await _publishOrder(orderId);

      // Return full order by fetching it
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Failed to retrieve created order');
      }
      return order;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateOrderStatus),
        variables: {
          'id': orderId,
          'status': _orderStatusToString(status),
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found after update');
      }
      return order;
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Update order tracking information
  Future<OrderModel> updateOrderTracking({
    required String orderId,
    String? trackingNumber,
    String? courierName,
    String? shiprocketOrderId,
  }) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updateOrderTracking),
        variables: {
          'id': orderId,
          'trackingNumber': trackingNumber,
          'courierName': courierName,
          'shiprocketOrderId': shiprocketOrderId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final updatedOrder = await getOrderById(orderId);
      if (updatedOrder == null) {
        throw Exception('Order not found after update');
      }
      return updatedOrder;
    } catch (e) {
      throw Exception('Error updating order tracking: $e');
    }
  }

  // Cancel order
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.cancelOrder),
        variables: {'id': orderId},
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Get updated order
      final cancelledOrder = await getOrderById(orderId);
      if (cancelledOrder == null) {
        throw Exception('Order not found after cancellation');
      }
      return cancelledOrder;
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }

  // Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status) async {
    try {
      final orders = await getUserOrders();
      return orders.where((order) => order.orderStatus == status).toList();
    } catch (e) {
      throw Exception('Error fetching orders by status: $e');
    }
  }

  // Helper: Convert GraphQL JSON to OrderModel
  OrderModel _orderFromGraphQL(Map<String, dynamic> json, String userId) {
    // Parse items
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((itemJson) => OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    // Parse shipping address if present
    AddressModel? shippingAddress;
    if (json['shippingAddress'] != null) {
      shippingAddress = AddressModel.fromJson({
        ...json['shippingAddress'] as Map<String, dynamic>,
        'userId': userId,
      });
    }

    return OrderModel(
      id: json['id']?.toString(),
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      userId: userId,
      items: items,
      totalAmount: (json['totalAmount'] ?? json['total_amount'] ?? 0).toDouble(),
      orderStatus: _stringToOrderStatus(json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      shippingAddressId: shippingAddress?.id,
      shippingAddress: shippingAddress,
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      courierName: json['courierName'] ?? json['courier_name'],
      shiprocketOrderId: json['shiprocketOrderId'] ?? json['shiprocket_order_id'],
    );
  }

  // Helper: Create order item
  Future<String?> _createOrderItem({
    required String orderId,
    required String productId,
    String? sizeId,
    required int quantity,
    required double pricePerUnit,
    required double totalPrice,
  }) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createOrderItem),
          variables: {
            'orderId': orderId,
            'productId': productId,
            'sizeId': sizeId,
            'quantity': quantity,
            'pricePerUnit': pricePerUnit,
            'totalPrice': totalPrice,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['createOrderItem']?['id']?.toString();
    } catch (e) {
      print('Error creating order item: $e');
      // Re-throw as this is critical
      throw Exception('Failed to create order item: $e');
    }
  }

  // Helper: Publish order item
  Future<void> _publishOrderItem(String itemId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrderItem),
          variables: {'id': itemId},
        ),
      );
    } catch (e) {
      print('Error publishing order item: $e');
      // Non-critical error
    }
  }

  // Helper: Publish order
  Future<void> _publishOrder(String orderId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrder),
          variables: {'id': orderId},
        ),
      );
    } catch (e) {
      print('Error publishing order: $e');
      // Non-critical error
    }
  }
}

// Global instance
final orderServiceGraphQL = OrderServiceGraphQL();
