import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/screens/checkout/views/order_confirmation_screen.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/services/order_service.dart';
import 'package:shop/services/wallet_service.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/services/user_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({
    super.key,
    required this.product,
    this.sizes = const [],
  });

  final ProductModel product;
  final List<SizeModel> sizes;

  @override
  _ProductBuyNowScreenState createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int _quantity = 1;
  int _selectedSizeIndex = 0;
  double walletBalance = 0.0; // User's shopping tokens
  int shoppingTokens = 0;
  bool _isInWishlist = false;
  final UserService _userService = userService;

  // Default sizes if none from API
  static const List<String> _defaultSizes = ["S", "M", "L", "XL", "XXL"];

  List<String> get availableSizes {
    if (widget.sizes.isNotEmpty) {
      return widget.sizes.map((s) => s.sizeName).toList();
    }
    return _defaultSizes;
  }

  SizeModel? get selectedSize {
    if (widget.sizes.isEmpty) return null;
    if (_selectedSizeIndex >= widget.sizes.length) return null;
    return widget.sizes[_selectedSizeIndex];
  }

  String get selectedSizeName {
    if (_selectedSizeIndex < availableSizes.length) {
      return availableSizes[_selectedSizeIndex];
    }
    return "M";
  }

  double get totalPrice => widget.product.price * _quantity;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final isInWishlist = wishlistService.isInWishlist(widget.product.id!);
    setState(() {
      _isInWishlist = isInWishlist;
    });
  }

  Future<void> _toggleWishlist() async {
    final newState = await wishlistService.toggleWishlist(widget.product);
    
    setState(() {
      _isInWishlist = newState;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInWishlist
                ? '${widget.product.title} added to wishlist'
                : '${widget.product.title} removed from wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final balance = await walletService.getBalance();
      setState(() {
        walletBalance = balance;
      });
    } catch (e) {
      print('Error loading wallet balance: $e');
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() async {
    // Create a size model from selected size name if no API sizes
    SizeModel? sizeToAdd = selectedSize;
    if (sizeToAdd == null && availableSizes.isNotEmpty) {
      sizeToAdd = SizeModel(
        id: 'local_$selectedSizeName',
        sizeName: selectedSizeName,
        quantity: 100,
      );
    }

    try {
      // Add to local cart (also syncs with backend if logged in)
      await cartService.addToLocalCart(
        widget.product,
        sizeToAdd,
        _quantity,
      );

      // Show success message
      if (mounted) {
        customModalBottomSheet(
          context,
          isDismissible: false,
          child: const AddedToCartMessageScreen(),
        );
      }
    } catch (e) {
      // Show error message if stock is insufficient or other error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _createOrder() async {
    // Create order items from product
    final orderItems = [
      OrderItem(
        productId: widget.product.id ?? widget.product.title,
        productTitle: widget.product.title,
        productImage: widget.product.image.isNotEmpty 
            ? widget.product.image 
            : productDemoImg1,
        quantity: _quantity,
        pricePerUnit: widget.product.price.toInt(),
        size: selectedSize,
      ),
    ];

    // Use unified order creation flow from OrderService
    final order = await orderService.createOrderWithPayment(
      items: orderItems,
      totalTokens: totalPrice.toInt(),
      clearCartAfter: false, // Don't clear cart for Redeem Now (no cart involved)
    );

    if (order != null) {
      // Reload wallet balance from server after order
      try {
        final userId = UserService.getCurrentUserId();
        if (userId != null) {
          final newBalance = await _userService.getWalletBalance();
          setState(() {
            walletBalance = newBalance;
            shoppingTokens = newBalance.toInt();
          });
        } else {
          // Fallback: Update local state
          setState(() {
            walletBalance -= totalPrice.toInt();
            shoppingTokens = walletBalance.toInt();
          });
        }
      } catch (e) {
        // Fallback: Update local state
        setState(() {
          walletBalance -= totalPrice.toInt();
          shoppingTokens = walletBalance.toInt();
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order created successfully! Order ID: ${order.id.substring(0, 8)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to order confirmation screen
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OrderConfirmationScreen(order: null),
            ),
          );
        }
      });
    } else {
      // Order creation failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order')),
      );
    }
  }

  void _handleRedeemNow() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Cart & Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add this product to cart and proceed to checkout?'),
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
                  'Total: ${totalPrice.toInt()} tokens',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processRedeemNow();
            },
            child: const Text('Yes, Proceed'),
          ),
        ],
      ),
    );
  }

  void _processRedeemNow() async {
    final int productPrice = totalPrice.toInt();

    if (walletBalance >= productPrice) {
      // Sufficient balance - add to cart and redirect to cart screen
      await _addToCartAndProceed();
    } else {
      // Insufficient balance - show dialog
      final tokensShort = productPrice - walletBalance.toInt();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Shopping Tokens'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This product costs $productPrice tokens.'),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'Your wallet has: ${walletBalance.toStringAsFixed(2)} tokens',
                style: const TextStyle(fontWeight: FontWeight.w500),
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
                    'You need $tokensShort more tokens',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                Navigator.pushNamed(
                  context,
                  walletScreenRoute,
                  arguments: {
                    'walletBalance': walletBalance.toDouble(),
                    'shoppingTokens': walletBalance,
                    'requiredAmount': tokensShort.toDouble(),
                    'returnToCart': false,
                    'tokensNeeded': tokensShort,
                  },
                ).then((result) {
                  // Refresh wallet balance when returning from wallet screen
                  if (result != null && result is Map && mounted) {
                    setState(() {
                      final num updated = (result['shoppingTokens'] ?? walletBalance) as num;
                      walletBalance = updated.toDouble();
                    });
                  }
                });
              },
              child: const Text('Add Tokens to Wallet'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addToCartAndProceed() async {
    final userId = UserService.getCurrentUserId();
    print('[REDEEM] Getting user ID: $userId');
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to continue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print('[REDEEM] Adding to cart - userId: $userId, productId: ${widget.product.id}, sizeId: ${selectedSize?.id}, quantity: $_quantity');
      
      // Add to cart
      await cartService.addToCart(
        userId: userId,
        productId: widget.product.id!,
        sizeId: selectedSize?.id,
        quantity: _quantity,
      );

      print('[REDEEM] Product added to cart successfully');

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to cart screen
      Navigator.pushReplacementNamed(context, cartScreenRoute);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart! Proceed to checkout.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('[REDEEM] Error adding to cart: $e');
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding),
              // Redeem Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleRedeemNow,
                  icon: SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 18,
                    height: 18,
                  ),
                  label: const Text('Redeem Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2, vertical: defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    widget.product.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: _toggleWishlist,
                  icon: SvgPicture.asset(
                    "assets/icons/Wishlist.svg",
                    colorFilter: ColorFilter.mode(
                      _isInWishlist ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: widget.product.image.isNotEmpty
                          ? NetworkImageWithLoader(widget.product.image)
                          : const NetworkImageWithLoader(productDemoImg1),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: widget.product.price,
                            priceAfterDiscount: widget.product.priceAfetDiscount,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: _quantity,
                          onIncrement: _incrementQuantity,
                          onDecrement: _decrementQuantity,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverToBoxAdapter(
                  child: SelectedSize(
                    sizes: availableSizes,
                    selectedIndex: _selectedSizeIndex,
                    press: (index) {
                      setState(() {
                        _selectedSizeIndex = index;
                      });
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Size guide",
                    svgSrc: "assets/icons/Sizeguid.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SizeGuideScreen(),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Product Info",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          widget.product.description ?? 
                              "Premium quality product with excellent durability.",
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Check stores",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child: const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(height: defaultPadding))
              ],
            ),
          )
        ],
      ),
    );
  }
}
