import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/ticket_message.dart';
import '../../data/repositories/chat_repository.dart';

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ChatRepository(supabase);
});

// Stream of messages for a specific ticket
final ticketMessagesProvider =
    StreamProvider.family<List<TicketMessage>, String>((ref, ticketId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.getMessages(ticketId);
    });

// Chat Controller for actions
class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repository;
  final Ref _ref;
  final String _ticketId;

  ChatController(this._repository, this._ref, this._ticketId)
    : super(const AsyncValue.data(null));

  Future<void> sendMessage(String text) async {
    final user = _ref.read(currentUserProvider);
    if (user == null || text.trim().isEmpty) return;

    state = const AsyncValue.loading();
    try {
      await _repository.sendMessage(
        ticketId: _ticketId,
        message: text,
        senderId: user['id'],
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendFile(File file, String type, {String? caption}) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      await _repository.sendFileMessage(
        ticketId: _ticketId,
        senderId: user['id'],
        file: file,
        messageType: type,
        caption: caption,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatControllerProvider =
    StateNotifierProvider.family<ChatController, AsyncValue<void>, String>((
      ref,
      ticketId,
    ) {
      final repository = ref.watch(chatRepositoryProvider);
      return ChatController(repository, ref, ticketId);
    });
