class BillingConfig {
  // Cafe Bazaar Configuration
  static const String packageName =
      'com.yourcompany.vista_net'; // Replace with your actual package name

  // Product IDs - Replace with your actual product IDs from Cafe Bazaar Developer Console
  static const Map<String, String> products = {
    'premium_upgrade': 'premium_upgrade',
    'remove_ads': 'remove_ads',
    'unlock_features': 'unlock_features',
    'monthly_subscription': 'monthly_subscription',
    'yearly_subscription': 'yearly_subscription',
  };

  // Subscription Product IDs
  static const List<String> subscriptionProducts = [
    'monthly_subscription',
    'yearly_subscription',
  ];

  // One-time Purchase Product IDs
  static const List<String> oneTimeProducts = [
    'premium_upgrade',
    'remove_ads',
    'unlock_features',
  ];

  // Product Details (for display purposes)
  static const Map<String, Map<String, String>> productDetails = {
    'premium_upgrade': {
      'title': 'ارتقاء به نسخه پریمیوم',
      'description': 'دسترسی به تمام ویژگی‌های پیشرفته',
      'price': 'تومان 50,000',
    },
    'remove_ads': {
      'title': 'حذف تبلیغات',
      'description': 'تجربه بدون تبلیغات',
      'price': 'تومان 25,000',
    },
    'unlock_features': {
      'title': 'باز کردن ویژگی‌های قفل شده',
      'description': 'دسترسی به ویژگی‌های اضافی',
      'price': 'تومان 30,000',
    },
    'monthly_subscription': {
      'title': 'اشتراک ماهانه',
      'description': 'دسترسی کامل به تمام ویژگی‌ها',
      'price': 'تومان 15,000',
    },
    'yearly_subscription': {
      'title': 'اشتراک سالانه',
      'description': 'دسترسی کامل به تمام ویژگی‌ها با تخفیف ویژه',
      'price': 'تومان 150,000',
    },
  };

  // Billing Settings
  static const bool enableDebugMode = true; // Set to false for production
  static const bool enableAutoRestore = true;
  static const int purchaseTimeoutSeconds = 30;

  // Error Messages
  static const Map<String, String> errorMessages = {
    'billing_unavailable': 'سیستم پرداخت در دسترس نیست',
    'item_unavailable': 'محصول مورد نظر در دسترس نیست',
    'developer_error': 'خطای توسعه‌دهنده',
    'item_already_owned': 'این محصول قبلاً خریداری شده است',
    'item_not_owned': 'این محصول خریداری نشده است',
    'user_cancelled': 'کاربر خرید را لغو کرد',
    'service_unavailable': 'سرویس پرداخت در دسترس نیست',
    'service_disconnected': 'اتصال به سرویس پرداخت قطع شد',
    'service_timeout': 'زمان اتصال به سرویس پرداخت به پایان رسید',
    'service_dead': 'سرویس پرداخت پاسخ نمی‌دهد',
    'feature_not_supported': 'این ویژگی پشتیبانی نمی‌شود',
    'billing_response_reset': 'پاسخ سیستم پرداخت بازنشانی شد',
    'unknown_error': 'خطای ناشناخته',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'purchase_success': 'خرید با موفقیت انجام شد',
    'restore_success': 'خریدها با موفقیت بازگردانی شدند',
    'consume_success': 'محصول با موفقیت مصرف شد',
  };

  /// Get product title by ID
  static String getProductTitle(String productId) {
    return productDetails[productId]?['title'] ?? productId;
  }

  /// Get product description by ID
  static String getProductDescription(String productId) {
    return productDetails[productId]?['description'] ?? '';
  }

  /// Get product price by ID
  static String getProductPrice(String productId) {
    return productDetails[productId]?['price'] ?? '';
  }

  /// Check if product is a subscription
  static bool isSubscription(String productId) {
    return subscriptionProducts.contains(productId);
  }

  /// Check if product is a one-time purchase
  static bool isOneTimePurchase(String productId) {
    return oneTimeProducts.contains(productId);
  }

  /// Get error message by error code
  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? errorMessages['unknown_error']!;
  }

  // Service Payment Configuration
  static const Map<String, String> servicePaymentSettings = {
    'currency': 'IRR',
    'currency_symbol': 'تومان',
    'payment_gateway': 'cafe_bazaar',
    'test_mode': 'true', // Set to false for production
  };

  // Service Payment Messages
  static const Map<String, String> servicePaymentMessages = {
    'payment_success': 'پرداخت با موفقیت انجام شد',
    'payment_failed': 'خطا در پرداخت',
    'payment_cancelled': 'پرداخت لغو شد',
    'service_already_paid': 'این سرویس قبلاً پرداخت شده است',
    'payment_required': 'برای استفاده از این سرویس باید پرداخت کنید',
    'payment_processing': 'در حال پردازش پرداخت...',
  };

  /// Get service payment message
  static String getServicePaymentMessage(String messageType) {
    return servicePaymentMessages[messageType] ?? 'پیام نامشخص';
  }

  /// Check if service payment is in test mode
  static bool isServicePaymentTestMode() {
    return servicePaymentSettings['test_mode'] == 'true';
  }

  /// Get currency symbol
  static String getCurrencySymbol() {
    return servicePaymentSettings['currency_symbol'] ?? 'تومان';
  }
}
