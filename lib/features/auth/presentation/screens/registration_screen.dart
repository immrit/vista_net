import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const RegistrationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'نام و نام خانوادگی را وارد کنید';
    }
    if (value.trim().length < 3) {
      return 'نام باید حداقل ۳ حرف باشد';
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length != 10) {
      return 'کد ملی باید ۱۰ رقم باشد';
    }
    return null;
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.snappPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.snappDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ref.read(authProvider.notifier).clearError();

      final success = await ref
          .read(authProvider.notifier)
          .register(
            fullName: _fullNameController.text.trim(),
            nationalId: _nationalIdController.text.isEmpty
                ? null
                : _nationalIdController.text.trim(),
            birthDate: _birthDate,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ثبت‌نام با موفقیت انجام شد'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to main screen - auth state listener will handle this
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'خطا در ثبت‌نام'),
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
          'ثبت‌نام',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.snappPrimary.withValues(alpha: 0.1),
                        AppTheme.snappSecondary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: AppTheme.snappPrimary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'تکمیل اطلاعات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.snappDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'شماره موبایل: ${widget.phoneNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.snappGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  validator: _validateFullName,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'نام و نام خانوادگی *',
                    hintText: 'مثال: علی احمدی',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppTheme.snappPrimary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // National ID Field (Optional)
                TextFormField(
                  controller: _nationalIdController,
                  validator: _validateNationalId,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'کد ملی (اختیاری)',
                    hintText: '0123456789',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: AppTheme.snappPrimary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Birth Date Field (Optional)
                InkWell(
                  onTap: _selectBirthDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'تاریخ تولد (اختیاری)',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: AppTheme.snappPrimary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}'
                          : 'انتخاب کنید',
                      style: TextStyle(
                        color: _birthDate != null
                            ? AppTheme.snappDark
                            : AppTheme.snappGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

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
                          'ثبت‌نام و ورود',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
