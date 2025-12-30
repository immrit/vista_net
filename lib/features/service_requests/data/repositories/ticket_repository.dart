import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_field_model.dart';
import '../../../../models/ticket_model.dart';

class TicketRepository {
  final SupabaseClient _supabase;

  TicketRepository(this._supabase);

  // 1. Get service details (Public access usually allowed)
  Future<Service> getServiceWithFields(String serviceId) async {
    final serviceResponse = await _supabase
        .from('services')
        .select()
        .eq('id', serviceId)
        .single();

    final fieldsResponse = await _supabase
        .from('service_fields')
        .select()
        .eq('service_id', serviceId)
        .order('sort_order');

    final service = Service.fromJson(serviceResponse);
    final fields = (fieldsResponse as List)
        .map((json) => ServiceField.fromJson(json))
        .toList();

    return service.copyWith(fields: fields);
  }

  // 2. Upload file to 'ticket-attachments'
  Future<String> uploadFile(File file) async {
    try {
      final uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = 'uploads/$uniqueName';

      await _supabase.storage.from('ticket-attachments').upload(path, file);

      final publicUrl = _supabase.storage
          .from('ticket-attachments')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  // 3. Submit Ticket via RPC
  Future<String> submitTicket({
    required String userId,
    required String serviceId,
    required String title,
    required String status,
    required String statusDetail,
    required String description,
    required Map<String, dynamic> dynamicFields,
    List<String>? fileUrls,
  }) async {
    try {
      // لاگ کردن پارامترها برای دیباگ
      debugPrint(
        'Sending RPC Params: userId=$userId, desc=$description, fields=$dynamicFields',
      );

      final params = {
        'p_user_id': userId,
        'p_service_id': serviceId,
        'p_title': title,
        'p_status': status,
        'p_status_detail': statusDetail,
        'p_description': description,
        'p_dynamic_fields': dynamicFields,
      };

      // فراخوانی RPC
      final ticketId = await _supabase.rpc('create_ticket_rpc', params: params);

      // Handle File Attachments
      if (fileUrls != null && fileUrls.isNotEmpty) {
        for (final url in fileUrls) {
          try {
            await _supabase.rpc(
              'add_ticket_message_rpc',
              params: {
                'p_ticket_id': ticketId,
                'p_sender_id': userId,
                'p_content': 'فایل پیوست',
                'p_message_type': 'file',
                'p_media_url': url,
              },
            );
          } catch (e) {
            debugPrint('Error adding file attachment: $e');
          }
        }
      }

      return ticketId.toString();
    } catch (e) {
      debugPrint('RPC Error: $e');
      throw Exception('خطا در ثبت تیکت: $e');
    }
  }

  // 4. Get User Tickets via RPC
  Future<List<TicketModel>> getUserTickets(String userId) async {
    final response = await _supabase.rpc(
      'get_user_tickets',
      params: {'p_user_id': userId},
    );

    return (response as List)
        .map((json) => TicketModel.fromJson(json))
        .toList();
  }
}

// Global Provider Definition
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(Supabase.instance.client);
});
