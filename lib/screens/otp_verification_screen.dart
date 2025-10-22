import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';
import '../config/app_theme.dart';
import 'main_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String fullName;
  final String? nationalId;
  final DateTime? birthDate;
  final bool isLogin;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.fullName,
    this.nationalId,
    this.birthDate,
    this.isLogin = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  late final TextEditingController _otpController;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _sendInitialCode();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
        if (_resendTimer > 0 && mounted) {
          _startResendTimer();
        }
      }
    });
  }

  Future<void> _sendInitialCode() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.sendVerificationCode(widget.phoneNumber);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    // Check if controller is still valid and mounted
    if (!mounted) {
      return;
    }

    if (_otpController.text.isEmpty) {
      return;
    }

    if (_otpController.text.length != 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً کد 5 رقمی را کامل وارد کنید'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // First verify the code
    final verifyResult = await _authService.verifyPhoneNumber(
      widget.phoneNumber,
      _otpController.text,
    );

    if (verifyResult['success']) {
      // Register or login the user
      if (!widget.isLogin) {
        // This is a new registration
        final registerResult = await _authService.registerUser(
          widget.phoneNumber,
          widget.fullName,
          nationalId: widget.nationalId,
          birthDate: widget.birthDate,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (registerResult['success']) {
            // Navigate to home screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(registerResult['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // This is a login
        // Fetch user profile and save session
        final profile = await _authService.getUserProfileByPhone(
          widget.phoneNumber,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (profile != null) {
            // Navigate to home screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('خطا در بارگذاری اطلاعات کاربر'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResult['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend || !mounted) return;

    setState(() {
      _isResending = true;
      _canResend = false;
      _resendTimer = 60;
    });

    final result = await _authService.sendVerificationCode(widget.phoneNumber);

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _canResend = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isLogin ? 'ورود' : 'ثبت‌نام',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.snappPrimary.withOpacity(0.3),
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
                ),
                const SizedBox(height: 32),

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
                      selectedFillColor: AppTheme.snappPrimary.withOpacity(0.1),
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
                      if (mounted) {
                        _verifyCode();
                      }
                    },
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (mounted) {
                            _verifyCode();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.snappPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.snappPrimary.withOpacity(0.4),
                  ),
                  child: _isLoading
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
                                  : 'ارسال مجدد ($_resendTimer ثانیه)',
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
