import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/admin_constants.dart';

/// Tracks whether the user is viewing in admin mode or client mode
/// Only admin users can toggle this
final adminModeProvider = StateNotifierProvider<AdminModeNotifier, bool>((ref) {
  return AdminModeNotifier();
});

class AdminModeNotifier extends StateNotifier<bool> {
  AdminModeNotifier() : super(_shouldStartInAdminMode());

  /// Check if current user is admin and should start in admin mode
  static bool _shouldStartInAdminMode() {
    final user = Supabase.instance.client.auth.currentUser;
    return AdminConstants.isAdmin(user?.id);
  }

  /// Check if current user is admin
  bool get isAdmin {
    final user = Supabase.instance.client.auth.currentUser;
    return AdminConstants.isAdmin(user?.id);
  }

  /// Toggle between admin and client mode
  void toggleMode() {
    if (isAdmin) {
      state = !state;
    }
  }

  /// Switch to admin mode (only if admin)
  void switchToAdmin() {
    if (isAdmin) {
      state = true;
    }
  }

  /// Switch to client mode
  void switchToClient() {
    state = false;
  }
}
