// Mock implementation of cafebazaar_flutter package
// This is a temporary solution until the namespace issue is resolved

import 'dart:async';

/// Mock CafebazaarFlutter class
class CafebazaarFlutter {
  static final CafebazaarFlutter _instance = CafebazaarFlutter._internal();
  factory CafebazaarFlutter() => _instance;
  CafebazaarFlutter._internal();

  static CafebazaarFlutter get instance => _instance;

  /// Mock InAppPurchase instance
  InAppPurchase inAppPurchase(String publicKey) {
    return InAppPurchase._(publicKey);
  }
}

/// Mock InAppPurchase class
class InAppPurchase {
  final String _publicKey;

  InAppPurchase._(this._publicKey);

  /// Get public key for debugging
  String get publicKey => _publicKey;

  /// Mock purchase method
  Future<dynamic> purchase(String productId, {String? payLoad}) async {
    // Simulate purchase process
    await Future.delayed(const Duration(seconds: 2));
    
    // Return mock purchase info
    return {
      'productId': productId,
      'purchaseToken': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'orderId': 'mock_order_${DateTime.now().millisecondsSinceEpoch}',
      'purchaseTime': DateTime.now().millisecondsSinceEpoch,
      'developerPayload': payLoad,
    };
  }

  /// Mock consume method
  Future<bool> consume(String purchaseToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  /// Mock disconnect method
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Mock getPurchases method
  Future<List<dynamic>> getPurchases() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  /// Mock getSkuDetails method
  Future<List<dynamic>> getSkuDetails(List<String> productIds) async {
    await Future.delayed(const Duration(seconds: 1));
    return productIds.map((id) => {
      'productId': id,
      'type': 'inapp',
      'price': '1000',
      'price_amount_micros': 1000000,
      'price_currency_code': 'IRR',
      'title': 'Mock Product $id',
      'description': 'Mock description for $id',
    }).toList();
  }
}

/// Mock PurchaseInfo class
class PurchaseInfo {
  final String productId;
  final String purchaseToken;
  final String orderId;
  final int purchaseTime;
  final String? developerPayload;

  PurchaseInfo({
    required this.productId,
    required this.purchaseToken,
    required this.orderId,
    required this.purchaseTime,
    this.developerPayload,
  });

  @override
  String toString() {
    return 'PurchaseInfo{productId: $productId, purchaseToken: $purchaseToken, orderId: $orderId, purchaseTime: $purchaseTime, developerPayload: $developerPayload}';
  }
}

/// Mock SkuDetails class
class SkuDetails {
  final String productId;
  final String type;
  final String price;
  final int priceAmountMicros;
  final String priceCurrencyCode;
  final String title;
  final String description;

  SkuDetails({
    required this.productId,
    required this.type,
    required this.price,
    required this.priceAmountMicros,
    required this.priceCurrencyCode,
    required this.title,
    required this.description,
  });
}
