import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Order Confirmed',
        'message': 'Your order #123456 has been confirmed',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Shipment Dispatched',
        'message': 'Your package is on the way',
        'time': '1 day ago',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Special Offer',
        'message': 'Get 20% off on selected items',
        'time': '3 days ago',
        'icon': Icons.local_offer,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications cleared")),
              );
            },
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "No notifications",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(notification['icon'] as IconData),
                  title: Text(notification['title'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification['message'] as String),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
