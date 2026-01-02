import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/session_model.dart';
import 'session_storage_service.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

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
    debugPrint(
      '[Auth] Sending Code - Original: $phoneNumber -> Formatted: $formattedPhone',
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
      debugPrint('[Auth] Error in sendVerificationCode: $e');

      // If JWT expired, clear stale session and retry
      if (e.toString().contains('JWT') || e.toString().contains('401')) {
        debugPrint('[Auth] 🔄 JWT expired, clearing session and retrying...');
        await _supabase.auth.signOut();
        await SessionStorageService.clearSession();

        // Retry after clearing session
        try {
          return await invokeFunction('OTP');
        } catch (retryError) {
          debugPrint('[Auth] Retry failed: $retryError');
        }
      }

      return {'success': false, 'message': 'خطا در ارسال کد تایید'};
    }
  }

  // Recover session on app start - UPDATED TO USE HIVE
  Future<Map<String, dynamic>?> recoverSession() async {
    try {
      // First try to get from Hive (offline-first)
      final storedSession = await SessionStorageService.getSession();
      if (storedSession != null && storedSession.isLoggedIn) {
        debugPrint('[Auth] 🔄 Found stored session: ${storedSession.userId}');

        // Validate with Supabase if online
        final user = _supabase.auth.currentUser;
        if (user != null) {
          // Try fetching fresh profile
          final profile = await _supabase
              .from('profiles')
              .select('id, phone_number, full_name, is_verified')
              .eq('id', user.id)
              .maybeSingle();

          if (profile != null) {
            // Update stored session with fresh data
            await _saveUserSession(
              profile['id'],
              profile['phone_number'],
              profile['full_name'] ?? '',
            );
            return profile;
          }
        }

        // Return stored session as fallback (offline mode)
        return {
          'id': storedSession.userId,
          'phone_number': storedSession.phoneNumber,
          'full_name': storedSession.fullName,
        };
      }

      // No stored session, check Supabase directly
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      debugPrint('[Auth] 🔄 Recovering session for user: ${user.id}');
      final profileById = await _supabase
          .from('profiles')
          .select('id, phone_number, full_name, is_verified')
          .eq('id', user.id)
          .maybeSingle();

      if (profileById != null) {
        await _saveUserSession(
          profileById['id'],
          profileById['phone_number'],
          profileById['full_name'] ?? '',
        );
        return profileById;
      }

      return await getUserProfileByPhone(
        user.userMetadata?['phone_number'] ??
            _formatPhoneNumber(user.phone ?? ''),
      );
    } catch (e) {
      debugPrint('[Auth] Error recovering session: $e');
      // Try offline session as last resort
      final storedSession = await SessionStorageService.getSession();
      if (storedSession != null && storedSession.isLoggedIn) {
        return {
          'id': storedSession.userId,
          'phone_number': storedSession.phoneNumber,
          'full_name': storedSession.fullName,
        };
      }
      return null;
    }
  }

  // Verify phone number with OTP
  Future<Map<String, dynamic>> verifyPhoneNumber(
    String phoneNumber,
    String code,
  ) async {
    final formattedPhone = _formatPhoneNumber(phoneNumber);
    debugPrint('[Auth] 🔐 Verifying OTP for: $formattedPhone');

    try {
      final response = await _supabase.functions.invoke(
        'verify-otp',
        body: {'phone': formattedPhone, 'code': code},
      );

      final data = response.data;

      if (data != null && data['success'] == true && data['session'] != null) {
        final session = data['session'];
        await _supabase.auth.setSession(session['refresh_token']);
        debugPrint('[Auth] ✅ Session set successfully');

        await _completeRegistrationProfileIfNeeded();

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
      debugPrint('[Auth] ❌ Error verifying OTP: $e');
      return {'success': false, 'message': 'خطا در تایید شماره موبایل'};
    }
  }

  // Helper to create/update profile
  Future<void> _completeRegistrationProfileIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingName = prefs.getString('temp_reg_fullname');
      final pendingNationalId = prefs.getString('temp_reg_national_id');

      if (pendingName != null) {
        final user = _supabase.auth.currentUser;
        if (user != null) {
          debugPrint('[Auth] 👤 Creating profile for user: ${user.id}');

          final phone =
              user.userMetadata?['phone_number'] ??
              _formatPhoneNumber(user.phone ?? '');

          await _supabase.from('profiles').upsert({
            'id': user.id,
            'full_name': pendingName,
            'national_id': pendingNationalId,
            'phone_number': phone,
            'is_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          });

          debugPrint('[Auth] ✨ Profile created successfully!');

          await prefs.remove('temp_reg_fullname');
          await prefs.remove('temp_reg_national_id');
        }
      }
    } catch (e) {
      debugPrint('[Auth] ❌ Failed to update profile: $e');
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
      debugPrint('[Auth] Error checking user existence: $e');
      return false;
    }
  }

  // Register user
  Future<Map<String, dynamic>> registerUser(
    String phoneNumber,
    String fullName, {
    String? nationalId,
    DateTime? birthDate,
  }) async {
    try {
      debugPrint('[Auth] 📝 Starting Registration Flow for $phoneNumber');

      // Save details temporarily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_reg_fullname', fullName);
      if (nationalId != null) {
        await prefs.setString('temp_reg_national_id', nationalId);
      }
      await prefs.reload();
      debugPrint('[Auth] 💾 Temp data saved: $fullName');

      final formattedPhone = _formatPhoneNumber(phoneNumber);
      return await sendVerificationCode(formattedPhone);
    } catch (e) {
      debugPrint('[Auth] ❌ Error in registerUser: $e');
      return {'success': false, 'message': 'خطا در شروع فرآیند ثبت‌نام'};
    }
  }

  // Get current user - UPDATED TO USE HIVE
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final session = await SessionStorageService.getSession();
      if (session == null || !session.isLoggedIn) {
        return null;
      }

      return {
        'id': session.userId,
        'phone_number': session.phoneNumber,
        'full_name': session.fullName,
      };
    } catch (e) {
      debugPrint('[Auth] Error getting current user: $e');
      return null;
    }
  }

  // Check if user is authenticated - UPDATED TO USE HIVE
  Future<bool> isAuthenticated() async {
    try {
      final session = await SessionStorageService.getSession();
      return session?.isLoggedIn ?? false;
    } catch (e) {
      debugPrint('[Auth] Error checking authentication: $e');
      return false;
    }
  }

  // Sign out - UPDATED TO CLEAR HIVE
  Future<void> signOut() async {
    try {
      // 1. Clear Supabase Session
      await _supabase.auth.signOut();

      // 2. Clear Hive Session
      await SessionStorageService.clearSession();

      // 3. Clear SharedPreferences (for temp data)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      debugPrint('[Auth] ✅ User signed out completely');
    } catch (e) {
      debugPrint('[Auth] Error signing out: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await getCurrentUser();
    } catch (e) {
      debugPrint('[Auth] Error getting user profile: $e');
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
          .maybeSingle();

      if (result == null) return null;

      await _saveUserSession(
        result['id'],
        result['phone_number'],
        result['full_name'],
      );
      return result;
    } catch (e) {
      debugPrint('[Auth] Error getting user profile by phone: $e');
      return null;
    }
  }

  // Save user session to Hive - UPDATED
  Future<void> _saveUserSession(
    String userId,
    String phoneNumber,
    String fullName,
  ) async {
    try {
      final session = UserSession(
        id: 'main_session',
        userId: userId,
        phoneNumber: phoneNumber,
        fullName: fullName,
        isLoggedIn: true,
        lastLoginAt: DateTime.now(),
      );

      await SessionStorageService.saveSession(session);
      debugPrint('[Auth] ✅ Session saved to Hive');
    } catch (e) {
      debugPrint('[Auth] Error saving user session: $e');
    }
  }
}
