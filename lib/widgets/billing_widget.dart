import 'package:flutter/material.dart';
import '../services/billing_service.dart';

class BillingWidget extends StatefulWidget {
  final String productId;
  final String title;
  final String description;
  final String price;
  final Widget? child;
  final VoidCallback? onPurchaseSuccess;
  final VoidCallback? onPurchaseError;
  final bool showAsButton;
  final String buttonText;
  final Color? buttonColor;
  final Color? textColor;

  const BillingWidget({
    super.key,
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    this.child,
    this.onPurchaseSuccess,
    this.onPurchaseError,
    this.showAsButton = true,
    this.buttonText = 'خرید',
    this.buttonColor,
    this.textColor,
  });

  @override
  State<BillingWidget> createState() => _BillingWidgetState();
}

class _BillingWidgetState extends State<BillingWidget> {
  final BillingService _billingService = BillingService();
  bool _isLoading = false;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  void _checkPurchaseStatus() {
    setState(() {
      _isPurchased = _billingService.isProductPurchased(widget.productId);
    });
  }

  Future<void> _handlePurchase() async {
    if (_isPurchased) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _billingService.purchaseProduct(widget.productId);

      if (result.isSuccess) {
        setState(() {
          _isPurchased = true;
        });
        widget.onPurchaseSuccess?.call();
        _showSuccessMessage('خرید با موفقیت انجام شد');
      } else {
        widget.onPurchaseError?.call();
        _showErrorMessage('خطا در خرید: ${result.message}');
      }
    } catch (e) {
      widget.onPurchaseError?.call();
      _showErrorMessage('خطا در خرید: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPurchased && widget.child != null) {
      return widget.child!;
    }

    if (widget.showAsButton) {
      return ElevatedButton(
        onPressed: _isLoading || _isPurchased ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor ?? Colors.blue,
          foregroundColor: widget.textColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(_isPurchased ? 'خریداری شده' : widget.buttonText),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading || _isPurchased
                      ? null
                      : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.buttonColor ?? Colors.blue,
                    foregroundColor: widget.textColor ?? Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_isPurchased ? 'خریداری شده' : widget.buttonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Feature Widget - Shows content only if purchased
class PremiumFeature extends StatelessWidget {
  final String productId;
  final Widget child;
  final Widget? lockedWidget;
  final String? unlockMessage;

  const PremiumFeature({
    super.key,
    required this.productId,
    required this.child,
    this.lockedWidget,
    this.unlockMessage,
  });

  @override
  Widget build(BuildContext context) {
    final billingService = BillingService();
    final isPurchased = billingService.isProductPurchased(productId);

    if (isPurchased) {
      return child;
    }

    return lockedWidget ??
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.lock, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                unlockMessage ?? 'این ویژگی نیاز به خرید دارد',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }
}

/// Subscription Status Widget
class SubscriptionStatus extends StatelessWidget {
  final String productId;
  final Widget activeWidget;
  final Widget inactiveWidget;

  const SubscriptionStatus({
    super.key,
    required this.productId,
    required this.activeWidget,
    required this.inactiveWidget,
  });

  @override
  Widget build(BuildContext context) {
    final billingService = BillingService();
    final isActive = billingService.isProductPurchased(productId);

    return isActive ? activeWidget : inactiveWidget;
  }
}
