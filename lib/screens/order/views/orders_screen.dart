import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/order_service_graphql.dart';
import 'package:shop/models/order_models.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  final OrderServiceGraphQL orderService = OrderServiceGraphQL();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final orders = await orderService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        "No orders yet",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        "Start shopping to place your first order!",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order ${order.orderNumber}",
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.statusString)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatStatus(order.statusString),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(order.statusString),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          order.orderSummary,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        // Show tracking info if available
                        if (order.trackingNumber != null || order.courierName != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (order.courierName != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.courierName!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              if (order.trackingNumber != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.track_changes,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Tracking: ${order.trackingNumber}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                            ],
                          ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${order.totalAmount.toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Row(
                              children: [
                                // Track button - show if order has Shiprocket order ID or tracking number
                                if (order.shiprocketOrderId != null || order.trackingNumber != null)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Navigate to tracking screen with Shiprocket order ID or order number
                                      final trackingId = order.shiprocketOrderId ?? order.orderNumber;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderTrackingScreen(
                                            orderId: trackingId,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.track_changes, size: 18),
                                    label: const Text('Track'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                if (order.shiprocketOrderId != null || order.trackingNumber != null)
                                  const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to order details/tracking screen
                                    final trackingId = order.shiprocketOrderId ?? order.orderNumber;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderTrackingScreen(
                                          orderId: trackingId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonth(date.month)} ${date.year}";
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatStatus(String status) {
    return status.replaceFirst(
      status[0],
      status[0].toUpperCase(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
      case 'in transit':
        return Colors.blue;
      case 'confirmed':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
