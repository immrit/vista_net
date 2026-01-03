import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../providers/services_provider.dart';
import '../providers/local_favorites_provider.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_category_model.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    final controller = ref.read(servicesProvider.notifier);
    final favoritesState = ref.watch(localFavoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'خدمات',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Vazir'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false, // No back button
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ServiceSearchDelegate(
                  services: state.filteredServices,
                  favoritesState: favoritesState,
                  ref: ref,
                ),
              );
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.snappPrimary),
            )
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطا: ${state.error}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadData(),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildCategoryTabs(
                  context,
                  ref,
                  state.categories,
                  state.selectedCategoryId,
                  controller,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildServicesGrid(
                    context,
                    ref,
                    state.filteredServices,
                    favoritesState,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    WidgetRef ref,
    List<ServiceCategory> categories,
    String? selectedId,
    ServicesController controller,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final id = isAll ? 'all' : category!.id;
          final isSelected = selectedId == id;
          final title = isAll ? 'خدمات جدید' : category!.title;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => controller.selectCategory(id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.snappPrimary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.snappPrimary
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontFamily: 'Vazir',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesGrid(
    BuildContext context,
    WidgetRef ref,
    List<Service> services,
    LocalFavoritesState favoritesState,
  ) {
    if (services.isEmpty) {
      return const Center(
        child: Text(
          'هیچ خدمتی یافت نشد',
          style: TextStyle(color: Colors.black54, fontFamily: 'Vazir'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceItem(context, ref, services[index], favoritesState);
      },
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    WidgetRef ref,
    Service service,
    LocalFavoritesState favoritesState,
  ) {
    final isNew = DateTime.now().difference(service.createdAt).inDays < 7;
    final isFavorite = favoritesState.isFavorite(service.id);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/service-form', arguments: service);
      },
      onLongPress: () async {
        final notifier = ref.read(localFavoritesProvider.notifier);
        final isNowFavorite = await notifier.toggleFavorite(service.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNowFavorite
                    ? 'به علاقه‌مندی‌ها اضافه شد'
                    : 'از علاقه‌مندی‌ها حذف شد',
                style: const TextStyle(fontFamily: 'Vazir'),
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: isNowFavorite
                  ? AppTheme.snappPrimary
                  : Colors.grey,
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _buildServiceImage(service),
                ),
              ),
              if (isNew)
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'جدید',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                  ),
                ),
              if (isFavorite)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImage(Service service) {
    if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.network(
          service.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(service);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return _buildFallbackIcon(service);
  }

  Widget _buildFallbackIcon(Service service) {
    return Center(
      child: Icon(
        _getServiceIcon(service.icon),
        color: AppTheme.snappPrimary,
        size: 28,
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
      default:
        return Icons.category_rounded;
    }
  }
}

/// Search delegate for services
class _ServiceSearchDelegate extends SearchDelegate<Service?> {
  final List<Service> services;
  final LocalFavoritesState favoritesState;
  final WidgetRef ref;

  _ServiceSearchDelegate({
    required this.services,
    required this.favoritesState,
    required this.ref,
  });

  @override
  String get searchFieldLabel => 'جستجوی خدمات...';

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(fontFamily: 'Vazir', fontSize: 16);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_forward),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = services.where((service) {
      return service.title.toLowerCase().contains(query.toLowerCase()) ||
          service.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'نتیجه‌ای یافت نشد',
          style: TextStyle(fontFamily: 'Vazir', color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final service = results[index];
        final isFavorite = favoritesState.isFavorite(service.id);
        final isNew = DateTime.now().difference(service.createdAt).inDays < 7;

        return GestureDetector(
          onTap: () {
            close(context, service);
            Navigator.pushNamed(context, '/service-form', arguments: service);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child:
                          service.imageUrl != null &&
                              service.imageUrl!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.network(
                                service.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.category_rounded,
                                  color: AppTheme.snappPrimary,
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.category_rounded,
                              color: AppTheme.snappPrimary,
                              size: 28,
                            ),
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: -6,
                      left: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'جدید',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ),
                    ),
                  if (isFavorite)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
