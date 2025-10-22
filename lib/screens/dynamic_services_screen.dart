import 'package:flutter/material.dart';
import '../models/service_category_model.dart';
import '../models/service_model.dart';
import '../services/service_api.dart';
import 'service_form_screen.dart';

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
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری داده‌ها: $e')));
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
      appBar: AppBar(
        title: const Text('دسته‌بندی خدمات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // نوار جستجو
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'دنبال چه چیزی میگردی؟',
                prefixIcon: const Icon(Icons.filter_list),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchServices(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: _searchServices,
            ),
          ),

          // محتوای اصلی
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoriesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_allServices.isEmpty) {
      return const Center(child: Text('نتیجه‌ای یافت نشد'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allServices.length,
      itemBuilder: (context, index) {
        final service = _allServices[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildCategoriesView() {
    if (_categoriesWithServices.isEmpty) {
      return const Center(child: Text('دسته‌بندی‌ای یافت نشد'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categoriesWithServices.length,
      itemBuilder: (context, index) {
        final categoryData = _categoriesWithServices[index];
        final category = categoryData['category'] as ServiceCategory;
        final services = categoryData['services'] as List<Service>;

        return _buildCategorySection(category, services);
      },
    );
  }

  Widget _buildCategorySection(
    ServiceCategory category,
    List<Service> services,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // هدر دسته‌بندی
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getIconData(category.icon),
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (category.description != null)
                        Text(
                          category.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // نمایش تمام خدمات این دسته‌بندی
                  },
                  child: const Text('بیشتر...'),
                ),
              ],
            ),
          ),

          // لیست خدمات
          Padding(
            padding: const EdgeInsets.all(16),
            child: services.isEmpty
                ? const Text('خدمتی در این دسته‌بندی وجود ندارد')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(services[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToServiceForm(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // آیکون خدمت
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getIconData(service.icon),
                  color: Colors.blue[700],
                  size: 24,
                ),
              ),

              const SizedBox(height: 8),

              // عنوان خدمت
              Text(
                service.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // توضیحات کوتاه
              Text(
                service.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (service.isPaidService) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${service.costAmount.toStringAsFixed(0)} تومان',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
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
        builder: (context) => ServiceFormScreen(service: service),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
