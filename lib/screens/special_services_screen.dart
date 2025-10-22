import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SpecialServicesScreen extends StatelessWidget {
  const SpecialServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text('سرویس‌های ویژه'),
        backgroundColor: AppTheme.snappPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 80,
              color: AppTheme.snappPrimary.withOpacity(0.5),
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
