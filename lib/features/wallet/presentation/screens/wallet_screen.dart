import 'package:flutter/material.dart';
import '../../../../services/billing_service.dart';
import '../../../../widgets/shimmer_loading.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final BillingService _billingService = BillingService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _statusMessage = '';

  // Sample product IDs - replace with your actual product IDs from Cafe Bazaar
  final List<String> _productIds = [
    'premium_upgrade',
    'remove_ads',
    'unlock_features',
    'monthly_subscription',
  ];

  @override
  void initState() {
    super.initState();
    _initializeBilling();
  }

  Future<void> _initializeBilling() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing billing...';
    });

    final result = await _billingService.initialize();

    if (result) {
      await _loadProductDetails();
      setState(() {
        _statusMessage = 'Billing initialized successfully';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to initialize billing';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProductDetails() async {
    final result = await _billingService.getMultipleProductDetails(_productIds);

    if (result.isSuccess && result.data != null) {
      setState(() {
        _products = (result.data as List)
            .map((json) => Product.fromJson(json))
            .toList();
      });
    }
  }

  Future<void> _purchaseProduct(String productId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing purchase...';
    });

    final result = await _billingService.purchaseProduct(productId);

    setState(() {
      _isLoading = false;
      _statusMessage = result.message;
    });

    if (result.isSuccess) {
      _showSuccessDialog(
        'Purchase Successful',
        'Your purchase has been completed successfully!',
      );
    } else {
      _showErrorDialog('Purchase Failed', result.message);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Restoring purchases...';
    });

    final result = await _billingService.restorePurchases();

    setState(() {
      _isLoading = false;
      _statusMessage = result.message;
    });

    if (result.isSuccess) {
      _showSuccessDialog(
        'Purchases Restored',
        'Your purchases have been restored successfully!',
      );
    } else {
      _showErrorDialog('Restore Failed', result.message);
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe Bazaar Billing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restorePurchases,
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status message
          if (_statusMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _statusMessage.contains('Failed') ||
                        _statusMessage.contains('error')
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _statusMessage.contains('Failed') ||
                          _statusMessage.contains('error')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color:
                      _statusMessage.contains('Failed') ||
                          _statusMessage.contains('error')
                      ? Colors.red.shade800
                      : Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: ShimmerLoading.circular(size: 40)),
            ),

          // Products list
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isPurchased = _billingService.isProductPurchased(
                        product.productId,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.description),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price} ${product.currency}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isPurchased)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Purchased',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: isPurchased
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                )
                              : ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () =>
                                            _purchaseProduct(product.productId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Buy'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Billing Provider for state management
class BillingProvider extends ChangeNotifier {
  final BillingService _billingService = BillingService();

  bool _isInitialized = false;
  List<String> _purchasedItems = [];
  String _statusMessage = '';

  bool get isInitialized => _isInitialized;
  List<String> get purchasedItems => _purchasedItems;
  String get statusMessage => _statusMessage;

  Future<void> initialize() async {
    final result = await _billingService.initialize();
    _isInitialized = result;
    _statusMessage = result
        ? 'Billing initialized successfully'
        : 'Failed to initialize billing';
    _purchasedItems = _billingService.purchasedItems;
    notifyListeners();
  }

  Future<void> purchaseProduct(String productId) async {
    final result = await _billingService.purchaseProduct(productId);
    _statusMessage = result.message;
    _purchasedItems = _billingService.purchasedItems;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    final result = await _billingService.restorePurchases();
    _statusMessage = result.message;
    _purchasedItems = _billingService.purchasedItems;
    notifyListeners();
  }

  bool isProductPurchased(String productId) {
    return _billingService.isProductPurchased(productId);
  }
}
