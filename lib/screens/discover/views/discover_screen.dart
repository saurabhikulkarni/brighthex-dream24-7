import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  String? _getCategoryId(String categoryTitle) {
    if (categoryTitle.toLowerCase().contains("men")) {
      return "mens";
    } else if (categoryTitle.toLowerCase().contains("women")) {
      return "womens";
    } else if (categoryTitle.toLowerCase().contains("accessor")) {
      return "accessories";
    } else if (categoryTitle.toLowerCase().contains("electron")) {
      return "electronics";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, searchScreenRoute);
                },
                child: AbsorbPointer(
                  child: const SearchForm(isEnabled: false),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // While loading use 👇
            // const Expanded(
            //   child: DiscoverCategoriesSkelton(),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: demoCategories.length,
                itemBuilder: (context, index) {
                  final category = demoCategories[index];
                  final categoryId = _getCategoryId(category.title);
                  
                  return Column(
                    children: [
                      ListTile(
                        leading: SvgPicture.asset(
                          category.svgSrc!,
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          category.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            categoryProductsScreenRoute,
                            arguments: {
                              'categoryName': category.title,
                              'categoryId': categoryId,
                            },
                          );
                        },
                      ),
                      if (index < demoCategories.length - 1) 
                        const Divider(height: 1),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
