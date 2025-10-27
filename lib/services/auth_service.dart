import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // Session management keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _fullNameKey = 'full_name';

  // Send verification code to phone number using Edge Function
  Future<Map<String, dynamic>> sendVerificationCode(String phoneNumber) async {
    Future<Map<String, dynamic>> invokeFunction(String name) async {
      final response = await _supabase.functions.invoke(
        name,
        body: {'phone_number': phoneNumber},
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
      // Use the deployed function name
      return await invokeFunction('OTP');
    } catch (e) {
      return {'success': false, 'message': 'خطا در ارسال کد تایید'};
    }
  }

  // Verify phone number with code
  Future<Map<String, dynamic>> verifyPhoneNumber(
    String phoneNumber,
    String code,
  ) async {
    // Debug: Check what's in the database first
    await debugOtpRecords(phoneNumber);
    await testDirectDatabaseCheck(phoneNumber, code);
    Future<bool?> tryVerify(String fn, Map<String, dynamic> params) async {
      try {
        print('=== OTP VERIFICATION DEBUG ===');
        print('Function: $fn');
        print('Parameters: $params');
        print('Phone: $phoneNumber');
        print('Code: $code');

        final result = await _supabase.rpc(fn, params: params);
        print('RPC Result: $result');
        print('=============================');

        return result == true;
      } catch (error) {
        print('verifyPhoneNumber RPC $fn failed: $error');
        return null;
      }
    }

    try {
      final attempts = [
        (
          'verify_otp_code',
          {'p_phone_number': phoneNumber, 'p_input_code': code},
        ),
      ];

      for (final attempt in attempts) {
        final fnName = attempt.$1;
        final params = attempt.$2;
        final result = await tryVerify(fnName, params);
        if (result == true) {
          return {'success': true, 'message': 'شماره موبایل تایید شد'};
        }
      }

      return {'success': false, 'message': 'کد تایید نامعتبر یا منقضی شده است'};
    } catch (e) {
      print('Error in verifyPhoneNumber: $e');
      return {'success': false, 'message': 'خطا در تایید شماره موبایل'};
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      final result = await _supabase
          .from('profiles')
          .select('id')
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Register user with phone number and additional info
  Future<Map<String, dynamic>> registerUser(
    String phoneNumber,
    String fullName, {
    String? nationalId,
    DateTime? birthDate,
  }) async {
    try {
      // Check if user already exists
      try {
        final existingUser = await _supabase
            .from('profiles')
            .select('id, is_verified')
            .eq('phone_number', phoneNumber)
            .single();

        if (existingUser['is_verified'] == true) {
          return {
            'success': false,
            'message': 'این شماره موبایل قبلاً ثبت شده است',
          };
        } else {
          return {
            'success': false,
            'message': 'این شماره موبایل در انتظار تایید است',
          };
        }
      } catch (e) {
        // User doesn't exist, continue with registration
      }

      // Create user profile using RPC function
      // This bypasses RLS policies by using SECURITY DEFINER
      try {
        print('Registering user with RPC function');
        print('Phone: $phoneNumber, Name: $fullName');

        // Prepare parameters
        final params = {'p_phone_number': phoneNumber, 'p_full_name': fullName};

        if (nationalId != null) {
          params['p_national_id'] = nationalId;
        }

        if (birthDate != null) {
          params['p_birth_date'] = birthDate.toIso8601String();
        }

        // Use RPC function to register user
        final response = await _supabase.rpc('register_user', params: params);

        print('Register user response: $response');

        if (response['success'] == true) {
          // Save user session
          await _saveUserSession(response['user_id'], phoneNumber, fullName);

          return {
            'success': true,
            'message': response['message'] ?? 'کاربر با موفقیت ثبت شد',
            'user_id': response['user_id'],
          };
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'خطا در ثبت کاربر',
          };
        }
      } catch (e) {
        print('Error registering user: $e');
        return {'success': false, 'message': 'خطا در ثبت کاربر: $e'};
      }
    } catch (e) {
      print('Error in registerUser: $e');
      return {'success': false, 'message': 'خطا در ثبت نام'};
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('User signed out');
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
      final result = await _supabase
          .from('profiles')
          .select('id, phone_number, full_name, is_verified')
          .eq('phone_number', phoneNumber)
          .single();

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

  // Debug function to check OTP records in database
  Future<void> debugOtpRecords(String phoneNumber) async {
    try {
      print('=== DEBUGGING OTP RECORDS ===');
      print('Phone Number: $phoneNumber');
      print('Current Time: ${DateTime.now().toIso8601String()}');

      // Check otp_requests table
      final otpRecords = await _supabase
          .from('otp_requests')
          .select('*')
          .eq('phone_number', phoneNumber)
          .order('created_at', ascending: false)
          .limit(5);

      print('OTP Records in database:');
      for (var record in otpRecords) {
        final expiresAt = DateTime.parse(record['expires_at']);
        final isExpired = expiresAt.isBefore(DateTime.now());
        print(
          'ID: ${record['id']}, Code: ${record['code']}, Expires: ${record['expires_at']}, Used: ${record['is_used']}, Verified: ${record['verified_at']}, IsExpired: $isExpired',
        );
      }

      // Check profiles table
      final profileRecords = await _supabase
          .from('profiles')
          .select('*')
          .eq('phone_number', phoneNumber);

      print('Profile Records:');
      for (var record in profileRecords) {
        print(
          'ID: ${record['id']}, Verified: ${record['is_verified']}, Code: ${record['verification_code']}, Expires: ${record['verification_expires_at']}',
        );
      }

      print('============================');
    } catch (e) {
      print('Error debugging OTP records: $e');
    }
  }

  // Test function to directly check database
  Future<void> testDirectDatabaseCheck(String phoneNumber, String code) async {
    try {
      print('=== DIRECT DATABASE TEST ===');
      print('Phone: $phoneNumber, Code: $code');

      // Direct query to check what's in database
      final result = await _supabase
          .from('otp_requests')
          .select('*')
          .eq('phone_number', phoneNumber)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      print('Latest OTP Record:');
      print('Code in DB: ${result['code']}');
      print('Code entered: $code');
      print('Match: ${result['code'] == code}');
      print('Expires: ${result['expires_at']}');
      print('Used: ${result['is_used']}');

      final expiresAt = DateTime.parse(result['expires_at']);
      final isExpired = expiresAt.isBefore(DateTime.now());
      print('Is Expired: $isExpired');

      print('============================');
    } catch (e) {
      print('Error in direct database test: $e');
    }
  }
}
