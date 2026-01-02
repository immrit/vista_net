import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_theme.dart';

class AdminTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const AdminTicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<AdminTicketDetailScreen> createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState
    extends ConsumerState<AdminTicketDetailScreen> {
  bool _loading = true;
  bool _sendingMessage = false;
  Map<String, dynamic>? _ticket;
  List<Map<String, dynamic>> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  RealtimeChannel? _messagesChannel;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'open', 'label': '🔵 باز'},
    {'value': 'in_progress', 'label': '🟠 در حال انجام'},
    {'value': 'answered', 'label': '🟢 پاسخ داده شده'},
    {'value': 'closed', 'label': '⚫ بسته شده'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTicket();
    _loadMessages();
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('tickets')
          .select('*, profiles!tickets_user_id_fkey(full_name, phone_number)')
          .eq('id', widget.ticketId)
          .single();

      if (mounted) {
        setState(() {
          _ticket = response;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading ticket: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMessages() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('ticket_messages')
          .select('*')
          .eq('ticket_id', widget.ticketId)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(response);
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _subscribeToMessages() {
    final supabase = Supabase.instance.client;
    _messagesChannel = supabase
        .channel('ticket-messages-${widget.ticketId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ticket_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ticket_id',
            value: widget.ticketId,
          ),
          callback: (payload) {
            final newMessage = payload.newRecord;
            if (mounted && !_messages.any((m) => m['id'] == newMessage['id'])) {
              setState(() {
                _messages.add(newMessage);
              });
              _scrollToBottom();
            }
          },
        )
        .subscribe();
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
    if (text.isEmpty) return;

    setState(() => _sendingMessage = true);
    _messageController.clear();

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      await supabase.from('ticket_messages').insert({
        'ticket_id': widget.ticketId,
        'sender_id': user?.id,
        'is_from_user': false, // Admin message
        'message': text,
        'type': 'text',
      });

      // Also update ticket status to answered
      await supabase
          .from('tickets')
          .update({
            'status': 'answered',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.ticketId);

      if (mounted) {
        setState(() {
          _ticket?['status'] = 'answered';
        });
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ارسال پیام: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingMessage = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('tickets')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.ticketId);

      if (mounted) {
        setState(() {
          _ticket?['status'] = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('وضعیت تیکت به‌روزرسانی شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'answered':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'open':
        return 'باز';
      case 'in_progress':
        return 'در حال انجام';
      case 'answered':
        return 'پاسخ داده شده';
      case 'closed':
        return 'بسته شده';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('جزئیات تیکت')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('جزئیات تیکت')),
        body: const Center(child: Text('تیکت یافت نشد')),
      );
    }

    final profile = _ticket!['profiles'] as Map<String, dynamic>?;
    final status = _ticket!['status'] ?? 'open';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _ticket!['title'] ?? 'تیکت',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Status Dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _updateStatus,
            itemBuilder: (context) => _statusOptions.map((option) {
              return PopupMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ticket Info Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _ticket!['service_title'] ?? 'سرویس',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(profile?['full_name'] ?? 'کاربر ناشناس'),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile?['phone_number'] ?? '-',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(status).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_ticket!['description'] != null &&
                    _ticket!['description'].toString().isNotEmpty) ...[
                  const Divider(height: 20),
                  Text(
                    _ticket!['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هنوز پیامی ارسال نشده',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اولین پیام را ارسال کنید!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isAdmin = message['is_from_user'] == false;
                      return _buildMessageBubble(message, isAdmin);
                    },
                  ),
          ),

          // Message Input
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'پیام خود را بنویسید...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: _sendingMessage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendingMessage ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isAdmin) {
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAdmin ? AppTheme.snappPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 4 : 16),
            bottomRight: Radius.circular(isAdmin ? 16 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isAdmin
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              message['message'] ?? '',
              style: TextStyle(color: isAdmin ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['created_at']),
              style: TextStyle(
                fontSize: 10,
                color: isAdmin ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
