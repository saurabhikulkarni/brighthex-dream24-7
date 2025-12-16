import 'package:flutter/material.dart';

import 'components/best_sellers.dart';
import 'components/category_banners_carousel.dart';
import 'components/most_popular.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Category Banners Carousel at Top
            const SliverToBoxAdapter(child: CategoryBannersCarousel()),
            const SliverToBoxAdapter(child: PopularProducts()),
            const SliverToBoxAdapter(child: BestSellers()),
            const SliverToBoxAdapter(child: MostPopular()),
          ],
        ),
      ),
    );
  }
}
