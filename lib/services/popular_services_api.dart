import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class PopularServicesApi {
  final SupabaseClient _supabase = Supabase.instance.client;

  // دریافت خدمات پرطرفدار
  Future<List<Service>> getPopularServices({int limit = 6}) async {
    try {
      // کوئری ساده برای تست
      final response = await _supabase
          .from('popular_services')
          .select('service_id, sort_order, is_active')
          .eq('is_active', true)
          .order('sort_order')
          .timeout(const Duration(seconds: 10)); // اضافه کردن timeout

      if (response.isEmpty) {
        return [];
      }

      // دریافت service_id ها
      final serviceIds = response.map((item) => item['service_id']).toList();

      // دریافت خدمات
      final servicesResponse = await _supabase
          .from('services')
          .select('*')
          .inFilter('id', serviceIds)
          .eq('is_active', true)
          .timeout(const Duration(seconds: 10)); // اضافه کردن timeout

      final services = (servicesResponse as List)
          .map((item) => Service.fromJson(item))
          .toList();

      return services;
    } catch (e) {
      // به جای throw کردن، لیست خالی برمی‌گردانیم
      return [];
    }
  }

  // اضافه کردن خدمت به لیست پرطرفدار (فقط ادمین)
  Future<void> addPopularService(String serviceId, {int sortOrder = 0}) async {
    try {
      await _supabase.from('popular_services').insert({
        'service_id': serviceId,
        'sort_order': sortOrder,
        'is_active': true,
      });
    } catch (e) {
      throw Exception('خطا در اضافه کردن خدمت پرطرفدار: $e');
    }
  }

  // حذف خدمت از لیست پرطرفدار (فقط ادمین)
  Future<void> removePopularService(String serviceId) async {
    try {
      await _supabase
          .from('popular_services')
          .delete()
          .eq('service_id', serviceId);
    } catch (e) {
      throw Exception('خطا در حذف خدمت پرطرفدار: $e');
    }
  }

  // به‌روزرسانی ترتیب خدمات پرطرفدار (فقط ادمین)
  Future<void> updatePopularServiceOrder(
    String serviceId,
    int sortOrder,
  ) async {
    try {
      await _supabase
          .from('popular_services')
          .update({'sort_order': sortOrder})
          .eq('service_id', serviceId);
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی ترتیب خدمت: $e');
    }
  }

  // دریافت آمار خدمات برای انتخاب پرطرفدارترین‌ها
  Future<List<Map<String, dynamic>>> getServiceAnalytics() async {
    try {
      final response = await _supabase
          .from('service_analytics')
          .select('''
            service_id,
            view_count,
            request_count,
            completion_count,
            services!inner(id, title, description, icon)
          ''')
          .order('request_count', ascending: false)
          .limit(20);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('خطا در دریافت آمار خدمات: $e');
    }
  }
}
