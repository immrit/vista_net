import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Session management keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _fullNameKey = 'full_name';

  // Format phone number to international format (+98)
  // Converts 09xxxxxxxxx to +98xxxxxxxxx
  // Format phone number to international format (+98)
  // Format phone number to international format (+98)
  // Format phone number to international format (+98)
  String _formatPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('09')) {
      return '+98${digits.substring(1)}'; // 0912 -> +98912
    }
    if (digits.startsWith('98')) return '+$digits'; // 98912 -> +98912
    if (digits.startsWith('9') && digits.length == 10) {
      return '+98$digits'; // 912 -> +98912
    }
    return '+$digits'; // Fallback
  }

  // Send verification code to phone number using Edge Function
  Future<Map<String, dynamic>> sendVerificationCode(String phoneNumber) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    print(
      'Sending Code - Original: $phoneNumber -> Formatted: $formattedPhone',
    );

    Future<Map<String, dynamic>> invokeFunction(String name) async {
      final response = await _supabase.functions.invoke(
        name,
        body: {'phone_number': formattedPhone},
      );

      if (response.data != null && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'کد تایید ارسال شد',
          'rec_id': response.data['rec_id'],
        };
      }
      final errorMessage = response.data?['error'] ?? 'خطا در ارسال کد تایید';
      return {'success': false, 'message': errorMessage};
    }

    try {
      return await invokeFunction('OTP');
    } catch (e) {
      print('Error in sendVerificationCode: $e');
      return {'success': false, 'message': 'خطا در ارسال کد تایید'};
    }
  }

  // Recover session on app start
  Future<Map<String, dynamic>?> recoverSession() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      print('🔄 Recovering session for user: ${user.id}');

      // Try fetching profile by ID first (Most reliable)
      final profileById = await _supabase
          .from('profiles')
          .select('id, phone_number, full_name, is_verified')
          .eq('id', user.id)
          .maybeSingle();

      if (profileById != null) {
        // Update local session just in case
        await _saveUserSession(
          profileById['id'],
          profileById['phone_number'],
          profileById['full_name'] ?? '',
        );
        return profileById;
      }

      // Fallback: Try by phone if ID lookup failed
      return await getUserProfileByPhone(
        user.userMetadata?['phone_number'] ??
            _formatPhoneNumber(user.phone ?? ''),
      );
    } catch (e) {
      print('Error recovering session: $e');
      return null;
    }
  }

  // 2. UPDATED verifyPhoneNumber
  // 2. UPDATED verifyPhoneNumber - Completes the loop!
  Future<Map<String, dynamic>> verifyPhoneNumber(
    String phoneNumber,
    String code,
  ) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    print('🔐 Verifying OTP for: $formattedPhone');

    try {
      // Call Edge Function
      final response = await _supabase.functions.invoke(
        'verify-otp',
        body: {'phone': formattedPhone, 'code': code},
      );

      final data = response.data;

      if (data != null && data['success'] == true && data['session'] != null) {
        // A. Set Session (Login)
        final session = data['session'];
        await _supabase.auth.setSession(session['refresh_token']);
        print('✅ Session set successfully');

        // B. Update Profile immediately (The Missing Link)
        await _completeRegistrationProfileIfNeeded();

        // C. Refresh local user data
        final user = _supabase.auth.currentUser;
        if (user != null) {
          final profile = await getUserProfileByPhone(formattedPhone);
          if (profile != null) {
            await _saveUserSession(
              user.id,
              formattedPhone,
              profile['full_name'] ?? 'کاربر',
            );
          }
        }

        return {'success': true, 'message': 'ورود موفقیت‌آمیز'};
      } else {
        return {
          'success': false,
          'message': data?['error'] ?? 'کد تایید نامعتبر است',
        };
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return {'success': false, 'message': 'خطا در تایید شماره موبایل'};
    }
  }

  // 3. Helper to create/update profile
  Future<void> _completeRegistrationProfileIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingName = prefs.getString('temp_reg_fullname');
      final pendingNationalId = prefs.getString('temp_reg_national_id');

      if (pendingName != null) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          print('👤 Creating profile for user: ${user.id} Name: $pendingName');

          final phone =
              user.userMetadata?['phone_number'] ??
              _formatPhoneNumber(user.phone ?? '');

          await _supabase.from('profiles').upsert({
            'id': user.id,
            'full_name': pendingName,
            'national_id': pendingNationalId,
            'phone_number': phone,
            'is_verified': true, // Auto-verify since they passed OTP
            'updated_at': DateTime.now().toIso8601String(),
          });

          print('✨ Profile created successfully!');

          // Cleanup
          await prefs.remove('temp_reg_fullname');
          await prefs.remove('temp_reg_national_id');
        }
      } else {
        print(
          '⚠️ No pending registration data found. This might be a Login, not Registration.',
        );
      }
    } catch (e) {
      print('❌ Failed to update profile: $e');
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final result = await _supabase
          .from('profiles')
          .select('id')
          .eq('phone_number', formattedPhone)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // 1. REPLACED registerUser
  // 1. REPLACED registerUser - Saves data first!
  Future<Map<String, dynamic>> registerUser(
    String phoneNumber,
    String fullName, {
    String? nationalId,
    DateTime? birthDate,
  }) async {
    try {
      print('📝 Starting Registration Flow for $phoneNumber');

      // A. Save details temporarily (CRITICAL STEP)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_reg_fullname', fullName);
      if (nationalId != null) {
        await prefs.setString('temp_reg_national_id', nationalId);
      }
      // Force save to disk
      await prefs.reload();
      print('💾 Temp data saved: $fullName');

      // B. Standardize Phone
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      // C. Send OTP
      return await sendVerificationCode(formattedPhone);
    } catch (e) {
      print('❌ Error in registerUser: $e');
      return {'success': false, 'message': 'خطا در شروع فرآیند ثبت‌نام'};
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) {
        return null;
      }

      final userId = prefs.getString(_userIdKey);
      final phoneNumber = prefs.getString(_phoneNumberKey);
      final fullName = prefs.getString(_fullNameKey);

      if (userId != null && phoneNumber != null && fullName != null) {
        return {
          'id': userId,
          'phone_number': phoneNumber,
          'full_name': fullName,
        };
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // 1. Clear Supabase Session (Critical)
      await _supabase.auth.signOut();

      // 2. Clear Local Preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('User signed out completely');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await getCurrentUser();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Get user profile by phone number
  Future<Map<String, dynamic>?> getUserProfileByPhone(
    String phoneNumber,
  ) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final result = await _supabase
          .from('profiles')
          .select('id, phone_number, full_name, is_verified')
          .eq('phone_number', formattedPhone)
          .maybeSingle(); // Changed single() to maybeSingle()

      if (result == null) return null;

      // Save session
      await _saveUserSession(
        result['id'],
        result['phone_number'],
        result['full_name'],
      );
      return result;
    } catch (e) {
      print('Error getting user profile by phone: $e');
      return null;
    }
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession(
    String userId,
    String phoneNumber,
    String fullName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_phoneNumberKey, phoneNumber);
      await prefs.setString(_fullNameKey, fullName);
      print('User session saved successfully');
    } catch (e) {
      print('Error saving user session: $e');
    }
  }
}
