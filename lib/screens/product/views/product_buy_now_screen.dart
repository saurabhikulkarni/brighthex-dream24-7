import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/services/cart_service.dart';

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
  int walletBalance = 500; // User's shopping tokens

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

  void _addToCart() {
    // Create a size model from selected size name if no API sizes
    SizeModel? sizeToAdd = selectedSize;
    if (sizeToAdd == null && availableSizes.isNotEmpty) {
      sizeToAdd = SizeModel(
        id: 'local_${selectedSizeName}',
        sizeName: selectedSizeName,
        quantity: 100,
      );
    }

    // Add to local cart
    cartService.addToLocalCart(
      widget.product,
      sizeToAdd,
      _quantity,
    );

    // Show success message
    customModalBottomSheet(
      context,
      isDismissible: false,
      child: const AddedToCartMessageScreen(),
    );
  }

  void _handleRedeemNow() {
    final int productPrice = totalPrice.toInt();

    if (walletBalance >= productPrice) {
      // Sufficient balance - add to cart and deduct tokens
      _addToCart();

      setState(() {
        walletBalance -= productPrice;
      });
    } else {
      // Insufficient balance - show dialog
      final tokensShort = productPrice - walletBalance;
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
                'Your wallet has: $walletBalance tokens',
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
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  walletScreenRoute,
                  arguments: {
                    'walletBalance': walletBalance.toDouble(),
                    'shoppingTokens': walletBalance,
                    'requiredAmount': tokensShort.toDouble(),
                    'returnToCart': false,
                  },
                ).then((result) {
                  // Refresh wallet balance when returning from wallet screen
                  if (result != null && result is Map && mounted) {
                    setState(() {
                      walletBalance = (result['shoppingTokens'] ?? walletBalance) as int;
                    });
                  }
                });
              },
              child: const Text('Add Tokens'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(
        price: totalPrice,
        title: "Add to Cart",
        subTitle: "Total tokens",
        press: _addToCart,
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
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
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
