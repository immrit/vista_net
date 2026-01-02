import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_category_model.dart';
import '../models/service_model.dart';
import '../models/service_field_model.dart';

class ServiceApi {
  final SupabaseClient _supabase = Supabase.instance.client;

  // دریافت تمام دسته‌بندی‌های فعال
  Future<List<ServiceCategory>> getActiveCategories() async {
    try {
      final response = await _supabase
          .from('service_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      return (response as List)
          .map((json) => ServiceCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطا در دریافت دسته‌بندی‌ها: $e');
    }
  }

  // دریافت خدمات یک دسته‌بندی
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order');

      return (response as List).map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت خدمات: $e');
    }
  }

  // دریافت جزئیات یک خدمت با فیلدهایش
  Future<Service> getServiceWithFields(String serviceId) async {
    try {
      // دریافت اطلاعات خدمت
      final serviceResponse = await _supabase
          .from('services')
          .select()
          .eq('id', serviceId)
          .single();

      // دریافت فیلدهای خدمت
      final fieldsResponse = await _supabase
          .from('service_fields')
          .select()
          .eq('service_id', serviceId)
          .order('sort_order', ascending: true);

      final service = Service.fromJson(serviceResponse);
      final fields = (fieldsResponse as List)
          .map((json) => ServiceField.fromJson(json))
          .toList();

      return service.copyWith(fields: fields);
    } catch (e) {
      throw Exception('خطا در دریافت جزئیات خدمت: $e');
    }
  }

  // جستجو در خدمات
  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('is_active', true)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('sort_order', ascending: true);

      return (response as List).map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطا در جستجو: $e');
    }
  }

  // دریافت تمام خدمات فعال
  Future<List<Service>> getAllActiveServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List).map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطا در دریافت خدمات: $e');
    }
  }

  // دریافت دسته‌بندی‌ها با خدماتشان
  Future<List<Map<String, dynamic>>> getCategoriesWithServices() async {
    try {
      final categories = await getActiveCategories();
      final List<Map<String, dynamic>> result = [];

      for (final category in categories) {
        final services = await getServicesByCategory(category.id);
        result.add({'category': category, 'services': services});
      }

      return result;
    } catch (e) {
      throw Exception('خطا در دریافت دسته‌بندی‌ها و خدمات: $e');
    }
  }
}
