import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';
import 'dynamic_services_screen.dart';
import 'tickets_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 4; // خانه (آخرین آیتم در لیست)

  final List<Widget> _screens = [
    const ProfileScreen(),
    const TicketsScreen(),
    const DynamicServicesScreen(),
    const NotificationsScreen(),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
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
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'پروفایل',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.confirmation_number_outlined),
                    activeIcon: Icon(Icons.confirmation_number_rounded),
                    label: 'تیکت‌ها',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_outlined),
                    activeIcon: Icon(Icons.grid_view_rounded),
                    label: 'خدمات',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_outlined),
                    activeIcon: Icon(Icons.notifications_rounded),
                    label: 'اطلاع رسانی‌ها',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'خانه',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
