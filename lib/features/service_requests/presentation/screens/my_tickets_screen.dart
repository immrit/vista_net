import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../config/app_theme.dart';
import '../../../../models/ticket_model.dart';
import '../../../tickets/presentation/screens/ticket_chat_screen.dart';
import '../providers/my_tickets_provider.dart';
import '../../../../widgets/shimmer_loading.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  String _searchQuery = '';
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    'پیگیری درخواست‌ها',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'جستجو در درخواست‌ها...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintStyle: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('همه', 0),
                        _buildTab('در جریان', 1),
                        _buildTab('تکمیل شده', 2),
                        _buildTab('لغو/رد شده', 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tickets List
            Expanded(
              child: ticketsAsync.when(
                data: (tickets) {
                  final filteredTickets = _filterTickets(tickets);

                  if (filteredTickets.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      return _TicketCard(ticket: filteredTickets[index]);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) => ShimmerLoading.rectangular(
                    height: 120,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'خطا در بارگذاری: $err',
                    style: const TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.snappPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.snappPrimary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Vazir',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'درخواستی یافت نشد',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }

  List<TicketModel> _filterTickets(List<TicketModel> tickets) {
    var filtered = tickets;

    // Apply Tab Filter
    if (_selectedTabIndex == 1) {
      // Pending / Processing
      filtered = filtered
          .where(
            (t) =>
                t.status == TicketStatus.pending ||
                t.status == TicketStatus.processing,
          )
          .toList();
    } else if (_selectedTabIndex == 2) {
      // Completed
      filtered = filtered
          .where((t) => t.status == TicketStatus.completed)
          .toList();
    } else if (_selectedTabIndex == 3) {
      // Rejected / Cancelled
      filtered = filtered
          .where(
            (t) =>
                t.status == TicketStatus.rejected ||
                t.status == TicketStatus.cancelled,
          )
          .toList();
    }

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.serviceTitle.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                t.id.contains(_searchQuery), // Search by ID/Tracking code
          )
          .toList();
    }

    return filtered;
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);
    // Placeholder date formatting - Replace with shamsi_date in real implementation if available
    final jalaliDate = Jalali.fromDateTime(ticket.createdAt);
    final formattedDate =
        '${jalaliDate.formatter.yyyy}/${jalaliDate.formatter.mm}/${jalaliDate.formatter.dd}';
    final formattedTime =
        '${ticket.createdAt.hour.toString().padLeft(2, '0')}:${ticket.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TicketChatScreen(
                  ticketId: ticket.id,
                  ticketTitle: ticket.title,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Service Name + Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        color: AppTheme.snappPrimary,
                        size: 20,
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
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Vazir',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'کد پیگیری: ${ticket.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _getStatusText(ticket.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // Content: Title + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontFamily: 'Vazir',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$formattedDate - $formattedTime',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'مشاهده جزئیات',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.snappPrimary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppTheme.snappPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.processing:
        return Colors.blue;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.rejected:
      case TicketStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'در انتظار بررسی';
      case TicketStatus.processing:
        return 'در حال انجام';
      case TicketStatus.completed:
        return 'تکمیل شده';
      case TicketStatus.rejected:
        return 'رد شده';
      case TicketStatus.cancelled:
        return 'لغو شده';
    }
  }
}
