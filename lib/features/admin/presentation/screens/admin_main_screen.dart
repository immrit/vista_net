import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../providers/admin_mode_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_tickets_screen.dart';
import 'admin_users_screen.dart';
import 'admin_finance_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminTicketsScreen(),
    const AdminUsersScreen(),
    const AdminFinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            if (index == 4) {
              // Switch to client mode
              ref.read(adminModeProvider.notifier).switchToClient();
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.snappPrimary.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppTheme.snappGray),
              selectedIcon: Icon(Icons.dashboard, color: AppTheme.snappPrimary),
              label: 'داشبورد',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.confirmation_number_outlined,
                color: AppTheme.snappGray,
              ),
              selectedIcon: Icon(
                Icons.confirmation_number,
                color: AppTheme.snappPrimary,
              ),
              label: 'تیکت‌ها',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline, color: AppTheme.snappGray),
              selectedIcon: Icon(Icons.people, color: AppTheme.snappPrimary),
              label: 'کاربران',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.snappGray,
              ),
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.snappPrimary,
              ),
              label: 'مالی',
            ),
            // Client Mode Switch
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.orange),
              selectedIcon: Icon(Icons.person, color: Colors.orange),
              label: 'حالت کاربر',
            ),
          ],
        ),
      ),
    );
  }
}
