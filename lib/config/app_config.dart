class AppConfig {
  // Supabase Configuration
  // Replace with your actual Supabase project credentials
  static const String supabaseUrl = 'https://lynxhjvmosxggrswhtud.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5bnhoanZtb3N4Z2dyc3dodHVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyNTM0NDYsImV4cCI6MjA3NTgyOTQ0Nn0.9JUbn1i3fXgtGBrvTMAppX0ABTYp6p4sdPvJQ2hEesA';

  // App Configuration
  static const String appName = 'Vista Net';
  static const String appVersion = '1.0.0';

  // SMS Configuration
  static const int otpLength = 5;
  static const int otpExpirationMinutes = 5;
  static const int resendCooldownSeconds = 60;
}
