import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_theme.dart';
import '../widgets/animated_chat_input.dart';
import '../widgets/message_bubble.dart';
import '../../presentation/providers/ticket_chat_provider.dart';
// import '../../data/models/ticket_message.dart'; // Unused import
import '../../../auth/presentation/providers/auth_provider.dart';

class TicketChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  final String ticketTitle;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.ticketTitle,
  });

  @override
  ConsumerState<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends ConsumerState<TicketChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(ticketMessagesProvider(widget.ticketId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(
        0xFF8D9CA5,
      ), // Telegram background color vibe
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.snappPrimary,
              child: const Icon(Icons.support_agent, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ticketTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'پشتیبانی آنلاین',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Menu options like "Close Ticket"
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            // Use a pattern if available, or just solid color
            image: NetworkImage(
              "https://w.wallhaven.cc/full/ey/wallhaven-eyg8mo.jpg",
            ), // Placeholder pattern from web or assets
            fit: BoxFit.cover,
            opacity: 0.1, // Subtle pattern
          ),
          color: Color(0xFFE6EBEF), // Fallback
        ),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Group messages by date? For now simplified list.
                  // We need to reverse? Usually chat lists start from bottom.
                  // But Supabase stream returns order by created_at.
                  // We can reverse in ListView or query.

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      // Determine sequence logic
                      final isFirstInSequence =
                          index == 0 ||
                          messages[index - 1].senderId != message.senderId;
                      final isLastInSequence =
                          index == messages.length - 1 ||
                          messages[index + 1].senderId != message.senderId;

                      return MessageBubble(
                        message: message,
                        isMe: message.senderId == currentUser?['id'],
                        isFirstInSequence: isFirstInSequence,
                        isLastInSequence: isLastInSequence,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('خطا در بارگذاری پیام‌ها: $err')),
              ),
            ),
            AnimatedChatInput(
              isRecording: _isRecording,
              onSendMessage: (text) {
                ref
                    .read(chatControllerProvider(widget.ticketId).notifier)
                    .sendMessage(text);
                _scrollToBottom();
              },
              onSendFile: (file, type) {
                ref
                    .read(chatControllerProvider(widget.ticketId).notifier)
                    .sendFile(file, type);
                _scrollToBottom();
              },
              onStartRecording: () {
                setState(() {
                  _isRecording = true;
                });
                // Start tracking mic
              },
              onStopRecording: () {
                setState(() {
                  _isRecording = false;
                });
                // Send captured audio
              },
              onCancelRecording: () {
                setState(() {
                  _isRecording = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    // Scroll to bottom after a slight delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'هنوز پیامی وجود ندارد.\nاولین پیام را ارسال کنید!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
