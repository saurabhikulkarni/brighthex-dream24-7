import 'package:flutter/material.dart';

/// A responsive image widget that adapts to different screen sizes
class ResponsiveImage extends StatelessWidget {
  final String imagePath;
  final double heightPercentage;
  final BoxFit fit;
  final Alignment alignment;
  final bool isNetwork;

  const ResponsiveImage({
    super.key,
    required this.imagePath,
    this.heightPercentage = 35,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageHeight = screenSize.height * (heightPercentage / 100);
    
    return SizedBox(
      height: imageHeight,
      width: double.infinity,
      child: isNetwork
          ? Image.network(
              imagePath,
              fit: fit,
              alignment: alignment,
            )
          : Image.asset(
              imagePath,
              fit: fit,
              alignment: alignment,
            ),
    );
  }
}

/// Extension to add responsive sizing to numbers
extension ResponsiveSize on num {
  /// Get responsive height based on screen height percentage
  double h(BuildContext context) {
    return MediaQuery.of(context).size.height * (this / 100);
  }

  /// Get responsive width based on screen width percentage
  double w(BuildContext context) {
    return MediaQuery.of(context).size.width * (this / 100);
  }

  /// Get responsive size based on the smaller dimension
  double sp(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final min = size.width < size.height ? size.width : size.height;
    return (this / 375) * min;
  }
}
