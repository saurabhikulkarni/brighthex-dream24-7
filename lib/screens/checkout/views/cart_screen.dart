import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class CartItem {
  final String name;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = [
      CartItem(
        name: "Nike Air Max",
        price: 120.0,
        quantity: 1,
        image: "assets/images/image_1.png",
      ),
      CartItem(
        name: "Adidas Jacket",
        price: 85.0,
        quantity: 2,
        image: "assets/images/image_2.png",
      ),
      CartItem(
        name: "Blue T-shirt",
        price: 25.0,
        quantity: 1,
        image: "assets/images/image_3.png",
      ),
    ];
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    "Your cart is empty",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.all(defaultPadding / 2),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image),
                            ),
                            title: Text(item.name),
                            subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text("Delete"),
                                  onTap: () => _removeItem(index),
                                ),
                              ],
                              child: const Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal"),
                          Text("\$${subtotal.toStringAsFixed(2)}"),
                        ],
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tax (10%)"),
                          Text("\$${tax.toStringAsFixed(2)}"),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Proceeding to checkout..."),
                              ),
                            );
                          },
                          child: const Text("Proceed to Checkout"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
