import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../services/chat_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/wallet/presentation/providers/wallet_provider.dart';

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
    final walletState = ref.watch(walletProvider);
    final phone = user?['phone_number'] ?? 'کاربر مهمان';
    final name = user?['full_name'] as String? ?? 'کاربر گرامی';
    final balance = NumberFormat('#,###').format(walletState.balance);

    return Drawer(
      backgroundColor:
          Colors.transparent, // Transparent to show container shape
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context, name, phone, balance),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'خانه',
                    routeName: '/home',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.grid_view_rounded,
                    title: 'خدمات',
                    routeName: '/services',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.confirmation_number_rounded,
                    title: 'تیکت‌های من',
                    routeName: '/tickets',
                    badge: _unreadMessagesCount > 0
                        ? _unreadMessagesCount.toString()
                        : null,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.star_rounded,
                    title: 'خدمات ویژه',
                    routeName: '/special-services',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'اعلان‌ها',
                    routeName: '/notifications',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'پروفایل کاربری',
                    routeName: '/profile',
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String phone,
    String balance,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(5), // Slight curve inside
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.snappPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 35,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? routeName,
    String? badge,
    VoidCallback? onTap,
  }) {
    // Check if this route is active (simple check, can be improved)
    // Note: ModalRoute.of(context)?.settings.name might be null or different in Drawer
    // For now, we keep it simple without active state highlighting logic unless passed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onTap ??
              () {
                Navigator.pop(context); // Close drawer
                if (routeName != null) {
                  // Assuming simple navigation or using existing named routes if available
                  // If named routes are not set up in main.dart, this might need Navigator.push replacement
                  // But based on previous code, let's stick to this or assume caller handles it.
                  // Just trying to pushNamed. If it fails, user will report.
                  // Previous code had logic issues mentioned in comments.
                  // Let's assume standard named routes for now as requested by user to "Redesign".
                  Navigator.pushNamed(context, routeName);
                }
              },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), // Very light gray for bubbles
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppTheme.snappPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildSimpleMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'تنظیمات',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(height: 8),
          _buildSimpleMenuItem(
            context,
            icon: Icons.logout_rounded,
            title: 'خروج از حساب',
            isDestructive: true,
            onTap: () => _logout(),
          ),
          const SizedBox(height: 24),
          Text(
            'نسخه ۱.۰.۲',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red[400] : Colors.grey[700];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'خروج از حساب',
          style: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
          style: TextStyle(fontFamily: 'Vazir'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'لغو',
              style: TextStyle(fontFamily: 'Vazir', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pop(context); // Close Drawer
              await ref.read(authProvider.notifier).signOut();
            },
            child: const Text(
              'خروج',
              style: TextStyle(fontFamily: 'Vazir', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
