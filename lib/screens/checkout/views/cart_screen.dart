import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/constants.dart';
import 'package:uuid/uuid.dart';

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
  int walletBalance = 500; // User's shopping tokens

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

  void _proceedToPayment(BuildContext context) {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final totalTokensNeeded = total.toInt();

    // Check if wallet has enough tokens
    if (walletBalance < totalTokensNeeded) {
      final tokensShort = totalTokensNeeded - walletBalance;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Tokens'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You need $totalTokensNeeded tokens to complete this purchase.'),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'Your wallet has: $walletBalance tokens',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'You need $tokensShort more tokens.',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
              child: const Text('Add Top-up'),
            ),
          ],
        ),
      );
      return;
    }

    // Deduct tokens from wallet and complete purchase
    setState(() {
      walletBalance -= totalTokensNeeded;
    });

    // Generate unique order ID
    const uuid = Uuid();
    final orderId = '#${uuid.v4().substring(0, 8).toUpperCase()}';

    _handlePaymentSuccess({
      'orderId': orderId,
      'paymentId': 'TOKEN_${uuid.v4().substring(0, 8).toUpperCase()}',
      'tokensDeducted': totalTokensNeeded,
    });
  }

  void _handlePaymentSuccess(Map<dynamic, dynamic> paymentResult) {
    final tokensDeducted = paymentResult['tokensDeducted'] ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thank you for your purchase!'),
            const SizedBox(height: defaultPadding),
            Text(
              'Order ID: ${paymentResult['orderId']}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tokens Deducted: $tokensDeducted',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Remaining Balance: $walletBalance',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.clear();
              });
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
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
                            subtitle: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/coin.svg',
                                  width: 14,
                                  height: 14,
                                ),
                                const SizedBox(width: 2),
                                Text("${item.price.toInt()}"),
                              ],
                            ),
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
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Text("${subtotal.toInt()}"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tax (10%)"),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 14,
                                height: 14,
                              ),
                              const SizedBox(width: 2),
                              Text("${tax.toInt()}"),
                            ],
                          ),
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
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "${total.toInt()}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      GradientButton(
                        onPressed: () {
                          _proceedToPayment(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text("Redeem"),
                            const SizedBox(width: 8),
                            Text(
                              "${total.toInt()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
