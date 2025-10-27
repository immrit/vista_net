import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ارسال پیام پشتیبانی
  Future<void> sendSupportMessage(
    String message, {
    List<String>? attachments,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      await _supabase.from('support_messages').insert({
        'user_id': user.id,
        'message': message,
        'is_from_user': true,
        'attachments': attachments ?? [],
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('خطا در ارسال پیام پشتیبانی: $e');
    }
  }

  // دریافت پیام‌های پشتیبانی
  Future<List<Map<String, dynamic>>> getSupportMessages() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      final response = await _supabase
          .from('support_messages')
          .select()
          .eq('user_id', user.id)
          .order('created_at');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('خطا در دریافت پیام‌های پشتیبانی: $e');
    }
  }

  // ارسال پیام تیکت
  Future<void> sendTicketMessage(
    String ticketId,
    String message, {
    List<String>? attachments,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // بررسی اینکه تیکت متعلق به کاربر است
      final ticketResponse = await _supabase
          .from('tickets')
          .select('user_id')
          .eq('id', ticketId)
          .single();

      if (ticketResponse['user_id'] != user.id) {
        throw Exception('شما دسترسی به این تیکت ندارید');
      }

      await _supabase.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'message': message,
        'is_from_user': true,
        'attachments': attachments ?? [],
      });
    } catch (e) {
      throw Exception('خطا در ارسال پیام تیکت: $e');
    }
  }

  // دریافت پیام‌های تیکت
  Future<List<Map<String, dynamic>>> getTicketMessages(String ticketId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // بررسی اینکه تیکت متعلق به کاربر است
      final ticketResponse = await _supabase
          .from('tickets')
          .select('user_id')
          .eq('id', ticketId)
          .single();

      if (ticketResponse['user_id'] != user.id) {
        throw Exception('شما دسترسی به این تیکت ندارید');
      }

      final response = await _supabase
          .from('ticket_messages')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('خطا در دریافت پیام‌های تیکت: $e');
    }
  }

  // به‌روزرسانی وضعیت پیام‌های پشتیبانی
  Future<void> markSupportMessagesAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      await _supabase
          .from('support_messages')
          .update({'status': 'read'})
          .eq('user_id', user.id)
          .eq('is_from_user', false)
          .eq('status', 'pending');
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی وضعیت پیام‌ها: $e');
    }
  }

  // دریافت تعداد پیام‌های خوانده نشده
  Future<int> getUnreadSupportMessagesCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('support_messages')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_from_user', false)
          .eq('status', 'pending');

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}


