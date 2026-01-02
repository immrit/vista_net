import '../../../../services/service_api.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_category_model.dart';

class ServiceRepository {
  final ServiceApi _api = ServiceApi();

  Future<List<ServiceCategory>> getCategories() async {
    return await _api.getActiveCategories();
  }

  Future<List<Service>> getServicesByCategory(String categoryId) async {
    return await _api.getServicesByCategory(categoryId);
  }

  Future<List<Service>> getAllServices() async {
    return await _api.getAllActiveServices();
  }
}
