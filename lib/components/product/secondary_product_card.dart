import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

class SecondaryProductCard extends StatelessWidget {
  const SecondaryProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.press,
    this.style,
  });
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final VoidCallback? press;

  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: style ??
          OutlinedButton.styleFrom(
              minimumSize: const Size(256, 114),
              maximumSize: const Size(256, 114),
              padding: const EdgeInsets.all(8)),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              children: [
                NetworkImageWithLoader(image, radius: defaultBorderRadious),
              ],
            ),
          ),
          const SizedBox(width: defaultPadding / 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 12),
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
                            SvgPicture.asset(
                              'assets/icons/coin.svg',
                              width: 12,
                              height: 12,
                              opacity: const AlwaysStoppedAnimation(0.5),
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
