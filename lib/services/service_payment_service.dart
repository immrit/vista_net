import 'dart:async';
import 'package:flutter/foundation.dart';
import '../mock/cafebazaar_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';

class ServicePaymentService {
  static final ServicePaymentService _instance =
      ServicePaymentService._internal();
  factory ServicePaymentService() => _instance;
  ServicePaymentService._internal();

  static const String _publicKey =
      'YOUR_PUBLIC_KEY_HERE'; // Replace with your actual public key
  static const String _servicePaymentsKey = 'service_payments';

  // Stream controllers for payment events
  final StreamController<ServicePaymentResponse> _paymentController =
      StreamController<ServicePaymentResponse>.broadcast();

  Stream<ServicePaymentResponse> get paymentStream => _paymentController.stream;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cafe Bazaar instance
  late CafebazaarFlutter _bazaar;
  late InAppPurchase _inAppPurchase;

  // List of paid services (for local cache)
  List<String> _paidServices = [];
  List<String> get paidServices => List.unmodifiable(_paidServices);

  /// Initialize service payment
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Initialize Cafe Bazaar billing
      _bazaar = CafebazaarFlutter.instance;
      _inAppPurchase = _bazaar.inAppPurchase(_publicKey);

      _isInitialized = true;
      await _loadPaidServices();
      await _syncWithDatabase(); // Sync with Supabase

