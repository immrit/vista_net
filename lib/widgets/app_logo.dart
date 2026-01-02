import 'package:flutter/material.dart';

import '../config/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 45,
    this.showTitle = false,
    this.spacing = 8,
    this.textStyle,
    this.color,
    this.useTransparent = false,
  });

  final double size;
  final bool showTitle;
  final double spacing;
  final TextStyle? textStyle;
  final Color? color;
  final bool useTransparent;

  @override
  Widget build(BuildContext context) {
    // If showTitle is true, we use the integrated Typography Logo
    if (showTitle) {
      Widget typographyLogo = Image.asset(
        AppAssets.logoTypography,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_rounded,
                size: size,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text('VistaNet'),
            ],
          );
        },
      );

      // Apply BlendMode.multiply to hide white background
      // This makes white pixels transparent when drawn over other colors
      typographyLogo = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.multiply),
        child: typographyLogo,
      );

      if (color != null) {
        typographyLogo = ColorFiltered(
          colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
          child: typographyLogo,
        );
      }
      return typographyLogo;
    }

    // Otherwise, show just the Icon
    Widget logoImage = Image.asset(
      useTransparent ? AppAssets.logoTransparent : AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_rounded,
          size: size,
          color: Colors.transparent,
        );
      },
    );

    if (color != null) {
      logoImage = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: logoImage,
      );
    }

    return logoImage;
  }
}
