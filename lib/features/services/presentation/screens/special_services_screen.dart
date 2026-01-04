import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main/presentation/providers/main_scaffold_provider.dart';

class SpecialServicesScreen extends ConsumerWidget {
  const SpecialServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text(
          'خدمات ویژه',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  ref
                      .read(mainScaffoldKeyProvider)
                      .currentState
                      ?.openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
      // endDrawer: const HamburgerMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 80,
              color: AppTheme.snappPrimary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'سرویس‌های ویژه',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: AppTheme.snappPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'خدمات اختصاصی و ویژه',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.snappGray),
            ),
          ],
        ),
      ),
    );
  }
}
