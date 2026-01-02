import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../widgets/hamburger_menu.dart';
import '../../../support/presentation/screens/feedback_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // We don't fetch from shared preferences anymore for auth info
  // We use currentUserProvider

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج از حساب'),
        content: const Text('آیا مطمئن هستید که می‌خواهید خارج شوید؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('خیر'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('بله، خروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      // main.dart will handle navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final phone = user?['phone_number'] ?? '';
    final name = user?['full_name'] as String? ?? 'کاربر';

    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text(
          'پروفایل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
      endDrawer: const HamburgerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.snappPrimary,
                            AppTheme.snappSecondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.snappDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 16, color: AppTheme.snappGray),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              icon: Icons.edit,
              title: 'ویرایش اطلاعات',
              subtitle: 'تغییر نام و اطلاعات شخصی',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('این بخش به زودی فعال می‌شود')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.folder_special,
              title: 'کیف مدارک من (گاوصندوق)',
              subtitle: 'مدیریت مدارک و اسناد',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.notifications,
              title: 'اعلان‌ها',
              subtitle: 'مدیریت اعلان‌های برنامه',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('این بخش به زودی فعال می‌شود')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.security,
              title: 'امنیت',
              subtitle: 'تنظیمات امنیتی حساب کاربری',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('این بخش به زودی فعال می‌شود')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help,
              title: 'راهنما و پشتیبانی',
              subtitle: 'سوالات متداول و تماس با پشتیبانی',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('این بخش به زودی فعال می‌شود')),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.feedback,
              title: 'بازخورد و پیشنهادات',
              subtitle: 'نظرات خود را با ما در میان بگذارید',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.info,
              title: 'درباره برنامه',
              subtitle: 'نسخه 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ویستانت',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.snappPrimary,
                          AppTheme.snappSecondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'خروج از حساب کاربری',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.snappPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.snappPrimary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: AppTheme.snappGray),
        ),
        trailing: Icon(Icons.chevron_left, color: AppTheme.snappGray),
        onTap: onTap,
      ),
    );
  }
}
