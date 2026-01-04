import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../../../../config/app_assets.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'شماره موبایل را وارد کنید';
    }
    if (value.length != 11 || !value.startsWith('09')) {
      return 'شماره موبایل معتبر نیست';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Temporary: Comment out unfocus to debug HardwareKeyboard crash
      // FocusScope.of(context).unfocus();

      debugPrint('🚀 Submitting Login Form for: ${_phoneController.text}');

      // Clear any previous errors
      ref.read(authProvider.notifier).clearError();

      // Send OTP using new provider
      debugPrint('⏳ Sending OTP...');
      final success = await ref
          .read(authProvider.notifier)
          .sendOtp(_phoneController.text);

      debugPrint('✅ Send OTP Result: $success');

      if (!mounted) {
        debugPrint('⚠️ Widget unmounted after OTP send');
        return;
      }

      if (success) {
        debugPrint('➡️ Navigating to OTP Screen...');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpVerificationScreen(phoneNumber: _phoneController.text),
          ),
        );
      } else {
        final error = ref.read(authProvider).error;
        debugPrint('❌ OTP Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'خطا در ارسال کد'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mobile Illustrator Image
                  Container(
                    height: 180, // Increased height for better visibility
                    width: 180,
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.loginMobile,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to old icon if image missing
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.snappPrimary,
                                AppTheme.snappSecondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.snappPrimary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.phone_android_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Title
                  const Text(
                    'ویستانت',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.snappDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'خوش آمدید',
                    style: TextStyle(fontSize: 18, color: AppTheme.snappGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    style: const TextStyle(fontSize: 20, letterSpacing: 2),
                    decoration: InputDecoration(
                      labelText: 'شماره موبایل',
                      hintText: '09123456789',
                      hintStyle: TextStyle(
                        color: AppTheme.snappGray,
                        letterSpacing: 2,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_iphone,
                        size: 24,
                        color: AppTheme.snappPrimary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.snappPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.snappPrimary.withValues(alpha: 0.4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'ادامه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.snappPrimary.withValues(alpha: 0.1),
                          AppTheme.snappSecondary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.snappPrimary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.snappPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'شماره موبایل شما جهت ورود یا ثبت‌نام استفاده می‌شود',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.snappDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
