import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ایجاد اطلاع‌رسانی جدید
  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    String? imageUrl,
    NotificationPriority priority = NotificationPriority.medium,
    DateTime? scheduledAt,
    List<String> targetUsers = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      final response = await _supabase
          .from('notifications')
          .insert({
            'title': title,
            'message': message,
            'image_url': imageUrl,
            'priority': NotificationModel.priorityToString(priority),
            'status': NotificationModel.statusToString(
              NotificationStatus.draft,
            ),
            'scheduled_at': scheduledAt?.toIso8601String(),
            'created_by': user.id,
            'target_users': targetUsers,
            'metadata': metadata,
            'is_active': true,
          })
          .select()
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در ایجاد اطلاع‌رسانی: $e');
    }
  }

  // دریافت تمام اطلاع‌رسانی‌ها
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطا در دریافت اطلاع‌رسانی‌ها: $e');
    }
  }

  // دریافت اطلاع‌رسانی‌های فعال برای کاربران
  Future<List<NotificationModel>> getActiveNotificationsForUsers() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطا در دریافت اطلاع‌رسانی‌های فعال: $e');
    }
  }

  // دریافت اطلاع‌رسانی بر اساس ID
  Future<NotificationModel> getNotificationById(String id) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('id', id)
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در دریافت اطلاع‌رسانی: $e');
    }
  }

  // به‌روزرسانی اطلاع‌رسانی
  Future<NotificationModel> updateNotification(
    String id, {
    String? title,
    String? message,
    String? imageUrl,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? scheduledAt,
    List<String>? targetUsers,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (message != null) updateData['message'] = message;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (priority != null) {
        updateData['priority'] = NotificationModel.priorityToString(priority);
      }
      if (status != null) {
        updateData['status'] = NotificationModel.statusToString(status);
      }
      if (scheduledAt != null) {
        updateData['scheduled_at'] = scheduledAt.toIso8601String();
      }
      if (targetUsers != null) updateData['target_users'] = targetUsers;
      if (metadata != null) updateData['metadata'] = metadata;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _supabase
          .from('notifications')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی اطلاع‌رسانی: $e');
    }
  }

  // حذف اطلاع‌رسانی
  Future<void> deleteNotification(String id) async {
    try {
      await _supabase.from('notifications').delete().eq('id', id);
    } catch (e) {
      throw Exception('خطا در حذف اطلاع‌رسانی: $e');
    }
  }

  // ارسال اطلاع‌رسانی
  Future<void> sendNotification(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'status': NotificationModel.statusToString(NotificationStatus.sent),
            'sent_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('خطا در ارسال اطلاع‌رسانی: $e');
    }
  }

  // زمان‌بندی اطلاع‌رسانی
  Future<void> scheduleNotification(String id, DateTime scheduledAt) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'status': NotificationModel.statusToString(
              NotificationStatus.scheduled,
            ),
            'scheduled_at': scheduledAt.toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('خطا در زمان‌بندی اطلاع‌رسانی: $e');
    }
  }

  // دریافت آمار اطلاع‌رسانی‌ها
  Future<Map<String, int>> getNotificationStats() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('is_active');

      final stats = <String, int>{};
      for (final item in response as List) {
        final isActive = item['is_active'] as bool;
        final status = isActive ? 'active' : 'inactive';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('خطا در دریافت آمار: $e');
    }
  }

  // جستجو در اطلاع‌رسانی‌ها
  Future<List<NotificationModel>> searchNotifications(String query) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .or('title.ilike.%$query%,message.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطا در جستجو: $e');
    }
  }
}
