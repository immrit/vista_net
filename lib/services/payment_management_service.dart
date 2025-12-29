import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all payments for admin
  Future<List<Map<String, dynamic>>> getAllPayments({
    int? limit,
    int? offset,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('service_payments').select('''
            *,
            user:auth.users(id, email, phone),
            service:services(id, title, description)
          ''');

      if (status != null) {
        query = query.eq('payment_status', status) as dynamic;
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String()) as dynamic;
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String()) as dynamic;
      }

      query = query.order('created_at', ascending: false) as dynamic;

      if (limit != null) {
        query = query.limit(limit) as dynamic;
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1) as dynamic;
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting payments: $e');
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_payment_statistics',
        params: {
          'p_start_date':
              startDate?.toIso8601String().split('T')[0] ??
              DateTime.now()
                  .subtract(const Duration(days: 30))
                  .toIso8601String()
                  .split('T')[0],
          'p_end_date':
              endDate?.toIso8601String().split('T')[0] ??
              DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response is List && response.isNotEmpty) {
        return response.first;
      }

      return {};
    } catch (e) {
      throw Exception('Error getting payment statistics: $e');
    }
  }

  /// Get service payment statistics
  Future<List<Map<String, dynamic>>> getServicePaymentStats() async {
    try {
      final response = await _supabase
          .from('service_payment_stats')
          .select('*')
          .order('total_revenue', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting service payment stats: $e');
    }
  }

  /// Get user payment summary
  Future<Map<String, dynamic>?> getUserPaymentSummary(String userId) async {
    try {
      final response = await _supabase
          .from('user_payment_summary')
          .select('*')
          .eq('user_id', userId)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      return null;
    }
  }

  /// Refund a payment
  Future<bool> refundPayment(String paymentId, String reason) async {
    try {
      await _supabase
          .from('service_payments')
          .update({
            'payment_status': 'refunded',
            'notes': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      // Create refund transaction
      await _supabase.from('payment_transactions').insert({
        'service_payment_id': paymentId,
        'transaction_id': 'refund_${DateTime.now().millisecondsSinceEpoch}',
        'transaction_type': 'refund',
        'amount': 0, // Will be updated with actual amount
        'status': 'completed',
        'gateway_response': {
          'refund_reason': reason,
          'refunded_at': DateTime.now().toIso8601String(),
        },
        'processed_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Error refunding payment: $e');
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _supabase
          .from('service_payments')
          .update({
            'payment_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      return true;
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }

  /// Generate daily payment report
  Future<void> generateDailyReport(DateTime date) async {
    try {
      await _supabase.rpc(
        'generate_daily_payment_report',
        params: {'report_date': date.toIso8601String().split('T')[0]},
      );
    } catch (e) {
      throw Exception('Error generating daily report: $e');
    }
  }

  /// Get payment reports
  Future<List<Map<String, dynamic>>> getPaymentReports({
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('payment_reports').select('*');

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (startDate != null) {
        query = query.gte(
          'report_date',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'report_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      query = query.order('report_date', ascending: false) as dynamic;

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting payment reports: $e');
    }
  }

  /// Create payment product
  Future<bool> createPaymentProduct({
    required String serviceId,
    required String productId,
    required String productName,
    required String productDescription,
    required double price,
    String currency = 'IRR',
    String productType = 'inapp',
  }) async {
    try {
      await _supabase.from('payment_products').insert({
        'service_id': serviceId,
        'product_id': productId,
        'product_name': productName,
        'product_description': productDescription,
        'price': price,
        'currency': currency,
        'product_type': productType,
        'is_active': true,
      });

      return true;
    } catch (e) {
      throw Exception('Error creating payment product: $e');
    }
  }

  /// Update payment product
  Future<bool> updatePaymentProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _supabase
          .from('payment_products')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('product_id', productId);

      return true;
    } catch (e) {
      throw Exception('Error updating payment product: $e');
    }
  }

  /// Get payment products
  Future<List<Map<String, dynamic>>> getPaymentProducts({
    String? serviceId,
    bool? isActive,
  }) async {
    try {
      var query = _supabase.from('payment_products').select('*');

      if (serviceId != null) {
        query = query.eq('service_id', serviceId);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      query = query.order('created_at', ascending: false) as dynamic;

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting payment products: $e');
    }
  }

  /// Cleanup expired payments
  Future<int> cleanupExpiredPayments() async {
    try {
      final response = await _supabase.rpc('cleanup_expired_payments');
      return response as int;
    } catch (e) {
      throw Exception('Error cleaning up expired payments: $e');
    }
  }

  /// Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    try {
      final response = await _supabase
          .from('service_payments')
          .select('''
            *,
            user:auth.users(id, email, phone),
            service:services(id, title, description),
            transactions:payment_transactions(*)
          ''')
          .eq('id', paymentId)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      return null;
    }
  }

  /// Get payments by user
  Future<List<Map<String, dynamic>>> getPaymentsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('service_payments')
          .select('''
            *,
            service:services(id, title, description),
            transactions:payment_transactions(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting user payments: $e');
    }
  }

  /// Get payments by service
  Future<List<Map<String, dynamic>>> getPaymentsByService(
    String serviceId,
  ) async {
    try {
      final response = await _supabase
          .from('service_payments')
          .select('''
            *,
            user:auth.users(id, email, phone),
            transactions:payment_transactions(*)
          ''')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error getting service payments: $e');
    }
  }
}
