import 'package:flutter/material.dart';

import 'app_logo.dart';

class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({
    super.key,
    required this.title,
    this.logoSize = 32,
    this.spacing = 10,
    this.textStyle,
  });

  final String title;
  final double logoSize;
  final double spacing;
  final TextStyle? textStyle;

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            title,
            style: resolvedTextStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }
}
