import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../config/app_theme.dart';

// Custom Cache Manager for 30 days persistence
class CustomCacheManager {
  static const key = 'customServiceIconsCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

class ServiceIcon extends StatelessWidget {
  final String? imageUrl;
  final String iconName;
  final double size;
  final Color? iconColor;
  final double? containerSize;
  final Color? backgroundColor;
  final bool usePadding;
  final bool isNew;

  const ServiceIcon({
    super.key,
    required this.imageUrl,
    required this.iconName,
    this.size = 80, // Standardized icon size
    this.iconColor,
    this.containerSize,
    this.backgroundColor,
    this.usePadding = true,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    // Default container style based on reference image
    // Dark background, squircle shape
    final effectiveContainerSize =
        containerSize ?? 64.0; // Standardized container size

    return Stack(
      children: [
        Container(
          width: effectiveContainerSize,
          height: effectiveContainerSize,
          clipBehavior: Clip.hardEdge,

          padding: usePadding
              ? EdgeInsets.all(effectiveContainerSize * 0.05)
              : null,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                Colors.white, // Light background for consistency
            borderRadius: BorderRadius.circular(22), // Squircle-ish radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Center(child: _buildContent()),
        ),
        if (isNew)
          Positioned(
            top: -5,
            left: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'جدید',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    // If we have an image URL, try to load it - fill the entire container
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // For images, use the full container size (minus padding if applied)
      final effectiveContainerSize = containerSize ?? 64.0;
      final imageSize = usePadding
          ? effectiveContainerSize - (effectiveContainerSize * 0.05 * 2)
          : effectiveContainerSize;

      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          cacheManager: CustomCacheManager.instance,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain, // Cover to fill the space
          placeholder: (context, url) => Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[100],
          ),
          errorWidget: (context, url, error) => _buildFallbackIcon(),
        ),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Icon(
      _getServiceIcon(iconName),
      color: iconColor ?? AppTheme.snappPrimary,
      size: size,
    );
  }

  IconData _getServiceIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'document':
        return Icons.description_rounded;
      case 'certificate':
        return Icons.verified_rounded;
      case 'license':
        return Icons.card_membership_rounded;
      case 'permit':
        return Icons.assignment_rounded;
      case 'registration':
        return Icons.app_registration_rounded;
      case 'renewal':
        return Icons.refresh_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'consultation':
        return Icons.psychology_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
