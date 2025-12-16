import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/models/product_model.dart';

import '../../../../constants.dart';

class ExpansionCategory extends StatelessWidget {
  const ExpansionCategory({
    super.key,
    required this.title,
    required this.subCategory,
    required this.svgSrc,
    this.categoryId,
  });

  final String title, svgSrc;
  final String? categoryId;
  final List subCategory;

  List<ProductModel> _getProductsForCategory(String? catId) {
    switch (catId) {
      case 'mens':
        return mensProducts;
      case 'womens':
        return womensProducts;
      case 'accessories':
        return accessoriesProducts;
      case 'electronics':
        return electronicsProducts;
      default:
        return [];
    }
  }

  List<ProductModel> _getProductsForSubcategory(String? categoryId, String subcategoryTitle) {
    // For accessories category, return products based on subcategory
    if (categoryId == 'accessories') {
      switch (subcategoryTitle.toLowerCase()) {
        case 'jewelry':
          return jewelryProducts;
        case 'handbags':
          return handbagsProducts;
        case 'mobile accessories':
          return mobileAccessoriesProducts;
        case "men's wallet":
          return mensWalletProducts;
        default:
          return [];
      }
    }
    
    // For other categories, use category-based products
    return _getProductsForCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      iconColor: Theme.of(context).textTheme.bodyLarge!.color,
      collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
      leading: SvgPicture.asset(
        svgSrc,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      textColor: Theme.of(context).textTheme.bodyLarge!.color,
      childrenPadding: const EdgeInsets.only(left: defaultPadding * 3.5),
      children: List.generate(
        subCategory.length,
        (index) => Column(
          children: [
            ListTile(
              onTap: () {
                // Navigate to category products screen
                final products = _getProductsForSubcategory(categoryId, subCategory[index].title);
                Navigator.pushNamed(
                  context,
                  categoryProductsScreenRoute,
                  arguments: {
                    'categoryName': subCategory[index].title,
                    'products': products.isEmpty ? [] : products,
                  },
                );
              },
              title: Text(
                subCategory[index].title,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (index < subCategory.length - 1) const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
