import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/service_api.dart';
import '../services/popular_services_api.dart';
import '../models/service_model.dart';
import '../widgets/app_logo.dart';
import '../widgets/hamburger_menu.dart';
import 'dynamic_services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceApi _serviceApi = ServiceApi();
  final PopularServicesApi _popularServicesApi = PopularServicesApi();
  List<Service> _popularServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularServices();
  }

  Future<void> _loadPopularServices() async {
    try {
      // ابتدا سعی می‌کنیم خدمات پرطرفدار را از دیتابیس دریافت کنیم
      final popularServices = await _popularServicesApi.getPopularServices(
        limit: 6,
      );

      if (!mounted) return; // Check before setState

      if (popularServices.isNotEmpty) {
        setState(() {
          _popularServices = popularServices;
          _isLoading = false;
        });
        return; // خروج از تابع
      }

      // اگر خدمات پرطرفدار تعریف نشده، از تمام خدمات انتخاب می‌کنیم
      final allServices = await _serviceApi.getAllActiveServices();

      if (!mounted) return; // Check before setState

      setState(() {
        _popularServices = allServices.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      // در صورت خطا، از تمام خدمات استفاده می‌کنیم
      try {
        final allServices = await _serviceApi.getAllActiveServices();

        if (!mounted) return; // Check before setState

        setState(() {
          _popularServices = allServices.take(6).toList();
          _isLoading = false;
        });
      } catch (fallbackError) {
        if (!mounted) return; // Check before setState

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری خدمات: $fallbackError')),
        );
      }
    }
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;

    // Navigate to services screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DynamicServicesScreen()),
    );
  }

  void _navigateToSupportChat() {
    // Navigate to tickets/support screen
    Navigator.pushNamed(context, '/support-chat');
  }

  void _navigateToAllServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DynamicServicesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        title: const AppLogo(
          showTitle: true,
          size: 32,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // Service Payments button
          IconButton(
            icon: const Icon(Icons.payment, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/service-payments');
            },
            tooltip: 'پرداخت سرویس‌ها',
          ),
          // Billing button
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/billing');
            },
            tooltip: 'مدیریت خریدها',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
      endDrawer: const HamburgerMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(),
              const SizedBox(height: 24),

              // Search Box
              _buildSearchBox(),
              const SizedBox(height: 24),

              // Support Chat Button
              _buildSupportChatButton(),
              const SizedBox(height: 24),

              // Popular Services Section
              _buildPopularServicesSection(),
              const SizedBox(height: 24),

              // View All Services Button
              _buildViewAllServicesButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.snappPrimary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppLogo(size: 48),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خوش آمدید',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'چه خدمتی نیاز دارید؟',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'دنبال چی می‌گردی؟',
          hintStyle: TextStyle(
            color: AppTheme.snappGray.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.snappPrimary,
            size: 24,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.snappPrimary,
            ),
            onPressed: _performSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildSupportChatButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToSupportChat,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'چت با پشتیبانی',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سوالات خود را از پشتیبان بپرسید',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: AppTheme.snappAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'خدمات پرطرفدار',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.snappDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading) _buildLoadingGrid() else _buildServicesGrid(),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive card width based on screen size
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth < 400
            ? (screenWidth - 36) /
                  2 // Smaller cards on narrow screens
            : (screenWidth - 48) / 2; // Standard cards on wider screens

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(6, (index) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                height: 120, // Fixed height for loading cards
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.snappPrimary,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildServicesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive card width based on screen size
        final screenWidth = constraints.maxWidth;
        final cardWidth = screenWidth < 400
            ? (screenWidth - 36) /
                  2 // Smaller cards on narrow screens
            : (screenWidth - 48) / 2; // Standard cards on wider screens

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _popularServices.map((service) {
            return SizedBox(
              width: cardWidth,
              child: _buildServiceCard(service),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildServiceCard(Service service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to service details
            Navigator.pushNamed(context, '/service-form', arguments: service);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(service.icon),
                    color: AppTheme.snappPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    service.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.snappDark,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.snappGray,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllServicesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToAllServices,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.snappPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_view_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'مشاهده کامل خدمات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'document':
        return Icons.description_rounded;
      case 'certificate':
        return Icons.verified_rounded;
      case 'license':
        return Icons.card_membership_rounded;
      case 'permit':
        return Icons.assignment_rounded;
      case 'registration':
        return Icons.app_registration_rounded;
      case 'renewal':
        return Icons.refresh_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'consultation':
        return Icons.psychology_rounded;
      case 'support':
        return Icons.support_agent_rounded;
      case 'information':
        return Icons.info_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
