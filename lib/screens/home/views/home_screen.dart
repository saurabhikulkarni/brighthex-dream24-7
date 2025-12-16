import 'package:flutter/material.dart';
import 'package:shop/components/Banner/S/banner_s_style_1.dart';
import 'package:shop/components/Banner/S/banner_s_style_5.dart';
import 'package:shop/constants.dart';

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
            // Removed FlashSale section to eliminate sale alerts/banners
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // New Arrival Banner
                  BannerSStyle1(
                    title: "New \narrival",
                    subtitle: "Explore",
                    discountParcent: 0,
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            const SliverToBoxAdapter(child: MostPopular()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),

                  const SizedBox(height: defaultPadding / 4),
                  // While loading use 👇
                  // const BannerSSkelton(),
                  // Removed sale messaging and navigation from banner
                  BannerSStyle5(
                    title: "Featured \ncollection",
                    subtitle: "New arrivals",
                    bottomText: "Collection".toUpperCase(),
                    press: () {},
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
          ],
        ),
      ),
    );
  }
}
