import 'package:shop/models/product_model.dart';
import 'package:uuid/uuid.dart';

class OrderItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final int quantity;
  final int pricePerUnit;
  final SizeModel? size;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.quantity,
    required this.pricePerUnit,
    this.size,
  });

  int get totalPrice => pricePerUnit * quantity;
}

class Order {
  final String id;
  final DateTime orderDate;
  final List<OrderItem> items;
  final int totalTokens;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String? trackingNumber;

  Order({
    String? id,
    DateTime? orderDate,
    required this.items,
    required this.totalTokens,
    this.status = 'confirmed',
    this.trackingNumber,
  })  : id = id ?? const Uuid().v4(),
        orderDate = orderDate ?? DateTime.now();

  int get itemCount => items.length;

  String get orderSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) {
      return '${items.first.productTitle} x${items.first.quantity}';
    }
    return '${items.length} items';
  }
}

class OrderService {
  static final OrderService _instance = OrderService._internal();

  factory OrderService() {
    return _instance;
  }

  OrderService._internal();

  // In-memory storage for orders (in real app, use database/backend)
  final List<Order> _orders = [];

  // Add new order
  void addOrder(Order order) {
    _orders.insert(0, order); // Add to beginning (newest first)
  }

  // Get all orders
  List<Order> getAllOrders() {
    return List.from(_orders);
  }

  // Get order by ID
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Update order status
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _orders[index];
      final updatedOrder = Order(
        id: oldOrder.id,
        orderDate: oldOrder.orderDate,
        items: oldOrder.items,
        totalTokens: oldOrder.totalTokens,
        status: newStatus,
        trackingNumber: oldOrder.trackingNumber,
      );
      _orders[index] = updatedOrder;
    }
  }

  // Cancel order
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, 'cancelled');
  }

  // Get recent orders (last n orders)
  List<Order> getRecentOrders({int limit = 5}) {
    return _orders.take(limit).toList();
  }

  // Clear all orders (for testing)
  void clearAll() {
    _orders.clear();
  }

  // Add sample orders for testing
  void addSampleOrders() {
    if (_orders.isNotEmpty) return; // Don't add if already have orders

    final now = DateTime.now();
    
    // Sample order 1
    addOrder(Order(
      orderDate: now.subtract(const Duration(days: 5)),
      items: [
        OrderItem(
          productId: '1',
          productTitle: 'Premium Cotton T-Shirt',
          productImage: 'assets/screens/shirt1.png',
          quantity: 1,
          pricePerUnit: 450,
        ),
      ],
      totalTokens: 450,
      status: 'delivered',
      trackingNumber: 'TRACK123456',
    ));

    // Sample order 2
    addOrder(Order(
      orderDate: now.subtract(const Duration(days: 2)),
      items: [
        OrderItem(
          productId: '3',
          productTitle: 'Classic Blue Hoodie',
          productImage: 'assets/screens/hoodie1.png',
          quantity: 1,
          pricePerUnit: 780,
        ),
      ],
      totalTokens: 780,
      status: 'shipped',
      trackingNumber: 'TRACK789012',
    ));

    // Sample order 3
    addOrder(Order(
      orderDate: now,
      items: [
        OrderItem(
          productId: '2',
          productTitle: 'Casual Striped Shirt',
          productImage: 'assets/screens/shirt2.png',
          quantity: 2,
          pricePerUnit: 520,
        ),
      ],
      totalTokens: 1040,
      status: 'confirmed',
    ));
  }
}

final orderService = OrderService();
