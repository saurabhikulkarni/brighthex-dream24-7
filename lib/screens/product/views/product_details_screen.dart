import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:shop/route/screen_export.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, this.isProductAvailable = true});

  final bool isProductAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: 1200,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductBuyNowScreen(),
                );
              },
            )
          :

          /// If profuct is not available then show [NotifyMeCard]
          NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            const ProductImages(
              images: [productDemoImg1, productDemoImg2, productDemoImg3],
            ),
            ProductInfo(
              brand: "LIPSY LONDON",
              title: "Sleeveless Ruffle",
              isAvailable: isProductAvailable,
              description:
                  "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you’re supporting more responsibly...",
              rating: 4.4,
              numOfReviews: 126,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Product Details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("Product Details"),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Premium quality product with excellent durability. Made from sustainable materials with attention to detail. Perfect for everyday use.",
                          ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            "Features",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text("• High quality materials\n• Comfortable design\n• Durable construction\n• Easy to maintain"),
                          const SizedBox(height: defaultPadding),
                          Text(
                            "Care Instructions",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text("Wash in cold water. Do not bleach. Tumble dry low."),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("Shipping Information"),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shipping Methods",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: ListTile(
                              title: const Text("Standard Shipping"),
                              subtitle: const Text("5-7 business days"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  svg.SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text("0"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              title: const Text("Express Shipping"),
                              subtitle: const Text("2-3 business days"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  svg.SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text("50"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              title: const Text("Overnight"),
                              subtitle: const Text("Next business day"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  svg.SvgPicture.asset(
                                    'assets/icons/coin.svg',
                                    width: 14,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text("150"),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          Text(
                            "Delivery Info",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text("Orders are processed within 1-2 business days. Tracking information will be provided via email once your order ships."),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.3,
                  numOfReviews: 128,
                  numOfFiveStar: 80,
                  numOfFourStar: 30,
                  numOfThreeStar: 5,
                  numOfTwoStar: 4,
                  numOfOneStar: 1,
                ),
              ),
            ),
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(context, productReviewsScreenRoute);
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      image: productDemoImg2,
                      title: "Sleeveless Tiered Dobby Swing Dress",
                      brandName: "LIPSY LONDON",
                      price: 24.65,\n                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}


