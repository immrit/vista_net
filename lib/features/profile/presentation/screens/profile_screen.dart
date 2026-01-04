import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../../service_requests/presentation/providers/my_tickets_provider.dart';
import '../../../support/presentation/screens/feedback_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../../models/ticket_model.dart';
import '../../../main/presentation/providers/main_scaffold_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final user = ref.watch(currentUserProvider);
    final walletState = ref.watch(walletProvider);
    final ticketsAsync = ref.watch(myTicketsProvider);

    final phone = user?['phone_number'] ?? '';
    final name = user?['full_name'] as String? ?? 'کاربر';

    // Calculate active tickets count
    final activeTicketsCount =
        ticketsAsync.value
            ?.where(
              (t) =>
                  t.status != TicketStatus.completed &&
                  t.status != TicketStatus.cancelled,
            )
            .length ??
        0;

    final formattedBalance = NumberFormat(
      '#,###',
      'fa_IR',
    ).format(walletState.balance);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // endDrawer: const HamburgerMenu(), // Removed to use MainScreen's drawer
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.snappPrimary,
            elevation: 0,
            leading: const SizedBox(),
            actions: [
              Container(
                margin: const EdgeInsets.only(left: 16),
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
            title: const Text(
              'پروفایل کاربری',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.snappPrimary,
                          AppTheme.snappSecondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Profile Info
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40), // Offset for AppBar
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppTheme.snappLightGray,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 70,
                                  color: AppTheme.snappPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: InkWell(
                                onTap: _showEditProfileDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.snappSecondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Vazir',
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'Vazir',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats & Menu Items
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      title: 'درخواست‌های فعال',
                      value: '$activeTicketsCount',
                      icon: Icons.confirmation_number_rounded,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      title: 'کیف پول',
                      value: formattedBalance,
                      unit: 'تومان',
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.orange,
                      flex: 1.5,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'ویرایش پروفایل',
                  subtitle: 'تغییر نام و اطلاعات کاربری',
                  onTap: _showEditProfileDialog,
                ),
                _buildMenuItem(
                  icon: Icons.folder_special_rounded,
                  title: 'کیف مدارک من (گاوصندوق)',
                  subtitle: 'مدیریت مدارک و اسناد',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentsScreen(),
                    ),
                  ),
                ),
                _buildMenuItem(
                  icon: Icons.settings_rounded,
                  title: 'تنظیمات',
                  subtitle: 'امنیت، اعلان‌ها و زبان',
                  onTap: _showSettingsDialog,
                ),
                _buildMenuItem(
                  icon: Icons.feedback_rounded,
                  title: 'بازخورد و پیشنهادات',
                  subtitle: 'نظرات خود را با ما در میان بگذارید',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackScreen(),
                    ),
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey.shade300),
                ),

                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'درباره ویستانت',
                  subtitle: 'نسخه 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ویستانت',
                      applicationVersion: '1.0.0',
                      applicationIcon: Container(
                        width: 50,
                        height: 50,
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
                          Icons.layers,
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
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('خروج از حساب کاربری'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final user = ref.read(currentUserProvider);
    final nameController = TextEditingController(text: user?['full_name']);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ویرایش پروفایل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                  color: AppTheme.snappPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'نام و نام خانوادگی',
                  labelStyle: const TextStyle(fontFamily: 'Vazir'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.snappPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty) return;
                        setModalState(() => isLoading = true);
                        try {
                          await ref
                              .read(authProvider.notifier)
                              .updateProfile(
                                fullName: nameController.text.trim(),
                              );
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('پروفایل با موفقیت بروز شد'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('خطا: $e')));
                          }
                        } finally {
                          if (context.mounted) {
                            setModalState(() => isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.snappPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'ذخیره تغییرات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تنظیمات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
                color: AppTheme.snappPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsItem(
              icon: Icons.notifications_active_rounded,
              title: 'اعلان‌ها',
              value: true,
              onChanged: (val) {},
            ),
            _buildSettingsItem(
              icon: Icons.fingerprint_rounded,
              title: 'ورود با اثر انگشت',
              value: false,
              onChanged: (val) {},
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_rounded,
              title: 'حالت شب',
              value: false,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Vazir',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.snappPrimary,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? unit,
    required IconData icon,
    required Color color,
    double flex = 1,
  }) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (unit != null)
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Vazir',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'Vazir',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.snappPrimary.withValues(alpha: 0.1),
                    AppTheme.snappPrimary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.snappPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
