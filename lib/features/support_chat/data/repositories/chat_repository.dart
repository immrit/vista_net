import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_message.dart';

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository(this._supabase);

  // Stream of messages for a specific ticket
  Stream<List<TicketMessage>> getMessages(String ticketId) {
    return _supabase
        .from('ticket_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map(
          (data) => data.map((json) => TicketMessage.fromJson(json)).toList(),
        );
  }

  // Send a text message
  Future<void> sendMessage({
    required String ticketId,
    required String message,
    required String senderId,
    bool isAdmin = false,
  }) async {
    // Check for Super Admin
    final isSuperAdmin = senderId == '26fc3140-8611-4fa0-985a-f6b3bce7148c';

    await _supabase.from('ticket_messages').insert({
      'ticket_id': ticketId,
      'sender_id': senderId,
      'content': message,
      'type': 'text',
      'is_admin': isAdmin || isSuperAdmin,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Send a file message (image, voice, etc.)
  Future<void> sendFileMessage({
    required String ticketId,
    required String senderId,
    required File file,
    required String messageType, // 'image', 'voice', 'file'
    String? caption,
  }) async {
    try {
      // 1. Upload file to storage
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}_$senderId.$fileExt';
      final filePath = '$ticketId/$fileName';

      await _supabase.storage.from('chat_attachments').upload(filePath, file);

      final publicUrl = _supabase.storage
          .from('chat_attachments')
          .getPublicUrl(filePath);

      // Check for Super Admin
      final isSuperAdmin = senderId == '26fc3140-8611-4fa0-985a-f6b3bce7148c';

      // 2. Insert message record
      await _supabase.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'sender_id': senderId,
        'content': caption ?? '',
        'type': messageType,
        'is_admin': isSuperAdmin, // Default to false unless Super Admin
        'media_url': publicUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error sending file message: $e');
    }
  }
}
