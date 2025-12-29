import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/auth_service.dart';

// ============================================================
// Auth State Model
// ============================================================

enum AuthStatus {
  initial, // هنوز چک نشده
  unauthenticated, // لاگین نشده
  authenticated, // لاگین شده
  needsRegistration, // کاربر پیدا نشد - ثبت‌نام لازم است
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? phoneNumber;
  final String? fullName;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.phoneNumber,
    this.fullName,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? phoneNumber,
    String? fullName,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================
// Auth Notifier (StateNotifier)
// ============================================================

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  // Check if user is already logged in (Auto-login on app start)
  Future<void> _checkAuthStatus() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          userId: user['id'],
          phoneNumber: user['phone_number'],
          fullName: user['full_name'],
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.sendVerificationCode(phoneNumber);

      if (result['success'] == true) {
        state = state.copyWith(isLoading: false, phoneNumber: phoneNumber);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'خطا در ارسال کد',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطا در ارسال کد: $e');
      return false;
    }
  }

  // Verify OTP code
  // Returns: 'success' | 'user_not_found' | 'error'
  Future<String> verifyOtp(String phoneNumber, String code) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.verifyPhoneNumber(phoneNumber, code);

      if (result['success'] == true) {
        // Verification successful - check if user exists
        final userProfile = await _authService.getUserProfileByPhone(
          phoneNumber,
        );

        if (userProfile != null) {
          // User exists - log them in
          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
            userId: userProfile['id'],
            phoneNumber: userProfile['phone_number'],
            fullName: userProfile['full_name'],
          );
          return 'success';
        } else {
          // User doesn't exist - needs registration
          state = state.copyWith(
            status: AuthStatus.needsRegistration,
            isLoading: false,
            phoneNumber: phoneNumber,
          );
          return 'user_not_found';
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'کد تایید نامعتبر است',
        );
        return 'error';
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطا در تایید کد: $e');
      return 'error';
    }
  }

  // Register new user
  Future<bool> register({
    required String fullName,
    String? nationalId,
    DateTime? birthDate,
  }) async {
    if (state.phoneNumber == null) {
      state = state.copyWith(error: 'شماره موبایل موجود نیست');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.registerUser(
        state.phoneNumber!,
        fullName,
        nationalId: nationalId,
        birthDate: birthDate,
      );

      if (result['success'] == true) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          userId: result['user_id'],
          fullName: fullName,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'خطا در ثبت‌نام',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطا در ثبت‌نام: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================
// Providers
// ============================================================

// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Main Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// Convenience Providers
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

// ============================================================
// Backward Compatibility Providers
// (Required by: ticket_chat_provider, profile_screen, hamburger_menu)
// ============================================================

// Supabase Client Provider (for chat and other features)
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Current User Provider (returns a Map for compatibility)
final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.isLoggedIn && authState.userId != null) {
    return {
      'id': authState.userId,
      'phone_number': authState.phoneNumber,
      'full_name': authState.fullName,
    };
  }
  return null;
});

// Alias for old code using authControllerProvider
// This wraps authProvider.notifier for backward compatibility
final authControllerProvider = Provider<AuthNotifier>((ref) {
  return ref.read(authProvider.notifier);
});
