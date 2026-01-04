import 'package:supabase_flutter/supabase_flutter.dart';

class WalletRepository {
  final SupabaseClient _supabase;

  WalletRepository(this._supabase);

  // دریافت موجودی کیف پول کاربر از جدول profiles
  Future<double> getBalance(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('balance')
          .eq('id', userId)
          .maybeSingle();

      if (response == null || response['balance'] == null) {
        return 0.0;
      }

      return (response['balance'] as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  // فراخوانی تابع RPC برای افزایش/کاهش موجودی
  Future<void> addBalance({
    required String targetUserId,
    required double amount,
    required String description,
    String type = 'deposit',
  }) async {
    await _supabase.rpc(
      'add_balance',
      params: {
        'target_user_id': targetUserId,
        'amount': amount,
        'description': description,
        'transaction_type': type,
      },
    );
  }

  // دریافت تراکنش‌های کاربر
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
