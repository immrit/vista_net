import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';
import 'services/session_storage_service.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/admin/presentation/screens/admin_main_screen.dart';
import 'features/admin/presentation/providers/admin_mode_provider.dart';

import 'features/service_requests/presentation/screens/my_tickets_screen.dart';
import 'models/service_model.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/service_requests/presentation/screens/service_form_screen.dart';
import 'features/wallet/presentation/screens/service_payments_screen.dart';
import 'features/services/presentation/screens/services_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/services/presentation/screens/special_services_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/support/presentation/screens/help_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اینیشیالایز کردن Hive برای ذخیره‌سازی آفلاین نشست
  await SessionStorageService.init();

  // اینیشیالایز کردن سوپابیس
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Vista Net',
      theme: ThemeData(fontFamily: 'Vazir', primarySwatch: Colors.blue),
      // Localization setup
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // Persian
      ],
      locale: const Locale('fa', 'IR'), // Force Persian

      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const MainScreen(),
        '/services': (context) => const ServicesScreen(),
        '/tickets': (context) => const MyTicketsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/special-services': (context) => const SpecialServicesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
        '/billing': (context) => const BillingScreen(),
        '/service-payments': (context) => const ServicePaymentsScreen(),
        '/support-chat': (context) => const MyTicketsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/service-form') {
          final service = settings.arguments as Service;
          return MaterialPageRoute(
            builder: (context) => ServiceFormScreen(service: service),
          );
        }
        return null;
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isInAdminMode = ref.watch(adminModeProvider);

    // Only show global loading on app startup (initial check)
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.status == AuthStatus.authenticated) {
      // Show admin or client mode based on provider state
      if (isInAdminMode) {
        return const AdminMainScreen();
      }
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
