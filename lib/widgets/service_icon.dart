import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ServiceIcon extends StatelessWidget {
  final String? imageUrl;
  final String iconName;
  final double size;
  final Color? iconColor;
  final double? containerSize;
  final Color? backgroundColor;
  final bool usePadding;
  final bool isNew; // Added for generic badge support if needed later

  const ServiceIcon({
    super.key,
    required this.imageUrl,
    required this.iconName,
    this.size = 32, // Slightly larger default for better visibility
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
        containerSize ?? 65.0; // Default size from design

    return Stack(
      children: [
        Container(
          width: effectiveContainerSize,
          height: effectiveContainerSize,
          clipBehavior: Clip.hardEdge,

          padding: usePadding ? const EdgeInsets.all(12) : null,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                Colors.white, // Light background for consistency
            borderRadius: BorderRadius.circular(22), // Squircle-ish radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    color: Colors.redAccent.withOpacity(0.4),
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
    // If we have an image URL, try to load it
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size, // Use provided icon size
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size * 0.6,
            height: size * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.5),
              ),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    // Fallback to icon
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
