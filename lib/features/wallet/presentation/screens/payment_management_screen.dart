import 'package:flutter/material.dart';
import '../../../../services/payment_management_service.dart';
import '../../../../widgets/app_logo_title.dart';
import '../../../../config/app_theme.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with TickerProviderStateMixin {
  final PaymentManagementService _paymentService = PaymentManagementService();

  late TabController _tabController;

  // Data
  List<Map<String, dynamic>> _payments = [];
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _serviceStats = [];
  List<Map<String, dynamic>> _reports = [];

  // Loading states
  bool _isLoadingPayments = false;
  bool _isLoadingStats = false;
  bool _isLoadingReports = false;

  // Filters
  String _selectedStatus = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadPayments(),
      _loadStatistics(),
      _loadServiceStats(),
      _loadReports(),
    ]);
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoadingPayments = true;
    });

    try {
      final payments = await _paymentService.getAllPayments(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _payments = payments;
      });
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری پرداخت‌ها: $e');
    } finally {
      setState(() {
        _isLoadingPayments = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await _paymentService.getPaymentStatistics(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری آمار: $e');
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _loadServiceStats() async {
    try {
      final stats = await _paymentService.getServicePaymentStats();
      setState(() {
        _serviceStats = stats;
      });
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری آمار سرویس‌ها: $e');
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoadingReports = true;
    });

    try {
      final reports = await _paymentService.getPaymentReports(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _reports = reports;
      });
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری گزارش‌ها: $e');
    } finally {
      setState(() {
        _isLoadingReports = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _showFilterDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('فیلتر پرداخت‌ها'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'وضعیت پرداخت',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('همه')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('در انتظار'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('تکمیل شده'),
                      ),
                      DropdownMenuItem(value: 'failed', child: Text('ناموفق')),
                      DropdownMenuItem(
                        value: 'refunded',
                        child: Text('برگشت شده'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('تاریخ شروع'),
                    subtitle: Text(
                      _startDate?.toString().split(' ')[0] ?? 'انتخاب نشده',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('تاریخ پایان'),
                    subtitle: Text(
                      _endDate?.toString().split(' ')[0] ?? 'انتخاب نشده',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 'all';
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: const Text('پاک کردن'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) Navigator.of(context).pop();
                    _loadPayments();
                  },
                  child: const Text('اعمال فیلتر'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogoTitle(title: 'مدیریت پرداخت‌ها'),
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'پرداخت‌ها', icon: Icon(Icons.payment)),
            Tab(text: 'آمار', icon: Icon(Icons.analytics)),
            Tab(text: 'سرویس‌ها', icon: Icon(Icons.business)),
            Tab(text: 'گزارش‌ها', icon: Icon(Icons.assessment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentsTab(),
          _buildStatisticsTab(),
          _buildServiceStatsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_isLoadingPayments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return const Center(child: Text('هیچ پرداختی یافت نشد'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(payment['payment_status']),
              child: Icon(
                _getStatusIcon(payment['payment_status']),
                color: Colors.white,
              ),
            ),
            title: Text(payment['service_title'] ?? 'نامشخص'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مبلغ: ${payment['amount']} ${payment['currency']}'),
                Text('وضعیت: ${_getStatusText(payment['payment_status'])}'),
                Text('تاریخ: ${_formatDate(payment['created_at'])}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handlePaymentAction(value, payment),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('مشاهده جزئیات'),
                ),
                if (payment['payment_status'] == 'completed')
                  const PopupMenuItem(
                    value: 'refund',
                    child: Text('برگشت پرداخت'),
                  ),
                const PopupMenuItem(
                  value: 'update',
                  child: Text('به‌روزرسانی وضعیت'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard(
            'کل پرداخت‌ها',
            '${_statistics['total_payments'] ?? 0}',
            Icons.payment,
            Colors.blue,
          ),
          _buildStatCard(
            'کل مبلغ',
            '${_statistics['total_amount'] ?? 0} تومان',
            Icons.attach_money,
            Colors.green,
          ),
          _buildStatCard(
            'پرداخت‌های موفق',
            '${_statistics['successful_payments'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatCard(
            'پرداخت‌های ناموفق',
            '${_statistics['failed_payments'] ?? 0}',
            Icons.error,
            Colors.red,
          ),
          _buildStatCard(
            'کاربران منحصر',
            '${_statistics['unique_users'] ?? 0}',
            Icons.people,
            Colors.orange,
          ),
          _buildStatCard(
            'سرویس‌های منحصر',
            '${_statistics['unique_services'] ?? 0}',
            Icons.business,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serviceStats.length,
      itemBuilder: (context, index) {
        final service = _serviceStats[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${index + 1}'),
            ),
            title: Text(service['service_title'] ?? 'نامشخص'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('هزینه: ${service['cost_amount']} تومان'),
                Text('کل پرداخت‌ها: ${service['total_payments']}'),
                Text('کل درآمد: ${service['total_revenue']} تومان'),
                Text('پرداخت‌های موفق: ${service['successful_payments']}'),
                Text(
                  'میانگین پرداخت: ${service['average_payment_amount']} تومان',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(report['report_type'][0].toUpperCase()),
            ),
            title: Text('گزارش ${_getReportTypeText(report['report_type'])}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تاریخ: ${_formatDate(report['report_date'])}'),
                Text('کل پرداخت‌ها: ${report['total_payments']}'),
                Text('کل مبلغ: ${report['total_amount']} تومان'),
                Text('پرداخت‌های موفق: ${report['successful_payments']}'),
                Text('پرداخت‌های ناموفق: ${report['failed_payments']}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check;
      case 'pending':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'تکمیل شده';
      case 'pending':
        return 'در انتظار';
      case 'failed':
        return 'ناموفق';
      case 'refunded':
        return 'برگشت شده';
      default:
        return 'نامشخص';
    }
  }

  String _getReportTypeText(String type) {
    switch (type) {
      case 'daily':
        return 'روزانه';
      case 'weekly':
        return 'هفتگی';
      case 'monthly':
        return 'ماهانه';
      case 'yearly':
        return 'سالانه';
      default:
        return 'نامشخص';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'نامشخص';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'نامشخص';
    }
  }

  void _handlePaymentAction(String action, Map<String, dynamic> payment) {
    switch (action) {
      case 'view':
        _showPaymentDetails(payment);
        break;
      case 'refund':
        _showRefundDialog(payment);
        break;
      case 'update':
        _showUpdateStatusDialog(payment);
        break;
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جزئیات پرداخت'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('شناسه پرداخت: ${payment['id']}'),
              Text('سرویس: ${payment['service_title']}'),
              Text('مبلغ: ${payment['amount']} ${payment['currency']}'),
              Text('وضعیت: ${_getStatusText(payment['payment_status'])}'),
              Text('تاریخ ایجاد: ${_formatDate(payment['created_at'])}'),
              if (payment['paid_at'] != null)
                Text('تاریخ پرداخت: ${_formatDate(payment['paid_at'])}'),
              if (payment['cafe_bazaar_transaction_id'] != null)
                Text('شناسه تراکنش: ${payment['cafe_bazaar_transaction_id']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(Map<String, dynamic> payment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('برگشت پرداخت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'آیا مطمئن هستید که می‌خواهید پرداخت ${payment['amount']} تومان را برگشت دهید؟',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'دلیل برگشت',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _paymentService.refundPayment(
                  payment['id'],
                  reasonController.text,
                );
                _showSuccessSnackBar('پرداخت با موفقیت برگشت شد');
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                _loadPayments();
              } catch (e) {
                _showErrorSnackBar('خطا در برگشت پرداخت: $e');
              }
            },
            child: const Text('برگشت'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> payment) {
    String selectedStatus = payment['payment_status'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('به‌روزرسانی وضعیت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'وضعیت جدید'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('در انتظار')),
                  DropdownMenuItem(
                    value: 'completed',
                    child: Text('تکمیل شده'),
                  ),
                  DropdownMenuItem(value: 'failed', child: Text('ناموفق')),
                  DropdownMenuItem(value: 'refunded', child: Text('برگشت شده')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _paymentService.updatePaymentStatus(
                    payment['id'],
                    selectedStatus,
                  );
                  _showSuccessSnackBar('وضعیت پرداخت به‌روزرسانی شد');
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  _loadPayments();
                } catch (e) {
                  _showErrorSnackBar('خطا در به‌روزرسانی وضعیت: $e');
                }
              },
              child: const Text('به‌روزرسانی'),
            ),
          ],
        ),
      ),
    );
  }
}
