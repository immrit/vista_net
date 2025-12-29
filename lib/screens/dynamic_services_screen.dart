import 'package:flutter/material.dart';
import '../models/service_category_model.dart';
import '../models/service_model.dart';
import '../services/service_api.dart';
import '../widgets/hamburger_menu.dart';
import '../widgets/app_logo_title.dart';
import '../config/app_theme.dart';
import '../features/service_requests/presentation/screens/new_request_screen.dart';

class DynamicServicesScreen extends StatefulWidget {
  const DynamicServicesScreen({super.key});

  @override
  State<DynamicServicesScreen> createState() => _DynamicServicesScreenState();
}

class _DynamicServicesScreenState extends State<DynamicServicesScreen> {
  final ServiceApi _serviceApi = ServiceApi();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _categoriesWithServices = [];
  List<Service> _allServices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final categoriesWithServices = await _serviceApi
          .getCategoriesWithServices();
      final allServices = await _serviceApi.getAllActiveServices();

      setState(() {
        _categoriesWithServices = categoriesWithServices;
        _allServices = allServices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری: $e')));
      }
    }
  }

  Future<void> _searchServices(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final searchResults = await _serviceApi.searchServices(query);

      setState(() {
        _searchQuery = query;
        _allServices = searchResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در جستجو: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        title: const AppLogoTitle(title: 'خدمات'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _loadData,
            ),
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
      body: Column(
        children: [
          // نوار جستجوی مدرن
          Container(
            margin: const EdgeInsets.all(16),
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
                hintText: 'دنبال چه چیزی میگردی؟',
                hintStyle: TextStyle(
                  color: AppTheme.snappGray.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.snappPrimary,
                  size: 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppTheme.snappGray,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchServices('');
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: AppTheme.snappPrimary,
                        ),
                        onPressed: () =>
                            _searchServices(_searchController.text),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _searchServices,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // محتوای اصلی
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoriesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.snappPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              color: AppTheme.snappPrimary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'در حال بارگذاری...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.snappGray),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_allServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.snappGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.snappGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نتیجه‌ای یافت نشد',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.snappDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً کلمات کلیدی دیگری امتحان کنید',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.snappGray),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header نتایج جستجو
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.snappPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.snappPrimary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: AppTheme.snappPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'نتایج جستجو',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.snappPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_allServices.length} نتیجه',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // لیست نتایج
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _allServices.length,
            itemBuilder: (context, index) {
              final service = _allServices[index];
              return _buildModernServiceCard(service);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesView() {
    if (_categoriesWithServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.snappGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.category_rounded,
                size: 48,
                color: AppTheme.snappGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'دسته‌بندی‌ای یافت نشد',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.snappDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً بعداً دوباره تلاش کنید',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.snappGray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categoriesWithServices.length,
      itemBuilder: (context, index) {
        final categoryData = _categoriesWithServices[index];
        final category = categoryData['category'] as ServiceCategory;
        final services = categoryData['services'] as List<Service>;

        return _buildModernCategorySection(category, services);
      },
    );
  }

  Widget _buildModernCategorySection(
    ServiceCategory category,
    List<Service> services,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // هدر دسته‌بندی مدرن
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.snappPrimary.withValues(alpha: 0.1),
                  AppTheme.snappSecondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: AppTheme.snappPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.snappDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (category.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.description!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.snappGray),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${services.length} خدمت',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // لیست خدمات مدرن
          Padding(
            padding: const EdgeInsets.all(16),
            child: services.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.snappGray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 32,
                          color: AppTheme.snappGray,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'خدمتی در این دسته‌بندی وجود ندارد',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.snappGray),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate responsive card width based on screen size
                      final screenWidth = constraints.maxWidth;
                      final cardWidth = screenWidth < 400
                          ? (screenWidth - 36) /
                                2 // Smaller cards on narrow screens
                          : (screenWidth - 48) /
                                2; // Standard cards on wider screens

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: services.map((service) {
                          return SizedBox(
                            width: cardWidth,
                            child: _buildGridServiceCard(service),
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridServiceCard(Service service) {
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
          onTap: () => _navigateToServiceForm(service),
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
                    _getIconData(service.icon),
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
                if (service.isPaidService) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${service.costAmount.toStringAsFixed(0)} تومان',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildModernServiceCard(Service service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToServiceForm(service),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // آیکون سرویس
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(service.icon),
                    color: AppTheme.snappPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // اطلاعات سرویس
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.snappDark,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.snappGray,
                          height: 1.3,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (service.isPaidService) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${service.costAmount.toStringAsFixed(0)} تومان',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // آیکون فلش
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.snappPrimary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'receipt':
        return Icons.receipt;
      case 'public':
        return Icons.public;
      case 'gavel':
        return Icons.gavel;
      case 'school':
        return Icons.school;
      case 'elderly':
        return Icons.elderly;
      case 'description':
        return Icons.description;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.description;
    }
  }

  void _navigateToServiceForm(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewRequestScreen(
          serviceId: service.id,
          serviceTitle: service.title,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
