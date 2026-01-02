import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../service_requests/presentation/screens/my_tickets_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../services/presentation/screens/services_screen.dart';
import '../../../admin/presentation/providers/admin_mode_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminModeNotifier = ref.read(adminModeProvider.notifier);
    final isAdmin = adminModeNotifier.isAdmin;

    final screens = [
      const HomeScreen(),
      const ServicesScreen(),
      const MyTicketsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: isAdmin
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                // Admin Mode Button - only visible for admin users
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () {
                      ref.read(adminModeProvider.notifier).switchToAdmin();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.snappPrimary,
                            AppTheme.snappSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    tooltip: 'پنل مدیریت',
                  ),
                ),
              ],
            )
          : null,
      body: screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppTheme.snappPrimary,
                  unselectedItemColor: AppTheme.snappGray,
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
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'خانه',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view),
                      activeIcon: Icon(Icons.grid_view_rounded),
                      label: 'خدمات',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.confirmation_number_outlined),
                      activeIcon: Icon(Icons.confirmation_number_rounded),
                      label: 'درخواست‌ها',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded),
                      label: 'پروفایل',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
