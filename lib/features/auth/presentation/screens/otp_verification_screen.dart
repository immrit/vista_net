import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../config/app_theme.dart';
import '../../../../config/app_assets.dart';
import '../providers/auth_provider.dart';
import 'registration_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _resendTimer = 60;
  bool _canResend = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    try {
      _otpController.dispose();
    } catch (_) {
      // Ignore if already disposed
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _resendTimer = 60;
    _canResend = false;
    if (mounted) setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    if (!mounted) return;
    if (_otpController.text.length != 5) return;

    final otpCode = _otpController.text; // Store before async
    FocusScope.of(context).unfocus(); // Close keyboard before async operation

    ref.read(authProvider.notifier).clearError();

    final result = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phoneNumber, otpCode);

    if (!mounted) return;

    switch (result) {
      case 'success':
        // User logged in successfully - main.dart will handle navigation
        // Pop back to let the auth state listener redirect
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        return; // Exit early to avoid any further processing

      case 'user_not_found':
        // Navigate to registration screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegistrationScreen(phoneNumber: widget.phoneNumber),
          ),
        );
        break;

      case 'error':
      default:
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'کد تایید نامعتبر است'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    final success = await ref
        .read(authProvider.notifier)
        .sendOtp(widget.phoneNumber);

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('کد تایید مجدداً ارسال شد'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      } else {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'خطا در ارسال مجدد'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تایید شماره موبایل',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // OTP Illustrator Image
                Container(
                  height: 150,
                  width: 150,
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAssets.otpIllustrator,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
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
                          Icons.message_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                const Text(
                  'کد تایید',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.snappDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  'کد 5 رقمی ارسال شده به شماره\n${widget.phoneNumber}\nرا وارد کنید',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.snappGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // OTP Input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 5,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 65,
                      fieldWidth: 55,
                      activeFillColor: Colors.white,
                      inactiveFillColor: AppTheme.snappLightGray,
                      selectedFillColor: AppTheme.snappPrimary.withValues(
                        alpha: 0.1,
                      ),
                      activeColor: AppTheme.snappPrimary,
                      inactiveColor: AppTheme.snappGray,
                      selectedColor: AppTheme.snappPrimary,
                    ),
                    enableActiveFill: true,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    onCompleted: (value) {
                      if (mounted && !isLoading && value.length == 5) {
                        _verifyCode();
                      }
                    },
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          _verifyCode();
                        },
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
                          'تایید و ادامه',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // Resend Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'کد را دریافت نکردید؟ ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.snappGray,
                      ),
                    ),
                    TextButton(
                      onPressed: _canResend && !_isResending
                          ? _resendCode
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: _isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue.shade300,
                              ),
                            )
                          : Text(
                              _canResend
                                  ? 'ارسال مجدد'
                                  : 'ارسال مجدد ($_resendTimer)',
                              style: TextStyle(
                                fontSize: 14,
                                color: _canResend
                                    ? AppTheme.snappPrimary
                                    : AppTheme.snappGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
