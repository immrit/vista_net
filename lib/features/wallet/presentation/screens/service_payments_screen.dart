import 'package:flutter/material.dart';
import '../../../../services/service_payment_service.dart';
import '../../../../services/service_api.dart';
import '../../../../models/service_model.dart';

class ServicePaymentsScreen extends StatefulWidget {
  const ServicePaymentsScreen({super.key});

  @override
  State<ServicePaymentsScreen> createState() => _ServicePaymentsScreenState();
}

class _ServicePaymentsScreenState extends State<ServicePaymentsScreen> {
  final ServicePaymentService _paymentService = ServicePaymentService();
  final ServiceApi _serviceApi = ServiceApi();

  List<Service> _services = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'در حال بارگذاری سرویس‌ها...';
    });

    try {
      final services = await _serviceApi.getAllActiveServices();
      setState(() {
        _services = services.where((service) => service.isPaidService).toList();
        _statusMessage = '${_services.length} سرویس پرداختی یافت شد';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'خطا در بارگذاری سرویس‌ها: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _payForService(Service service) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'در حال پردازش پرداخت...';
    });

    try {
      final result = await _paymentService.payForService(service);

      setState(() {
        _isLoading = false;
        _statusMessage = result.message;
      });

      if (result.isSuccess) {
        _showSuccessDialog('پرداخت موفق', 'پرداخت با موفقیت انجام شد!');
        // Refresh the list
        _loadServices();
      } else {
        _showErrorDialog('خطا در پرداخت', result.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'خطا در پرداخت: $e';
      });
      _showErrorDialog('خطا در پرداخت', e.toString());
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
            child: const Text('باشه'),
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
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پرداخت سرویس‌ها'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServices,
            tooltip: 'بروزرسانی',
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
                    _statusMessage.contains('خطا') ||
                        _statusMessage.contains('Failed')
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _statusMessage.contains('خطا') ||
                          _statusMessage.contains('Failed')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color:
                      _statusMessage.contains('خطا') ||
                          _statusMessage.contains('Failed')
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
              child: CircularProgressIndicator(),
            ),

          // Services list
          Expanded(
            child: _services.isEmpty
                ? const Center(
                    child: Text(
                      'هیچ سرویس پرداختی یافت نشد',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      final isPaid = _paymentService.isServicePaid(service.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPaid
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              isPaid ? Icons.check : Icons.payment,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            service.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.description),
                              const SizedBox(height: 4),
                              Text(
                                '${service.costAmount.toStringAsFixed(0)} تومان',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isPaid)
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
                                    'پرداخت شده',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: isPaid
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                )
                              : ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => _payForService(service),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('پرداخت'),
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
