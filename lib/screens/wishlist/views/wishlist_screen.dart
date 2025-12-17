import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/wishlist_service.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late List<ProductModel> _wishlistItems;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() {
    _wishlistItems = wishlistService.getWishlist();
  }

  void _removeFromWishlist(String productId) {
    setState(() {
      wishlistService.removeFromWishlist(productId);
      _loadWishlist();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from wishlist'),
        duration: Duration(seconds: 2),
      ),
    );
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
                        onPressed: () {
                          wishlistService.clearWishlist();
                          setState(() {
                            _loadWishlist();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wishlist cleared'),
                            ),
                          );
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
      body: _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Like.svg',
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
                      childAspectRatio: 0.66,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final product = _wishlistItems[index];
                        return Stack(
                          children: [
                            ProductCard(
                              image: product.image,
                              brandName: product.brandName,
                              title: product.title,
                              price: product.price,
                              priceAfetDiscount:
                                  product.priceAfetDiscount,
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
