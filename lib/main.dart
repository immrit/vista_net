import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'screens/main_screen.dart';

import 'features/service_requests/presentation/screens/my_tickets_screen.dart';
import 'models/service_model.dart';
import 'screens/billing_screen.dart';
import 'screens/service_form_screen.dart';
import 'screens/service_payments_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اینیشیالایز کردن سوپابیس
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // گوش دادن به وضعیت احراز هویت (Custom Auth State)
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Vista Net',
      theme: ThemeData(fontFamily: 'Vazir', primarySwatch: Colors.blue),
      home: _buildHome(authState),
      debugShowCheckedModeBanner: false,
      routes: {
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
        return null; // Let onUnknownRoute handle it if we had one, or default error.
      },
    );
  }

  Widget _buildHome(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
        // Still checking auth status
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.authenticated:
        // User is logged in
        return const MainScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.needsRegistration:
        // Not logged in
        return const LoginScreen();
    }
  }
}
