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

  // 1. Get service details with dynamic fields
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
        .order('sort_order', ascending: true);

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

  // 3. Submit Ticket via Direct Insert (RLS handles user_id via trigger)
  Future<String> submitTicket({
    required String userId,
    required String serviceId,
    required String title,
    required String description,
    required Map<String, dynamic> dynamicFields,
    List<String>? fileUrls,
  }) async {
    try {
      debugPrint('[TicketRepository] Submitting ticket: $title');
      debugPrint(
        '[TicketRepository] Dynamic fields: ${dynamicFields.keys.toList()}',
      );

      // Direct Insert into 'tickets' table
      // Note: 'user_id' is handled by DB trigger if set up
      final response = await _supabase
          .from('tickets')
          .insert({
            'service_id': serviceId,
            'title': title,
            'status': 'open',
            'status_detail': 'submitted',
            'description': description,
            'dynamic_fields': dynamicFields,
          })
          .select('id')
          .single();

      final ticketId = response['id'] as String;
      debugPrint('[TicketRepository] Ticket created with ID: $ticketId');

      // Handle File Attachments as messages
      if (fileUrls != null && fileUrls.isNotEmpty) {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser == null) {
          debugPrint(
            '[TicketRepository] Warning: No current user for attachments',
          );
        } else {
          for (final url in fileUrls) {
            try {
              await _supabase.from('ticket_messages').insert({
                'ticket_id': ticketId,
                'sender_id': currentUser.id,
                'sender_type': 'user',
                'type': 'file',
                'message': 'فایل پیوست',
                'media_url': url,
              });
              debugPrint('[TicketRepository] Attachment added: $url');
            } catch (e) {
              debugPrint('[TicketRepository] Error adding attachment: $e');
            }
          }
        }
      }

      return ticketId;
    } catch (e) {
      debugPrint('[TicketRepository] Submit Ticket Error: $e');
      throw Exception('خطا در ثبت درخواست: $e');
    }
  }

  // 4. Get User Tickets via Direct Select
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select('*, service:services(title)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[TicketRepository] Get Tickets Error: $e');
      throw Exception('خطا در دریافت درخواست‌ها: $e');
    }
  }
}

// Global Provider Definition
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(Supabase.instance.client);
});
