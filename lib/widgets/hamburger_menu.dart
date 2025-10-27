import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({super.key});

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
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
            colors: [Colors.white, AppTheme.snappLightGray.withOpacity(0.3)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildMenuHeader(),
            _buildMenuItems(),
            _buildMenuFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuHeader() {
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
            color: AppTheme.snappPrimary.withOpacity(0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
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
                      'کاربر گرامی',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
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
                  value: '0',
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.chat_rounded,
                  title: 'پیام‌ها',
                  value: _unreadMessagesCount.toString(),
                  color: Colors.white.withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.8),
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
            color: Colors.black.withOpacity(0.05),
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
                color: AppTheme.snappPrimary.withOpacity(0.1),
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
                Navigator.pushNamed(context, routeName);
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
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
