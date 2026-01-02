import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/chat_service.dart';
import '../../../../services/ticket_service.dart';
import '../widgets/ticket_timeline_widget.dart';

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
  final String ticketTitle;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    this.ticketTitle = '',
  });

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final ChatService _chatService = ChatService();
  final TicketService _ticketService = TicketService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  TicketModel? _ticket;
  List<TicketMessage> _messages = [];
  bool _isLoadingMessages = true;
  bool _isLoadingTicket = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
    _loadMessages();
  }

  Future<void> _loadTicketDetails() async {
    try {
      final ticket = await _ticketService.getTicketById(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _isLoadingTicket = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTicket = false);
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getTicketMessages(widget.ticketId);
      if (mounted) {
        setState(() {
          _messages = messages
              .map(
                (m) => TicketMessage(
                  id: m['id'].toString(),
                  ticketId: m['ticket_id'].toString(),
                  message: m['message'] ?? '',
                  isFromUser: m['is_from_user'] ?? true,
                  timestamp: DateTime.parse(m['created_at']),
                  attachments: m['attachments'] != null
                      ? List<String>.from(m['attachments'])
                      : [],
                ),
              )
              .toList();
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && !_isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      // Optimistic update
      final tempMessage = TicketMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        ticketId: widget.ticketId,
        message: text,
        isFromUser: true,
        timestamp: DateTime.now(),
      );
      setState(() => _messages.add(tempMessage));
      _scrollToBottom();

      await _chatService.sendTicketMessage(widget.ticketId, text);

      // Refresh to get real ID and status
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در ارسال پیام: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine status name for Timeline and Colors
    final statusName = _ticket?.status.name ?? 'pending';
    final statusColor = _ticket != null
        ? _getStatusColor(_ticket!.status)
        : AppTheme.snappPrimary;
    final statusText = _ticket != null ? _ticket!.getStatusText() : '';

    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تیکت #${widget.ticketId.substring(0, 8)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (statusText.isNotEmpty)
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        backgroundColor: statusColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: _showTicketInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Timeline Widget
          TicketTimelineWidget(currentStatus: statusName),

          _buildTicketInfoHeader(statusColor, statusText),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _isLoadingMessages
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMessagesList(),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTicketInfoHeader(Color statusColor, String statusText) {
    if (_isLoadingTicket && _ticket == null) {
      return const SizedBox(height: 3, child: LinearProgressIndicator());
    }

    final title = _ticket?.title ?? widget.ticketTitle;
    final description = _ticket?.description ?? 'در حال بارگذاری جزئیات...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _ticket != null
                  ? _getStatusIcon(_ticket!.status)
                  : Icons.confirmation_number_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.snappGray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (statusText.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppTheme.snappGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'هنوز پیامی ارسال نشده است',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.snappGray),
            ),
            const SizedBox(height: 8),
            Text(
              'اولین پیام خود را ارسال کنید',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.snappGray.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(TicketMessage message) {
    return Align(
      alignment: message.isFromUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isFromUser
              ? AppTheme.snappPrimary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isFromUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: message.isFromUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: message.isFromUser ? AppTheme.snappDark : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'پیام خود را بنویسید...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isSending ? null : _sendMessage,
            backgroundColor: AppTheme.snappPrimary,
            elevation: 0,
            mini: true,
            child: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  void _showTicketInfo() {
    if (_ticket == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جزئیات تیکت',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.title, 'عنوان', _ticket!.title),
            _buildDetailRow(Icons.description, 'توضیحات', _ticket!.description),
            _buildDetailRow(Icons.category, 'سرویس', _ticket!.serviceTitle),
            _buildDetailRow(
              Icons.calendar_today,
              'تاریخ ثبت',
              _ticket!.createdAt.toString().split(' ')[0],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for Status Colors/Icons using TicketStatus Enum
  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.blue;
      case TicketStatus.processing:
        return Colors.orange;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return Colors.grey;
      case TicketStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Icons.mark_email_unread;
      case TicketStatus.processing:
        return Icons.timelapse;
      case TicketStatus.completed:
        return Icons.check_circle;
      case TicketStatus.cancelled:
        return Icons.cancel;
      case TicketStatus.rejected:
        return Icons.error;
    }
  }
}

class TicketMessage {
  final String id;
  final String ticketId;
  final String message;
  final bool isFromUser;
  final DateTime timestamp;
  final List<String> attachments;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
    this.attachments = const [],
  });
}
