import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/components/network_image_with_loader.dart';

class CategoryBannerCard extends StatelessWidget {
  const CategoryBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
    required this.onPressed,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Stack(
        children: [
          // Background Image (supports both assets and network)
          AspectRatio(
            aspectRatio: 2.0,
            child: image.startsWith('assets/')
                ? Image.asset(
                    image,
                    fit: BoxFit.cover,
                  )
                : NetworkImageWithLoader(
                    image,
                    radius: defaultBorderRadious,
                  ),
          ),
          // Dark overlay
          Container(
            color: Colors.black38,
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and Subtitle Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: defaultPadding / 4),
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  // Shop Now Button
                  SizedBox(
                    width: 90,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 3,
                          vertical: defaultPadding / 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ),
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
