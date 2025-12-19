import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/shiprocket_service.dart';

class DeliveryPartnerCard extends StatelessWidget {
  final DeliveryPartner deliveryPartner;

  const DeliveryPartnerCard({
    super.key,
    required this.deliveryPartner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Delivery Partner Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF219A00),
                child: Text(
                  deliveryPartner.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding),
              // Partner Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliveryPartner.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.call, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          deliveryPartner.phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (deliveryPartner.vehicleInfo != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            deliveryPartner.vehicleInfo!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Call Button
              IconButton(
                onPressed: () {
                  // Implement phone call functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${deliveryPartner.phone}'),
                    ),
                  );
                },
                icon: const Icon(Icons.phone, color: Color(0xFF219A00)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
