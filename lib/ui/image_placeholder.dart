import 'package:flutter/material.dart';

/// Stand-in for the photos in the design. Swap for Image.asset/network
/// when real images are available.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    super.key,
    required this.colors,
    this.icon,
    this.radius = 12,
    this.width,
    this.height,
  });

  final List<Color> colors;
  final IconData? icon;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: icon == null
          ? null
          : Center(child: Icon(icon, color: Colors.white54, size: 30)),
    );
  }
}
