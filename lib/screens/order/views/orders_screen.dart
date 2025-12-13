import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class Order {
  final String id;
  final String date;
  final double total;
  final String status;
  final List<String> items;

  Order({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      Order(
        id: "#123456",
        date: "Dec 10, 2024",
        total: 325.50,
        status: "Delivered",
        items: ["Nike Air Max", "Blue T-shirt"],
      ),
      Order(
        id: "#123455",
        date: "Dec 5, 2024",
        total: 85.00,
        status: "In Transit",
        items: ["Adidas Jacket"],
      ),
      Order(
        id: "#123454",
        date: "Nov 28, 2024",
        total: 150.00,
        status: "Processing",
        items: ["Summer Sunglasses", "Black Belt"],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: orders.isEmpty
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
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
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
                            Text(
                              "Order ${order.id}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order.status == "Delivered"
                                    ? Colors.green.shade100
                                    : order.status == "In Transit"
                                        ? Colors.blue.shade100
                                        : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: order.status == "Delivered"
                                      ? Colors.green
                                      : order.status == "In Transit"
                                          ? Colors.blue
                                          : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          order.date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Items: ${order.items.join(", ")}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: \$${order.total.toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text("Details"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
