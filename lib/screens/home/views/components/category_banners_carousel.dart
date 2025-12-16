import 'package:flutter/material.dart';
import 'package:shop/components/category_banner_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';

class CategoryBannersCarousel extends StatefulWidget {
  const CategoryBannersCarousel({super.key});

  @override
  State<CategoryBannersCarousel> createState() =>
      _CategoryBannersCarouselState();
}

class _CategoryBannersCarouselState extends State<CategoryBannersCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get products for the selected category
  List<ProductModel> _getProductsForCategory(String categoryId) {
    switch (categoryId) {
      case 'mens':
        return mensProducts;
      case 'womens':
        return womensProducts;
      case 'accessories':
        return accessoriesProducts;
      case 'electronics':
        return electronicsProducts;
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
    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: demoCategoryBanners.length,
            itemBuilder: (context, index) {
              final banner = demoCategoryBanners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        const SizedBox(height: defaultPadding),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            demoCategoryBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              width: _currentIndex == index ? 24 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: defaultPadding / 2),
      ],
    );
  }
}
