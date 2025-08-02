import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String? assetPath;
  final IconData? iconData;
  final double size;
  final Color? color;

  const CustomIcon({
    super.key,
    this.assetPath,
    this.iconData,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: size,
        height: size,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default icon if asset not found
          return Icon(
            iconData ?? Icons.apps,
            size: size,
            color: color,
          );
        },
      );
    } else {
      return Icon(
        iconData ?? Icons.apps,
        size: size,
        color: color,
      );
    }
  }
}