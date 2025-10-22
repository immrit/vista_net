import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';
import 'dynamic_services_screen.dart';
import 'tickets_screen.dart';
import 'special_services_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 4; // خانه (آخرین آیتم در لیست)

  final List<Widget> _screens = [
    const ProfileScreen(),
    const SpecialServicesScreen(),
    const TicketsScreen(),
    const DynamicServicesScreen(),
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
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.snappPrimary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CrystalNavigationBar(
                currentIndex: _currentIndex,
                height: 10,
                unselectedItemColor: AppTheme.snappGray,
                backgroundColor: Colors.transparent,
                borderRadius: 30,
                outlineBorderColor: Colors.transparent,
                paddingR: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                indicatorColor: AppTheme.snappPrimary,
                selectedItemColor: Colors.white,
                splashBorderRadius: 30,
                enableFloatingNavBar: false,
                enablePaddingAnimation: true,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: [
                  CrystalNavigationBarItem(
                    icon: Icons.person_rounded,
                    unselectedIcon: Icons.person_outline_rounded,
                    selectedColor: AppTheme.snappPrimary,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.star_rounded,
                    unselectedIcon: Icons.star_outline_rounded,
                    selectedColor: AppTheme.snappAccent,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.confirmation_number_rounded,
                    unselectedIcon: Icons.confirmation_number_outlined,
                    selectedColor: AppTheme.snappPrimary,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.grid_view_rounded,
                    unselectedIcon: Icons.grid_view_outlined,
                    selectedColor: AppTheme.snappSecondary,
                  ),
                  CrystalNavigationBarItem(
                    icon: Icons.home_rounded,
                    unselectedIcon: Icons.home_outlined,
                    selectedColor: AppTheme.snappPrimary,
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
