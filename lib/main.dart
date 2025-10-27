import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/support_chat_screen.dart';
import 'screens/dynamic_services_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/special_services_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vista Net',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/support-chat': (context) => const SupportChatScreen(),
        '/services': (context) => const DynamicServicesScreen(),
        '/tickets': (context) => const TicketsScreen(),
        '/special-services': (context) => const SpecialServicesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit for Supabase to initialize
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if user is authenticated
    return FutureBuilder<bool>(
      future: _authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
