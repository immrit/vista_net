import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mock/cafebazaar_flutter.dart';

class BillingService {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  static const String _billingKey = 'billing_purchases';
  static const String _developerPayload = 'developer_payload';
  static const String _publicKey =
      'YOUR_PUBLIC_KEY_HERE'; // Replace with your actual public key

  // Stream controllers for billing events
  final StreamController<BillingResponse> _billingController =
      StreamController<BillingResponse>.broadcast();

  Stream<BillingResponse> get billingStream => _billingController.stream;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Cafe Bazaar instance
  late CafebazaarFlutter _bazaar;
  late InAppPurchase _inAppPurchase;

  // List of purchased items
  List<String> _purchasedItems = [];
  List<String> get purchasedItems => List.unmodifiable(_purchasedItems);

  /// Initialize Cafe Bazaar billing
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Initialize Cafe Bazaar billing
      _bazaar = CafebazaarFlutter.instance;
      _inAppPurchase = _bazaar.inAppPurchase(_publicKey);

      _isInitialized = true;
      await _loadPurchasedItems();
      _billingController.add(
        BillingResponse.success('Billing initialized successfully'),
      );
      return true;
    } catch (e) {
      _billingController.add(
        BillingResponse.error('Billing initialization error: $e'),
      );
      return false;
    }
  }

  /// Check if billing is available
  Future<bool> isBillingAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Cafe Bazaar billing is always available if initialized
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Purchase a product
  Future<BillingResponse> purchaseProduct(
    String productId, {
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (!initResult) {
          return BillingResponse.error('Billing not initialized');
        }
      }

      // Check if already purchased
      if (_purchasedItems.contains(productId)) {
        return BillingResponse.error('Product already purchased');
      }

      final purchasePayload = payload ?? _developerPayload;
      final purchaseInfo = await _inAppPurchase.purchase(
        productId,
        payLoad: purchasePayload,
      );

      if (purchaseInfo != null) {
        await _addPurchasedItem(productId);
        _billingController.add(BillingResponse.success('Purchase successful'));
        return BillingResponse.success('Purchase completed successfully');
      } else {
        _billingController.add(BillingResponse.error('Purchase failed'));
        return BillingResponse.error('Purchase failed');
      }
    } catch (e) {
      _billingController.add(BillingResponse.error('Purchase error: $e'));
      return BillingResponse.error('Purchase error: $e');
    }
  }

  /// Consume a purchased product (for consumable items)
  Future<BillingResponse> consumeProduct(String productId) async {
    try {
      if (!_isInitialized) {
        return BillingResponse.error('Billing not initialized');
      }

      await _inAppPurchase.consume(productId);
      await _removePurchasedItem(productId);
      _billingController.add(
        BillingResponse.success('Product consumed successfully'),
      );
      return BillingResponse.success('Product consumed successfully');
    } catch (e) {
      _billingController.add(BillingResponse.error('Consume error: $e'));
      return BillingResponse.error('Consume error: $e');
    }
  }

  /// Get product details
  Future<BillingResponse> getProductDetails(String productId) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (!initResult) {
          return BillingResponse.error('Billing not initialized');
        }
      }

      // Since cafebazaar_flutter doesn't have getProductDetails,
      // we'll return a mock response with basic product info
      final productData = {
        'productId': productId,
        'title': 'Product $productId',
        'description': 'Description for $productId',
        'price': '0',
        'currency': 'IRR',
        'type': 'inapp',
      };

      return BillingResponse.success(
        'Product details retrieved',
        data: productData,
      );
    } catch (e) {
      return BillingResponse.error('Get product details error: $e');
    }
  }

  /// Get multiple product details
  Future<BillingResponse> getMultipleProductDetails(
    List<String> productIds,
  ) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (!initResult) {
          return BillingResponse.error('Billing not initialized');
        }
      }

      // Since cafebazaar_flutter doesn't have getMultipleProductDetails,
      // we'll return mock responses for all products
      final List<Map<String, dynamic>> productsData = productIds
          .map(
            (productId) => {
              'productId': productId,
              'title': 'Product $productId',
              'description': 'Description for $productId',
              'price': '0',
              'currency': 'IRR',
              'type': 'inapp',
            },
          )
          .toList();

      return BillingResponse.success(
        'Product details retrieved',
        data: productsData,
      );
    } catch (e) {
      return BillingResponse.error('Get product details error: $e');
    }
  }

  /// Check if a product is purchased
  bool isProductPurchased(String productId) {
    return _purchasedItems.contains(productId);
  }

  /// Restore purchases
  Future<BillingResponse> restorePurchases() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (!initResult) {
          return BillingResponse.error('Billing not initialized');
        }
      }

      // Since cafebazaar_flutter doesn't have restorePurchases,
      // we'll just reload the local purchases
      await _loadPurchasedItems();
      _billingController.add(
        BillingResponse.success('Purchases restored successfully'),
      );
      return BillingResponse.success('Purchases restored successfully');
    } catch (e) {
      _billingController.add(BillingResponse.error('Restore error: $e'));
      return BillingResponse.error('Restore error: $e');
    }
  }

  /// Add purchased item to local storage
  Future<void> _addPurchasedItem(String productId) async {
    if (!_purchasedItems.contains(productId)) {
      _purchasedItems.add(productId);
      await _savePurchasedItems();
    }
  }

  /// Remove purchased item from local storage
  Future<void> _removePurchasedItem(String productId) async {
    _purchasedItems.remove(productId);
    await _savePurchasedItems();
  }

  /// Save purchased items to SharedPreferences
  Future<void> _savePurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_billingKey, _purchasedItems);
  }

  /// Load purchased items from SharedPreferences
  Future<void> _loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    _purchasedItems = prefs.getStringList(_billingKey) ?? [];
  }

  /// Clear all purchased items (for testing)
  Future<void> clearPurchasedItems() async {
    _purchasedItems.clear();
    await _savePurchasedItems();
  }

  /// Disconnect from billing service
  Future<void> disconnect() async {
    try {
      if (_isInitialized) {
        await _inAppPurchase.disconnect();
      }
    } catch (e) {
      debugPrint('Error disconnecting billing service: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _billingController.close();
  }
}

/// Billing response model
class BillingResponse {
  final bool isSuccess;
  final String message;
  final dynamic data;

  BillingResponse({required this.isSuccess, required this.message, this.data});

  factory BillingResponse.success(String message, {dynamic data}) {
    return BillingResponse(isSuccess: true, message: message, data: data);
  }

  factory BillingResponse.error(String message) {
    return BillingResponse(isSuccess: false, message: message);
  }
}

/// Product model
class Product {
  final String productId;
  final String title;
  final String description;
  final String price;
  final String currency;
  final String type; // 'inapp' or 'subs'

  Product({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      currency: json['currency'] ?? '',
      type: json['type'] ?? 'inapp',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type,
    };
  }
}
