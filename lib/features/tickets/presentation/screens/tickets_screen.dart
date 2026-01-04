import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/chat_service.dart';
import '../../../../widgets/ticket_details_dialog.dart';
import '../../../../widgets/enhanced_tickets_table.dart';
import 'ticket_chat_screen.dart'; // Same directory
import '../../../support_chat/presentation/screens/support_chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main/presentation/providers/main_scaffold_provider.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  final _ticketService = TicketService();
  final _chatService = ChatService();
  List<TicketModel> _tickets = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  bool _showTableView = false;
  int _unreadSupportMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _loadUnreadSupportMessages();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);

    try {
      final tickets = await _ticketService.getUserTickets();
      setState(() {
        _tickets = tickets;
      });
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری تیکت‌ها: $e')));
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadUnreadSupportMessages() async {
    try {
      final count = await _chatService.getUnreadSupportMessagesCount();
      setState(() {
        _unreadSupportMessages = count;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  List<TicketModel> get _filteredTickets {
    if (_selectedFilter == 'all') {
      return _tickets;
    }

    final status = TicketStatus.values.firstWhere(
      (s) => s.toString().split('.').last == _selectedFilter,
      orElse: () => TicketStatus.pending,
    );

    return _tickets.where((t) => t.status == status).toList();
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.processing:
        return Colors.blue;
      case TicketStatus.completed:
        return AppTheme.snappPrimary;
      case TicketStatus.cancelled:
        return Colors.red;
      case TicketStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Icons.pending;
      case TicketStatus.processing:
        return Icons.autorenew;
      case TicketStatus.completed:
        return Icons.check_circle;
      case TicketStatus.cancelled:
        return Icons.cancel;
      case TicketStatus.rejected:
        return Icons.cancel;
    }
  }

  void _showTicketDetails(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => TicketDetailsDialog(ticket: ticket),
    );
  }

  void _navigateToChat(TicketModel ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TicketChatScreen(ticketId: ticket.id, ticketTitle: ticket.title),
      ),
    );
  }

  void _navigateToSupportChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SupportChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _filteredTickets;

    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text(
          'تیکت‌ها و پشتیبانی',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _showTableView
                    ? Icons.view_list_rounded
                    : Icons.table_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _showTableView = !_showTableView;
                });
              },
              tooltip: _showTableView ? 'نمایش لیستی' : 'نمایش جدولی',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  ref
                      .read(mainScaffoldKeyProvider)
                      .currentState
                      ?.openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
      // endDrawer: const HamburgerMenu(),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('همه', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('در انتظار', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('در حال پردازش', 'processing'),
                  const SizedBox(width: 8),
                  _buildFilterChip('تکمیل شده', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('لغو شده', 'cancelled'),
                  const SizedBox(width: 8),
                  _buildFilterChip('رد شده', 'rejected'),
                ],
              ),
            ),
          ),

          // Support Chat Card
          if (!_showTableView)
            Container(
              margin: const EdgeInsets.all(16),
              child: _buildSupportChatCard(),
            ),

          // Tickets List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTickets.isEmpty
                ? _buildEmptyState()
                : _showTableView
                ? _buildTableView(filteredTickets)
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    color: AppTheme.snappPrimary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(filteredTickets[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppTheme.snappPrimary,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.snappDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppTheme.snappGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'هنوز تیکتی ثبت نکرده‌اید',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.snappGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'از بخش خدمات، درخواست خود را ثبت کنید',
            style: TextStyle(fontSize: 14, color: AppTheme.snappGray),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToChat(ticket),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        ticket.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(ticket.status),
                      size: 20,
                      color: _getStatusColor(ticket.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.serviceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.snappDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket.status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.getStatusText(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.chat_rounded,
                            color: AppTheme.snappPrimary,
                            size: 20,
                          ),
                          onPressed: () => _navigateToChat(ticket),
                          tooltip: 'چت با پشتیبانی',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.snappGray,
                          size: 20,
                        ),
                        onPressed: () => _showTicketDetails(ticket),
                        tooltip: 'جزئیات تیکت',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.description,
                style: TextStyle(fontSize: 14, color: AppTheme.snappGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppTheme.snappGray),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: TextStyle(fontSize: 12, color: AppTheme.snappGray),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'امروز ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'دیروز';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} روز پیش';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  Widget _buildSupportChatCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToSupportChat,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'چت با پشتیبانی',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سوالات خود را از پشتیبان بپرسید',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_unreadSupportMessages > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _unreadSupportMessages.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableView(List<TicketModel> tickets) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: EnhancedTicketsTable(
        tickets: tickets,
        onTicketTap: _showTicketDetails,
        onStatusChange: (status) {
          // تغییر وضعیت تیکت
          debugPrint('تغییر وضعیت به: $status');
        },
        showActions: true,
      ),
    );
  }
}
