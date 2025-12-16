import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';
import '../../utils/responsive_extension.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    required this.press,
  });
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final cardWidth = context.isTablet ? 160 : 140;
    final cardHeight = context.isTablet ? 260 : 220;
    final fontSize = context.fontSize(10, minSize: 8, maxSize: 12);
    
    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
          minimumSize: Size(cardWidth.toDouble(), cardHeight.toDouble()),
          maximumSize: Size(cardWidth.toDouble(), cardHeight.toDouble()),
          padding: EdgeInsets.all(context.responsiveSpacing)),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadious),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing / 2, 
                  vertical: context.responsiveSpacing / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: fontSize),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: fontSize + 2),
                  ),
                  const Spacer(),
                  priceAfetDiscount != null
                      ? Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${priceAfetDiscount!.toInt()}",
                              style: const TextStyle(
                                color: Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                            Opacity(
                              opacity: 0.5,
                              child: SvgPicture.asset(
                                'assets/icons/coin.svg',
                                width: 12,
                                height: 12,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${price.toInt()}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${price.toInt()}",
                              style: const TextStyle(
                                color: Color(0xFF31B0D8),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
