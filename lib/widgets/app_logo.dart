import 'package:flutter/material.dart';

import '../config/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 36,
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
    final baseStyle =
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        );
    final resolvedTextStyle = textStyle == null
        ? baseStyle
        : baseStyle?.merge(textStyle) ?? textStyle;

    Widget logoImage = Image.asset(
      useTransparent ? AppAssets.logoTransparent : AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_rounded,
          size: size,
          color: Colors.grey,
        );
      },
    );

    if (color != null) {
      logoImage = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: logoImage,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoImage,
        if (showTitle) ...[
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              'ویستا نت',
              style: resolvedTextStyle,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
