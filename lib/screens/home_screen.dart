import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text('خانه'),
        backgroundColor: AppTheme.snappPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 80,
              color: AppTheme.snappPrimary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'خوش آمدید',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: AppTheme.snappPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'صفحه اصلی اپلیکیشن',
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
