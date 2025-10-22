import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/service_model.dart';
import '../widgets/service_request_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);

    // Mock data - در محیط واقعی از سرویس استفاده می‌شود
    await Future.delayed(const Duration(milliseconds: 500));

    _services = [
      ServiceModel(
        id: '1',
        title: 'دریافت ابلاغیه',
        description: 'دریافت ابلاغیه‌های قضایی و اداری',
        icon: 'gavel',
      ),
      ServiceModel(
        id: '2',
        title: 'استعلام احکام',
        description: 'استعلام احکام قضایی و آراء صادره',
        icon: 'assignment',
      ),
      ServiceModel(
        id: '3',
        title: 'درخواست گواهی',
        description: 'درخواست گواهی‌های مختلف',
        icon: 'card_membership',
      ),
      ServiceModel(
        id: '4',
        title: 'پرینت مدارک',
        description: 'پرینت و تکثیر مدارک',
        icon: 'print',
      ),
      ServiceModel(
        id: '5',
        title: 'ارسال پیامک',
        description: 'ارسال پیامک اطلاع‌رسانی',
        icon: 'sms',
      ),
      ServiceModel(
        id: '6',
        title: 'تهیه فتوکپی',
        description: 'تهیه فتوکپی رنگی و سیاه و سفید',
        icon: 'content_copy',
      ),
    ];

    setState(() => _isLoading = false);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'gavel':
        return Icons.gavel;
      case 'assignment':
        return Icons.assignment;
      case 'card_membership':
        return Icons.card_membership;
      case 'print':
        return Icons.print;
      case 'sms':
        return Icons.sms;
      case 'content_copy':
        return Icons.content_copy;
      default:
        return Icons.description;
    }
  }

  void _showServiceDialog(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => ServiceRequestDialog(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text(
          'خدمات کافینت',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadServices,
              color: AppTheme.snappPrimary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.snappPrimary,
                            AppTheme.snappSecondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'خوش آمدید!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'خدمت مورد نظر خود را انتخاب کنید',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Services Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return _buildServiceCard(service);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showServiceDialog(service),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(service.icon),
                  size: 32,
                  color: AppTheme.snappPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.snappDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                style: TextStyle(fontSize: 11, color: AppTheme.snappGray),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
