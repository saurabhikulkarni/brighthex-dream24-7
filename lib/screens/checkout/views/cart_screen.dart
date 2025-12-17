import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/gradient_button.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/cart_service.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int walletBalance = 500; // User's shopping tokens

  List<CartModel> get cartItems => cartService.getLocalCart();

  double get subtotal => cartService.getCartTotal();
  double get tax => subtotal * 0.1;
  double get total => subtotal + tax;

  void _removeItem(String cartItemId) {
    setState(() {
      cartService.removeFromLocalCart(cartItemId);
    });
  }

  void _updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity < 1) return;
    setState(() {
      cartService.updateLocalCartQuantity(cartItemId, newQuantity);
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
                cartService.clearLocalCart();
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
        title: Text("Shopping Cart (${cartService.getCartItemCount()})"),
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
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Continue Shopping"),
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
                      final product = item.product;
                      
                      return Dismissible(
                        key: Key(item.id ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: defaultPadding),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeItem(item.id!),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding / 2),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: product?.image.isNotEmpty == true
                                          ? NetworkImageWithLoader(product!.image)
                                          : Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: defaultPadding),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product?.title ?? 'Product',
                                          style: Theme.of(context).textTheme.titleSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.size != null)
                                          Text(
                                            'Size: ${item.size!.sizeName}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/coin.svg',
                                              width: 14,
                                              height: 14,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${product?.price.toInt() ?? 0}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity Controls
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            onPressed: () => _updateQuantity(
                                              item.id!,
                                              item.quantity - 1,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            onPressed: () => _updateQuantity(
                                              item.id!,
                                              item.quantity + 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _removeItem(item.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
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
                      const Divider(height: defaultPadding),
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
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
