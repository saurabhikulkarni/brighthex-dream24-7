import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class KidsScreen extends StatelessWidget {
  const KidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kidsProducts = [
      {'name': 'Kids T-shirt', 'price': 12.0, 'color': 'Blue'},
      {'name': 'Kids Shorts', 'price': 15.0, 'color': 'Red'},
      {'name': 'Kids Jacket', 'price': 35.0, 'color': 'Green'},
      {'name': 'Kids Shoes', 'price': 45.0, 'color': 'Yellow'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kids Collection"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: defaultPadding,
          crossAxisSpacing: defaultPadding,
          childAspectRatio: 0.7,
        ),
        itemCount: kidsProducts.length,
        itemBuilder: (context, index) {
          final product = kidsProducts[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] as String,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['color'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${product['price']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
