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

  // Arvan Cloud S3 Configuration
  static const String arvanEndpoint = 's3.ir-thr-at1.arvanstorage.ir';
  static const String arvanAccessKey = '7e5941c1-9eb4-430b-8700-2a47c4a707ba';
  static const String arvanSecretKey =
      '3e0ec2707773f6c7d9717ada23b6ce40870ad2789887ffc86d9b18e02b07224c';
  static const String arvanBucketName = 'vistanet-manager';

  // File Upload Configuration
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];
}
