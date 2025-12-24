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

  // Convert OrderStatus enum to string for GraphQL
  // Hygraph expects enum values to match the schema exactly
  // Try lowercase first as that's a common pattern
  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.refunded:
        return 'refunded';
      default:
        return 'pending';
    }
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
      final List<OrderModel> orders = [];
      for (final json in ordersJson) {
        final order = await _orderFromGraphQL(json as Map<String, dynamic>, userId);
        orders.add(order);
      }
      return orders;
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

      return await _orderFromGraphQL(result.data!['order'] as Map<String, dynamic>, userId);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder({
    required List<OrderItemModel> items,
    required double totalAmount,
    String? addressId,
    OrderStatus status = OrderStatus.pending,
  }) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        print('Error: userId is null or empty when creating order');
        print('UserService.getCurrentUserId() returned: $userId');
        throw Exception('User not logged in. Please log in to create an order.');
      }
      
      print('Creating order with userId: $userId');

      // Ensure totalAmount is valid (should be >= 0)
      if (totalAmount < 0) {
        throw Exception('Total amount cannot be negative');
      }
      
      // Generate order number
      final orderNumber = _generateOrderNumber();
      
      // Create order - use different mutation based on whether address is provided
      final bool hasAddress = addressId != null && addressId.isNotEmpty;
      
      final MutationOptions options = MutationOptions(
        document: gql(hasAddress 
          ? GraphQLQueries.createOrderWithAddress 
          : GraphQLQueries.createOrderWithoutAddress),
        variables: {
          'userId': userId,
          'orderNumber': orderNumber,
          'totalAmount': totalAmount,
          'orderStatus': _orderStatusToString(status),
          if (hasAddress) 'addressId': addressId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        print('Error creating order: ${result.exception}');
        print('GraphQL errors: ${result.exception?.graphqlErrors}');
        throw Exception(result.exception.toString());
      }

      print('Create order response: ${result.data}');
      final createdOrder = result.data?['createOrder'];
      if (createdOrder == null) {
        print('Error: createOrder response is null. Full data: ${result.data}');
        throw Exception('Failed to create order - no data returned');
      }
      
      print('Order created successfully: ${createdOrder['id']}');

      // Create order items
      final orderId = createdOrder['id']?.toString();
      if (orderId == null) {
        throw Exception('Failed to get order ID after creation');
      }

      // Validate and prepare order items with default values
      if (items.isEmpty) {
        throw Exception('Order must have at least one item');
      }
      
      // Create each order item - if any fails, rollback the order
      final List<String> createdItemIds = [];
      try {
        for (final item in items) {
          // Add small delay between items to avoid rate limiting (Hygraph free tier)
          if (createdItemIds.isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          // Validate required fields and use defaults if needed
          final productId = item.productId.isNotEmpty 
            ? item.productId 
            : throw Exception('Product ID is required for order item');
          
          final quantity = item.quantity > 0 
            ? item.quantity 
            : 1; // Default to 1 if invalid
          
          final pricePerUnit = item.pricePerUnit >= 0 
            ? item.pricePerUnit 
            : 0.0; // Default to 0 if invalid
          
          final totalPrice = item.totalPrice >= 0 
            ? item.totalPrice 
            : (pricePerUnit * quantity); // Calculate if invalid
          
          // sizeId can be null (optional field)
          final sizeId = item.sizeId;
          
          final itemId = await _createOrderItem(
            orderId: orderId,
            productId: productId,
            sizeId: sizeId,
            quantity: quantity,
            pricePerUnit: pricePerUnit,
            totalPrice: totalPrice,
          );
          
          if (itemId == null) {
            throw Exception('Failed to create order item - no ID returned');
          }
          
          // Small delay before publishing to avoid rate limit
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Publish order item
          print('Publishing order item: $itemId');
          await _publishOrderItem(itemId);
          createdItemIds.add(itemId);
          print('Order item created and published successfully: $itemId');
        }
      } catch (e) {
        // If any item creation fails, we should ideally rollback
        // For now, log the error and throw to prevent order completion
        print('Critical error creating order items: $e');
        print('Created ${createdItemIds.length} out of ${items.length} items');
        // Note: In a production system, you might want to delete the order here
        // if some items fail. For now, we'll throw to prevent incomplete orders.
        throw Exception('Failed to create all order items: $e');
      }

      // Publish order
      print('Publishing order: $orderId');
      await _publishOrder(orderId);
      print('Order published successfully');

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
          'orderStatus': _orderStatusToString(status),
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

  // Helper: Fetch order items separately
  Future<List<OrderItemModel>> _fetchOrderItems(String orderId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getOrderItemsByOrderId),
          variables: {'orderId': orderId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        print('Error fetching order items: ${result.exception}');
        return [];
      }

      if (result.data == null || result.data!['orderItems'] == null) {
        return [];
      }

      final List<dynamic> itemsJson = result.data!['orderItems'] as List<dynamic>;
      return itemsJson
          .map((itemJson) => OrderItemModel.fromJson(itemJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  // Helper: Convert GraphQL JSON to OrderModel
  Future<OrderModel> _orderFromGraphQL(Map<String, dynamic> json, String userId) async {
    final orderId = json['id']?.toString() ?? '';
    
    // Fetch items separately
    final items = await _fetchOrderItems(orderId);

    // Parse address if present
    AddressModel? address;
    if (json['address'] != null) {
      address = AddressModel.fromJson({
        ...json['address'] as Map<String, dynamic>,
        'userId': userId,
      });
    } else if (json['shippingAddress'] != null) {
      // Fallback for backward compatibility
      address = AddressModel.fromJson({
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
      addressId: address?.id,
      address: address,
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
      // Use different mutations based on whether sizeId is provided
      final bool hasValidSizeId = sizeId != null && 
                                  sizeId.isNotEmpty && 
                                  !sizeId.startsWith('local_');
      
      final QueryResult result;
      if (hasValidSizeId) {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createOrderItemWithSize),
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
      } else {
        result = await _client.mutate(
          MutationOptions(
            document: gql(GraphQLQueries.createOrderItemWithoutSize),
            variables: {
              'orderId': orderId,
              'productId': productId,
              'quantity': quantity,
              'pricePerUnit': pricePerUnit,
              'totalPrice': totalPrice,
            },
          ),
        );
      }

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
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrderItem),
          variables: {'id': itemId},
        ),
      );
      
      if (result.hasException) {
        print('Error publishing order item: ${result.exception}');
        throw Exception('Failed to publish order item: ${result.exception}');
      }
      print('Order item published successfully: $itemId');
    } catch (e) {
      print('Error publishing order item: $e');
      // Re-throw as this is critical for order creation
      rethrow;
    }
  }

  // Helper: Publish order
  Future<void> _publishOrder(String orderId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishOrder),
          variables: {'id': orderId},
        ),
      );
      
      if (result.hasException) {
        print('Error publishing order: ${result.exception}');
        throw Exception('Failed to publish order: ${result.exception}');
      }
      print('Order published successfully: $orderId');
    } catch (e) {
      print('Error publishing order: $e');
      // Re-throw as this is critical for order creation
      rethrow;
    }
  }
}

// Global instance
final orderServiceGraphQL = OrderServiceGraphQL();