      _paymentController.add(
        ServicePaymentResponse.success(
          'Service payment initialized successfully',
        ),
      );
      return true;
    } catch (e) {
      _paymentController.add(
        ServicePaymentResponse.error(
          'Service payment initialization error: $e',
        ),
      );
      return false;
    }
  }

  /// Check if service payment is available
  Future<bool> isPaymentAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Pay for a service
  Future<ServicePaymentResponse> payForService(Service service) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (!initResult) {
          return ServicePaymentResponse.error('Payment not initialized');
        }
      }

      // Check if service is already paid
      if (_paidServices.contains(service.id)) {
        return ServicePaymentResponse.error('Service already paid');
      }

      // Create payment record in Supabase
      final paymentId = await _createPaymentRecord(service);
      if (paymentId == null) {
        return ServicePaymentResponse.error('Failed to create payment record');
      }

      // Generate unique product ID for this service
      final productId =
          'service_${service.id}_${DateTime.now().millisecondsSinceEpoch}';
      final payload = 'service_payment_${service.id}_$paymentId';

      final purchaseInfo = await _inAppPurchase.purchase(
        productId,
        payLoad: payload,
      );

      if (purchaseInfo != null) {
        // Confirm payment in Supabase
        await _confirmPayment(paymentId, productId, purchaseInfo.toString());

        // Update local cache
        await _addPaidService(service.id);

        _paymentController.add(
          ServicePaymentResponse.success('Service payment successful'),
        );
        return ServicePaymentResponse.success(
          'Service payment completed successfully',
        );
      } else {
        // Mark payment as failed in Supabase
        await _markPaymentFailed(paymentId);

        _paymentController.add(
          ServicePaymentResponse.error('Service payment failed'),
        );
        return ServicePaymentResponse.error('Service payment failed');
      }
    } catch (e) {
      _paymentController.add(
        ServicePaymentResponse.error('Service payment error: $e'),
      );
      return ServicePaymentResponse.error('Service payment error: $e');
    }
  }

  /// Create payment record in Supabase
  Future<String?> _createPaymentRecord(Service service) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.rpc(
        'create_service_payment',
        params: {
          'p_user_id': user.id,
          'p_service_id': service.id, // service.id باید UUID باشد
          'p_service_title': service.title,
          'p_amount': service.costAmount,
          'p_currency': 'IRR',
          'p_product_id': 'service_${service.id}_payment',
          'p_metadata': {
            'service_description': service.description,
            'processing_time_days': service.processingTimeDays,
            'created_at': DateTime.now().toIso8601String(),
          },
        },
      );

      return response.toString();
    } catch (e) {
      debugPrint('Error creating payment record: $e');
      return null;
    }
  }

  /// Confirm payment in Supabase
  Future<void> _confirmPayment(
    String paymentId,
    String transactionId,
    String purchaseToken,
  ) async {
    try {
      await _supabase.rpc(
        'confirm_service_payment',
        params: {
          'p_payment_id': paymentId,
          'p_transaction_id': transactionId,
          'p_purchase_token': purchaseToken,
          'p_gateway_response': {
            'gateway': 'cafe_bazaar',
            'confirmed_at': DateTime.now().toIso8601String(),
          },
        },
      );
    } catch (e) {
      debugPrint('Error confirming payment: $e');
    }
  }

  /// Mark payment as failed in Supabase
  Future<void> _markPaymentFailed(String paymentId) async {
    try {
      await _supabase
          .from('service_payments')
          .update({
            'payment_status': 'failed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
    } catch (e) {
      debugPrint('Error marking payment as failed: $e');
    }
  }

  /// Check if a service is paid (from Supabase)
  Future<bool> isServicePaidFromDatabase(String serviceId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase.rpc(
        'check_service_payment_status',
        params: {'p_user_id': user.id, 'p_service_id': serviceId},
      );

      if (response is List && response.isNotEmpty) {
        final paymentData = response.first as Map<String, dynamic>;
        return paymentData['is_paid'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking payment status from database: $e');
      return false;
    }
  }

  /// Check if a service is paid (from local cache)
  bool isServicePaid(String serviceId) {
    return _paidServices.contains(serviceId);
  }

  /// Get payment status for a service
  ServicePaymentStatus getServicePaymentStatus(String serviceId) {
    if (_paidServices.contains(serviceId)) {
      return ServicePaymentStatus.paid;
    }
    return ServicePaymentStatus.unpaid;
  }

  /// Get user's payment history
  Future<List<ServicePaymentInfo>> getUserPaymentHistory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('service_payments')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) =>
                ServicePaymentInfo.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  /// Sync local cache with database
  Future<void> _syncWithDatabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Get all paid services from database
      final response = await _supabase
          .from('service_payments')
          .select('service_id')
          .eq('user_id', user.id)
          .eq('payment_status', 'completed');

      final paidServicesFromDb = (response as List)
          .map((json) => json['service_id'] as String)
          .toList();

      // Update local cache
      _paidServices = paidServicesFromDb;
      await _savePaidServices();
    } catch (e) {
      debugPrint('Error syncing with database: $e');
    }
  }

  /// Add paid service to local storage
  Future<void> _addPaidService(String serviceId) async {
    if (!_paidServices.contains(serviceId)) {
      _paidServices.add(serviceId);
      await _savePaidServices();
    }
  }

  /// Remove paid service from local storage (for admin/testing purposes)
  Future<void> removePaidService(String serviceId) async {
    _paidServices.remove(serviceId);
    await _savePaidServices();
  }

  /// Save paid services to SharedPreferences
  Future<void> _savePaidServices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_servicePaymentsKey, _paidServices);
  }

  /// Load paid services from SharedPreferences
  Future<void> _loadPaidServices() async {
    final prefs = await SharedPreferences.getInstance();
    _paidServices = prefs.getStringList(_servicePaymentsKey) ?? [];
  }

  /// Clear all paid services (for testing)
  Future<void> clearPaidServices() async {
    _paidServices.clear();
    await _savePaidServices();
  }

  /// Disconnect from payment service
  Future<void> disconnect() async {
    try {
      if (_isInitialized) {
        await _inAppPurchase.disconnect();
      }
    } catch (e) {
      debugPrint('Error disconnecting payment service: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _paymentController.close();
  }
}

/// Service payment response model
class ServicePaymentResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;

  ServicePaymentResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory ServicePaymentResponse.success(String message, {dynamic data}) {
    return ServicePaymentResponse(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory ServicePaymentResponse.error(String message) {
    return ServicePaymentResponse(isSuccess: false, message: message);
  }
}

/// Service payment status enum
enum ServicePaymentStatus { paid, unpaid, pending }

/// Service payment info model
class ServicePaymentInfo {
  final String serviceId;
  final String serviceTitle;
  final double amount;
  final ServicePaymentStatus status;
  final DateTime? paymentDate;
  final String? transactionId;

  ServicePaymentInfo({
    required this.serviceId,
    required this.serviceTitle,
    required this.amount,
    required this.status,
    this.paymentDate,
    this.transactionId,
  });

  factory ServicePaymentInfo.fromJson(Map<String, dynamic> json) {
    return ServicePaymentInfo(
      serviceId: json['service_id'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: ServicePaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => ServicePaymentStatus.unpaid,
      ),
      paymentDate: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'])
          : null,
      transactionId: json['cafe_bazaar_transaction_id'],
    );
  }

  factory ServicePaymentInfo.fromService(
    Service service,
    ServicePaymentStatus status,
  ) {
    return ServicePaymentInfo(
      serviceId: service.id,
      serviceTitle: service.title,
      amount: service.costAmount,
      status: status,
    );
  }
}
