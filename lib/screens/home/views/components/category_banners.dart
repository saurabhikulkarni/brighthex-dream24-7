import 'package:flutter/material.dart';
import 'package:shop/components/category_banner_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class CategoryBanners extends StatelessWidget {
  const CategoryBanners({super.key});

  // Get products for the selected category
  List<ProductModel> _getProductsForCategory(String categoryId) {
    // Filter demo products by category
    // Using a simple mapping based on category ID
    switch (categoryId) {
      case 'mens':
        return demoPopularProducts.sublist(0, 2);
      case 'womens':
        return demoPopularProducts.sublist(2, 4);
      case 'accessories':
        return demoPopularProducts.sublist(4, 6);
      case 'electronics':
        return demoPopularProducts.sublist(6);
      default:
        return demoPopularProducts;
    }
  }

  void _navigateToCategoryProducts(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    final products = _getProductsForCategory(categoryId);
    Navigator.pushNamed(
      context,
      categoryProductsScreenRoute,
      arguments: {
        'categoryName': categoryName,
        'products': products,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding),
      child: Column(
        children: List.generate(
          demoCategoryBanners.length,
          (index) {
            final banner = demoCategoryBanners[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: CategoryBannerCard(
                title: banner.categoryName,
                subtitle: banner.subtitle,
                image: banner.bannerImageUrl,
                buttonText: "Shop Now",
                onPressed: () => _navigateToCategoryProducts(
                  context,
                  banner.id,
                  banner.categoryName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
