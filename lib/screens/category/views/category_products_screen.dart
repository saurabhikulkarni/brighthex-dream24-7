import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.products,
  });

  final String categoryName;
  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'No products in $categoryName',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(defaultPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) => ProductCard(
                  image: products[index].image,
                  brandName: products[index].brandName,
                  title: products[index].title,
                  price: products[index].price,
                  priceAfetDiscount: products[index].priceAfetDiscount,
                  press: () {
                    Navigator.pushNamed(context, productDetailsScreenRoute);
                  },
                ),
              ),
      ),
    );
  }
}
