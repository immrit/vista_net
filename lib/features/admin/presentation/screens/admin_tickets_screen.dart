import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_theme.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'admin_ticket_detail_screen.dart';

class AdminTicketsScreen extends ConsumerStatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  ConsumerState<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends ConsumerState<AdminTicketsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tickets = [];
  String _searchQuery = '';
  String _statusFilter = 'all';

  final List<Map<String, String>> _statusOptions = [
    {'value': 'all', 'label': 'همه'},
    {'value': 'open', 'label': 'باز'},
    {'value': 'in_progress', 'label': 'در حال انجام'},
    {'value': 'answered', 'label': 'پاسخ داده شده'},
    {'value': 'closed', 'label': 'بسته شده'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final supabase = Supabase.instance.client;

      List<dynamic> response;
      if (_statusFilter != 'all') {
        response = await supabase
            .from('tickets')
            .select('*, profiles!tickets_user_id_fkey(full_name, phone_number)')
            .eq('status', _statusFilter)
            .order('created_at', ascending: false);
      } else {
        response = await supabase
            .from('tickets')
            .select('*, profiles!tickets_user_id_fkey(full_name, phone_number)')
            .order('created_at', ascending: false);
      }

      if (mounted) {
        setState(() {
          _tickets = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTickets {
    if (_searchQuery.isEmpty) return _tickets;
    final query = _searchQuery.toLowerCase();
    return _tickets.where((t) {
      final title = (t['title'] ?? '').toString().toLowerCase();
      final phone = (t['profiles']?['phone_number'] ?? '').toString();
      final name = (t['profiles']?['full_name'] ?? '').toString().toLowerCase();
      final id = (t['id'] ?? '').toString().toLowerCase();
      return title.contains(query) ||
          phone.contains(query) ||
          name.contains(query) ||
          id.contains(query);
    }).toList();
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
      case 'pending':
        return Colors.amber;
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
      case 'pending':
        return 'در انتظار';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text('مدیریت تیکت‌ها'),
        centerTitle: true,
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadTickets();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'جستجو در تیکت‌ها...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusOptions.map((option) {
                      final isSelected = _statusFilter == option['value'];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(
                            option['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontFamily: 'Vazir',
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _statusFilter = option['value']!;
                                _loading = true;
                              });
                              _loadTickets();
                            }
                          },
                          selectedColor: AppTheme.snappPrimary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.snappPrimary
                                : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.snappPrimary,
                    ),
                  )
                : _filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'موردی یافت نشد',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontFamily: 'Vazir',
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _filteredTickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(_filteredTickets[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'open';
    final statusColor = _getStatusColor(status);
    final profile = ticket['profiles'] as Map<String, dynamic>?;
    String date = '-';
    if (ticket['created_at'] != null) {
      final dt = DateTime.parse(ticket['created_at']).toLocal();
      final jalali = Jalali.fromDateTime(dt);
      date =
          '${jalali.formatter.yyyy}/${jalali.formatter.mm}/${jalali.formatter.dd}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminTicketDetailScreen(ticketId: ticket['id']),
              ),
            ).then((_) => _loadTickets());
          },
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
                        color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
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
                            ticket['service_title'] ?? 'خدمت نامشخص',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: 'Vazir',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket['title'] ?? 'بدون عنوان',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Vazir',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _getStatusLabel(status),
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

                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      profile?['full_name'] ?? 'کاربر ناشناس',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ],
                      ),
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
}
