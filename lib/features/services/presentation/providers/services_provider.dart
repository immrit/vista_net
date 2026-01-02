import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_category_model.dart';
import '../../data/repositories/service_repository.dart';

// Repository Provider
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

// State for Services Screen
class ServicesState {
  final bool isLoading;
  final List<ServiceCategory> categories;
  final List<Service> allServices;
  final String? selectedCategoryId;
  final String? error;

  ServicesState({
    this.isLoading = true,
    this.categories = const [],
    this.allServices = const [],
    this.selectedCategoryId,
    this.error,
  });

  ServicesState copyWith({
    bool? isLoading,
    List<ServiceCategory>? categories,
    List<Service>? allServices,
    String? selectedCategoryId,
    String? error,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      allServices: allServices ?? this.allServices,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      error: error ?? this.error,
    );
  }

  // Helper to get services for current selection
  List<Service> get filteredServices {
    if (selectedCategoryId == null || selectedCategoryId == 'all') {
      return allServices;
    }
    return allServices
        .where((s) => s.categoryId == selectedCategoryId)
        .toList();
  }
}

// Controller
class ServicesController extends StateNotifier<ServicesState> {
  final ServiceRepository _repository;

  ServicesController(this._repository) : super(ServicesState()) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final categories = await _repository.getCategories();
      final services = await _repository.getAllServices();

      state = state.copyWith(
        isLoading: false,
        categories: categories,
        allServices: services,
        selectedCategoryId: 'all', // Default to 'All'
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }
}

final servicesProvider =
    StateNotifierProvider<ServicesController, ServicesState>((ref) {
      final repository = ref.watch(serviceRepositoryProvider);
      return ServicesController(repository);
    });
