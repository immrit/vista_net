import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text('تنظیمات'),
        backgroundColor: AppTheme.snappPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: 'حساب کاربری',
            items: [
              _buildSettingsItem(
                icon: Icons.person_rounded,
                title: 'اطلاعات شخصی',
                subtitle: 'ویرایش پروفایل',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.security_rounded,
                title: 'امنیت',
                subtitle: 'رمز عبور و احراز هویت',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'اعلان‌ها',
            items: [
              _buildSettingsItem(
                icon: Icons.notifications_rounded,
                title: 'اعلان‌های اپلیکیشن',
                subtitle: 'مدیریت اعلان‌ها',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.email_rounded,
                title: 'ایمیل',
                subtitle: 'اعلان‌های ایمیل',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'عمومی',
            items: [
              _buildSettingsItem(
                icon: Icons.language_rounded,
                title: 'زبان',
                subtitle: 'فارسی',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.dark_mode_rounded,
                title: 'تم',
                subtitle: 'روشن',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.snappDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.snappPrimary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.snappDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.snappGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.snappGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
