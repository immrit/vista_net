import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/admin_constants.dart';

/// Admin Stats Model
class AdminStats {
  final int totalUsers;
  final int totalTickets;
  final int pendingTickets;
  final int totalServices;
  final int activeServices;

  const AdminStats({
    this.totalUsers = 0,
    this.totalTickets = 0,
    this.pendingTickets = 0,
    this.totalServices = 0,
    this.activeServices = 0,
  });

  AdminStats copyWith({
    int? totalUsers,
    int? totalTickets,
    int? pendingTickets,
    int? totalServices,
    int? activeServices,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalTickets: totalTickets ?? this.totalTickets,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      totalServices: totalServices ?? this.totalServices,
      activeServices: activeServices ?? this.activeServices,
    );
  }
}

/// Admin State Notifier
class AdminNotifier extends StateNotifier<AdminStats> {
  final SupabaseClient _supabase;

  AdminNotifier(this._supabase) : super(const AdminStats());

  Future<void> loadStats() async {
    try {
      // Use count method correctly for supabase_flutter
      final usersRes = await _supabase
          .from('profiles')
          .select('id')
          .count(CountOption.exact);
      final ticketsRes = await _supabase
          .from('tickets')
          .select('id')
          .count(CountOption.exact);
      final pendingRes = await _supabase
          .from('tickets')
          .select('id')
          .eq('status', 'open')
          .count(CountOption.exact);
      final servicesRes = await _supabase
          .from('services')
          .select('id')
          .count(CountOption.exact);
      final activeRes = await _supabase
          .from('services')
          .select('id')
          .eq('is_active', true)
          .count(CountOption.exact);

      state = AdminStats(
        totalUsers: usersRes.count,
        totalTickets: ticketsRes.count,
        pendingTickets: pendingRes.count,
        totalServices: servicesRes.count,
        activeServices: activeRes.count,
      );
    } catch (e) {
      debugPrint('Error loading admin stats: $e');
    }
  }
}

/// Provider to check if current user is admin
final isAdminProvider = Provider<bool>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  return AdminConstants.isAdmin(user?.id);
});

/// Admin Stats Provider
final adminStatsProvider = StateNotifierProvider<AdminNotifier, AdminStats>((
  ref,
) {
  return AdminNotifier(Supabase.instance.client);
});
