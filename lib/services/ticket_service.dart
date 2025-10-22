import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';

class TicketService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ایجاد تیکت جدید
  Future<TicketModel> createTicket({
    required String serviceId,
    required String serviceTitle,
    required String title,
    required String description,
    String? nationalId,
    String? personalCode,
    String? address,
    DateTime? birthDate,
    Map<String, dynamic>? dynamicFields,
    Map<String, dynamic>? details,
    List<Map<String, dynamic>>? uploadedFiles,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      final response = await _supabase
          .from('tickets')
          .insert({
            'user_id': user.id,
            'service_id': serviceId,
            'service_title': serviceTitle,
            'title': title,
            'description': description,
            'national_id': nationalId,
            'personal_code': personalCode,
            'address': address,
            'birth_date': birthDate?.toIso8601String(),
            'dynamic_fields': dynamicFields ?? {},
            'details': details ?? {},
            'uploaded_files': uploadedFiles ?? [],
            'status': 'pending',
          })
          .select()
          .single();

      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در ایجاد تیکت: $e');
    }
  }

  // دریافت تیکت‌های کاربر
  Future<List<TicketModel>> getUserTickets() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      final response = await _supabase
          .from('tickets')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطا در دریافت تیکت‌ها: $e');
    }
  }

  // دریافت جزئیات یک تیکت
  Future<TicketModel> getTicketById(String ticketId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      final response = await _supabase
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .eq('user_id', user.id)
          .single();

      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در دریافت تیکت: $e');
    }
  }

  // به‌روزرسانی وضعیت تیکت
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      await _supabase
          .from('tickets')
          .update({'status': status})
          .eq('id', ticketId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی تیکت: $e');
    }
  }

  // لغو تیکت
  Future<void> cancelTicket(String ticketId) async {
    await updateTicketStatus(ticketId, 'cancelled');
  }

  // آپلود فایل
  Future<String> uploadFile(
    String ticketId,
    String fieldName,
    String fileName,
    List<int> fileBytes,
    String fileType,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('کاربر وارد نشده است');
      }

      // آپلود فایل به Supabase Storage
      final filePath = 'tickets/$ticketId/$fieldName/$fileName';
      await _supabase.storage
          .from('ticket-files')
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      // دریافت URL فایل
      final fileUrl = _supabase.storage
          .from('ticket-files')
          .getPublicUrl(filePath);

      // ذخیره اطلاعات فایل در دیتابیس
      await _supabase.from('uploaded_files').insert({
        'ticket_id': ticketId,
        'field_name': fieldName,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileBytes.length,
        'file_type': fileType,
        'uploaded_by': user.id,
      });

      return fileUrl;
    } catch (e) {
      throw Exception('خطا در آپلود فایل: $e');
    }
  }
}
