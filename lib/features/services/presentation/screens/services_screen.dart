import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../providers/services_provider.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_category_model.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    final controller = ref.read(servicesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'خدمات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.error}'),
                  ElevatedButton(
                    onPressed: () => controller.loadData(),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Categories List
                _buildCategoriesList(
                  context,
                  state.categories,
                  state.selectedCategoryId,
                  controller,
                ),
                const Divider(height: 1),
                // Services Grid
                Expanded(
                  child: _buildServicesGrid(context, state.filteredServices),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    List<ServiceCategory> categories,
    String? selectedId,
    ServicesController controller,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : categories[index - 1];
          final id = isAll ? 'all' : category!.id;
          final isSelected = selectedId == id;
          final title = isAll ? 'همه خدمات' : category!.title;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(title),
              selected: isSelected,
              onSelected: (_) => controller.selectCategory(id),
              selectedColor: AppTheme.snappPrimary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Vazir',
              ),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.snappPrimary
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<Service> services) {
    if (services.isEmpty) {
      return const Center(child: Text('هیچ خدمتی یافت نشد'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85, // Adjusted for card height
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(context, services[index]);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, '/service-form', arguments: service);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getServiceIcon(service.icon),
                  size: 32,
                  color: AppTheme.snappPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Vazir',
                ),
              ),
              const SizedBox(height: 4),
              if (service.isPaidService)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${service.costAmount.toStringAsFixed(0)} ریال',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
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
      default:
        return Icons.category_rounded;
    }
  }
}
