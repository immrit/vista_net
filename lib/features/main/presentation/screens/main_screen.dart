import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../service_requests/presentation/screens/my_tickets_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../services/presentation/screens/services_screen.dart';
import '../../../admin/presentation/providers/admin_mode_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../widgets/hamburger_menu.dart';
import '../providers/main_scaffold_provider.dart';

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
      const NotificationsScreen(),
      const MyTicketsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: ref.watch(mainScaffoldKeyProvider),
      extendBody: true,
      appBar: null,
      endDrawer: const HamburgerMenu(),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.6),
                    Colors.white.withValues(alpha: 0.4),
                  ],
                ),
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
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      // Check if the tapped item is the Admin item (index 5)
                      if (isAdmin && index == 5) {
                        ref.read(adminModeProvider.notifier).switchToAdmin();
                        return;
                      }
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
                    selectedFontSize: 10,
                    unselectedFontSize: 9,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Vazir',
                    ),
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home_rounded),
                        label: 'خانه',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.grid_view),
                        activeIcon: Icon(Icons.grid_view_rounded),
                        label: 'خدمات',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_none_outlined),
                        activeIcon: Icon(Icons.notifications_rounded),
                        label: 'اعلان‌ها',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.confirmation_number_outlined),
                        activeIcon: Icon(Icons.confirmation_number_rounded),
                        label: 'درخواست‌ها',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded),
                        activeIcon: Icon(Icons.person_rounded),
                        label: 'پروفایل',
                      ),
                      if (isAdmin)
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.admin_panel_settings_outlined),
                          activeIcon: Icon(Icons.admin_panel_settings_rounded),
                          label: 'مدیریت',
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
