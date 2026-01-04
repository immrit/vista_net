import 'dart:ui';
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
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                // Gradient for glass effect
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.grey.shade900.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      if (index == 4) {
                        // Switch to client mode
                        ref.read(adminModeProvider.notifier).switchToClient();
                      } else {
                        setState(() {
                          _currentIndex = index;
                        });
                      }
                    },
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: AppTheme.snappPrimary,
                    unselectedItemColor: Colors.grey.shade400,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedFontSize: 11,
                    unselectedFontSize: 10,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Vazir',
                    ),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        activeIcon: Icon(Icons.dashboard),
                        label: 'داشبورد',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.confirmation_number_outlined),
                        activeIcon: Icon(Icons.confirmation_number),
                        label: 'تیکت‌ها',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people_outline),
                        activeIcon: Icon(Icons.people),
                        label: 'کاربران',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_balance_wallet_outlined),
                        activeIcon: Icon(Icons.account_balance_wallet),
                        label: 'مالی',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.orange,
                        ),
                        activeIcon: Icon(
                          Icons.swap_horiz_rounded,
                          color: Colors.orange,
                        ),
                        label: 'خروج از ادمین',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
