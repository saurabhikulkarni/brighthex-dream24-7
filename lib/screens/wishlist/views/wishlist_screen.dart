import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ProductModel> _wishlistItems = [];
  bool _isLoading = true;
  final CartService cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh wishlist when screen comes back to focus
    _loadWishlist();
  }

  void _loadWishlist() async {
    setState(() {
      _isLoading = true;
    });
    
    // Sync with backend first to get latest wishlist
    await wishlistService.syncWithBackend();
    
    if (mounted) {
      setState(() {
        _wishlistItems = wishlistService.getWishlist();
        _isLoading = false;
      });
    }
  }

  void _removeFromWishlist(String productId) async {
    await wishlistService.removeFromWishlist(productId);
    _loadWishlist();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from wishlist'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Check if product has stock (checking all sizes)
  bool _hasStock(ProductModel product) {
    // If no size information, assume in stock
    // You might need to add sizes field to ProductModel or fetch separately
    return true; // Implement proper stock checking based on your data model
  }

  Future<void> _addToCart(ProductModel product) async {
    try {
      // Check stock before adding
      if (!_hasStock(product)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This product is out of stock'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Add to cart without size (you can modify this if you want to show size selection)
      await cartService.addToLocalCart(product, null, 1);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                Navigator.pushNamed(context, cartScreenRoute);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _moveAllToCart() async {
    if (_wishlistItems.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    int addedCount = 0;
    int failedCount = 0;

    for (var product in _wishlistItems) {
      try {
        await cartService.addToLocalCart(product, null, 1);
        await wishlistService.removeFromWishlist(product.id!);
        addedCount++;
      } catch (e) {
        failedCount++;
        print('Error moving ${product.title} to cart: $e');
      }
    }

    _loadWishlist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failedCount > 0
                ? '$addedCount items moved to cart, $failedCount failed'
                : 'All $addedCount items moved to cart',
          ),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.pushNamed(context, cartScreenRoute);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _moveAllToCart,
              tooltip: 'Move All to Cart',
            ),
          if (_wishlistItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Wishlist?'),
                    content: const Text(
                        'Are you sure you want to clear your entire wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() {
                            _isLoading = true;
                          });
                          await wishlistService.clearWishlist();
                          _loadWishlist();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wishlist cleared'),
                              ),
                            );
                          }
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Wishlist.svg',
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade400,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'Your wishlist is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Add products you love to your wishlist',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final product = _wishlistItems[index];
                        return Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ProductCard(
                                    image: product.image,
                                    brandName: product.brandName,
                                    title: product.title,
                                    price: product.price,
                                    priceAfetDiscount:
                                        product.priceAfetDiscount,
                                    product: product,
                                    press: () {
                                      Navigator.pushNamed(
                                        context,
                                        productDetailsScreenRoute,
                                        arguments: {'product': product},
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _removeFromWishlist(product.id!);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _addToCart(product),
                                icon: const Icon(Icons.shopping_cart, size: 16),
                                label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  minimumSize: const Size(0, 32),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: _wishlistItems.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
