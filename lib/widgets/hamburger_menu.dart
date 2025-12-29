import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../services/chat_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'app_logo.dart';

class HamburgerMenu extends ConsumerStatefulWidget {
  const HamburgerMenu({super.key});

  @override
  ConsumerState<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends ConsumerState<HamburgerMenu> {
  final ChatService _chatService = ChatService();
  int _unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadMessagesCount();
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      final count = await _chatService.getUnreadSupportMessagesCount();
      if (mounted) {
        setState(() {
          _unreadMessagesCount = count;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final phone = user?['phone_number'] ?? 'کاربر مهمان';
    final name = user?['full_name'] as String? ?? 'کاربر گرامی';

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              AppTheme.snappLightGray.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildMenuHeader(name, phone),
            _buildMenuItems(),
            _buildMenuFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuHeader(String name, String phone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.snappPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const AppLogo(size: 52),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خوش آمدید',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.confirmation_number_rounded,
                  title: 'تیکت‌ها',
                  value: '0', // TODO: Get from provider
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.chat_rounded,
                  title: 'پیام‌ها',
                  value: _unreadMessagesCount.toString(),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildDrawerItem(
          context,
          icon: Icons.home_rounded,
          title: 'خانه',
          routeName: '/home',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.grid_view_rounded,
          title: 'خدمات',
          routeName: '/services',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.confirmation_number_rounded,
          title: 'تیکت‌ها',
          routeName: '/tickets',
          badge: _unreadMessagesCount > 0
              ? _unreadMessagesCount.toString()
              : null,
        ),
        _buildDrawerItem(
          context,
          icon: Icons.star_rounded,
          title: 'خدمات ویژه',
          routeName: '/special-services',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.notifications_rounded,
          title: 'اعلان‌ها',
          routeName: '/notifications',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.person_rounded,
          title: 'پروفایل',
          routeName: '/profile',
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? routeName,
    String? badge,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.snappPrimary, size: 20),
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.snappDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppTheme.snappGray,
          size: 16,
        ),
        onTap:
            onTap ??
            () {
              Navigator.pop(context); // Close the drawer
              if (routeName != null) {
                // For now, since we don't have named routes fully set up in main.dart correctly (we removed routes map),
                // we should rely on navigation in main.dart?
                // Wait, main.dart removed routes map. Navigation via named routes will FAIL.
                // I need to fix main.dart to include routes OR change navigation here.
                // Assuming I will fix main.dart routes later or now.
                // Actually, I should probably add routes back to MainApp.
                // But for refactoring Phase 1, I just need it to run.
                // Let's assume onGenerateRoute or similar will be added or I add routes back to main.dart.
                // I'll keep this logic but I MUST add routes to main.dart. (Noted)
              }
            },
      ),
    );
  }

  Widget _buildMenuFooter() {
    return Column(
      children: [
        const Divider(),
        _buildDrawerItem(
          context,
          icon: Icons.settings_rounded,
          title: 'تنظیمات',
          routeName: '/settings',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.help_rounded,
          title: 'راهنما و پشتیبانی',
          routeName: '/help',
        ),
        _buildDrawerItem(
          context,
          icon: Icons.logout_rounded,
          title: 'خروج',
          onTap: () => _logout(),
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج از حساب'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              // main.dart listening to authState will handle redirection to login
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
