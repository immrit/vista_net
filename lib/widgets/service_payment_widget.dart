import 'package:flutter/material.dart';
import '../services/service_payment_service.dart';
import '../models/service_model.dart';

class ServicePaymentWidget extends StatefulWidget {
  final Service service;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;
  final bool showAsButton;
  final String buttonText;
  final Color? buttonColor;
  final Color? textColor;

  const ServicePaymentWidget({
    super.key,
    required this.service,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.showAsButton = true,
    this.buttonText = 'پرداخت',
    this.buttonColor,
    this.textColor,
  });

  @override
  State<ServicePaymentWidget> createState() => _ServicePaymentWidgetState();
}

class _ServicePaymentWidgetState extends State<ServicePaymentWidget> {
  final ServicePaymentService _paymentService = ServicePaymentService();
  bool _isLoading = false;
  bool _isPaid = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  void _checkPaymentStatus() {
    setState(() {
      _isPaid = _paymentService.isServicePaid(widget.service.id);
    });
  }

  Future<void> _handlePayment() async {
    if (_isPaid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _paymentService.payForService(widget.service);

      if (result.isSuccess) {
        setState(() {
          _isPaid = true;
        });
        widget.onPaymentSuccess?.call();
        _showSuccessMessage('پرداخت با موفقیت انجام شد');
      } else {
        widget.onPaymentError?.call();
        _showErrorMessage('خطا در پرداخت: ${result.message}');
      }
    } catch (e) {
      widget.onPaymentError?.call();
      _showErrorMessage('خطا در پرداخت: $e');
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
    // If service is not paid, show payment option
    if (!widget.service.isPaidService) {
      return const SizedBox.shrink(); // Don't show payment for free services
    }

    if (widget.showAsButton) {
      return ElevatedButton(
        onPressed: _isLoading || _isPaid ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor ?? Colors.green,
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
            : Text(_isPaid ? 'پرداخت شده' : widget.buttonText),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: _isPaid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'هزینه سرویس',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.service.title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.service.costAmount.toStringAsFixed(0)} تومان',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading || _isPaid ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.buttonColor ?? Colors.green,
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
                      : Text(_isPaid ? 'پرداخت شده' : widget.buttonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Service Payment Status Widget
class ServicePaymentStatus extends StatelessWidget {
  final String serviceId;
  final Widget paidWidget;
  final Widget unpaidWidget;

  const ServicePaymentStatus({
    super.key,
    required this.serviceId,
    required this.paidWidget,
    required this.unpaidWidget,
  });

  @override
  Widget build(BuildContext context) {
    final paymentService = ServicePaymentService();
    final isPaid = paymentService.isServicePaid(serviceId);

    return isPaid ? paidWidget : unpaidWidget;
  }
}

/// Service Payment Confirmation Dialog
class ServicePaymentConfirmationDialog extends StatefulWidget {
  final Service service;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentError;

  const ServicePaymentConfirmationDialog({
    super.key,
    required this.service,
    this.onPaymentSuccess,
    this.onPaymentError,
  });

  @override
  State<ServicePaymentConfirmationDialog> createState() =>
      _ServicePaymentConfirmationDialogState();
}

class _ServicePaymentConfirmationDialogState
    extends State<ServicePaymentConfirmationDialog> {
  final ServicePaymentService _paymentService = ServicePaymentService();
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _paymentService.payForService(widget.service);

      if (result.isSuccess) {
        widget.onPaymentSuccess?.call();
        if (mounted) Navigator.of(context).pop(true);
        _showSuccessMessage('پرداخت با موفقیت انجام شد');
      } else {
        widget.onPaymentError?.call();
        _showErrorMessage('خطا در پرداخت: ${result.message}');
      }
    } catch (e) {
      widget.onPaymentError?.call();
      _showErrorMessage('خطا در پرداخت: $e');
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
    return AlertDialog(
      title: const Text('تأیید پرداخت'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'آیا می‌خواهید برای سرویس زیر پرداخت کنید؟',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.service.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('هزینه:'),
                    Text(
                      '${widget.service.costAmount.toStringAsFixed(0)} تومان',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('پرداخت'),
        ),
      ],
    );
  }
}
