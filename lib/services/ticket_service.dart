import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import '../models/service_model.dart';

class TicketService {
  final _supabase = Supabase.instance.client;

  // Get all available services
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select()
          .eq('is_active', true)
          .order('title');

      final services = (response as List)
          .map((json) => ServiceModel.fromJson(json))
          .toList();

      return services;
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  // Create a new ticket
  Future<Map<String, dynamic>> createTicket({
    required String userId,
    required String serviceId,
    required String serviceTitle,
    required String title,
    required String description,
    required Map<String, dynamic> details,
  }) async {
    try {
      final ticketData = {
        'user_id': userId,
        'service_id': serviceId,
        'service_title': serviceTitle,
        'title': title,
        'description': description,
        'details': details,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('tickets')
          .insert(ticketData)
          .select()
          .single();

      return {
        'success': true,
        'message': 'درخواست شما با موفقیت ثبت شد',
        'ticket': TicketModel.fromJson(response),
      };
    } catch (e) {
      print('Error creating ticket: $e');
      return {'success': false, 'message': 'خطا در ثبت درخواست'};
    }
  }

  // Get user tickets
  Future<List<TicketModel>> getUserTickets(String userId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final tickets = (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();

      return tickets;
    } catch (e) {
      print('Error fetching tickets: $e');
      return [];
    }
  }

  // Get ticket by ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .single();

      return TicketModel.fromJson(response);
    } catch (e) {
      print('Error fetching ticket: $e');
      return null;
    }
  }

  // Update ticket status
  Future<bool> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      String statusString;
      switch (status) {
        case TicketStatus.pending:
          statusString = 'pending';
          break;
        case TicketStatus.processing:
          statusString = 'processing';
          break;
        case TicketStatus.completed:
          statusString = 'completed';
          break;
        case TicketStatus.cancelled:
          statusString = 'cancelled';
          break;
      }

      await _supabase
          .from('tickets')
          .update({
            'status': statusString,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId);

      return true;
    } catch (e) {
      print('Error updating ticket status: $e');
      return false;
    }
  }

  // Cancel ticket
  Future<bool> cancelTicket(String ticketId) async {
    return await updateTicketStatus(ticketId, TicketStatus.cancelled);
  }
}
