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
  });

  final double size;
  final bool showTitle;
  final double spacing;
  final TextStyle? textStyle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            );
    final resolvedTextStyle =
        textStyle == null ? baseStyle : baseStyle?.merge(textStyle) ?? textStyle;

    Widget logoImage = Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
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
          Text(
            'ویستا نت',
            style: resolvedTextStyle,
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}

