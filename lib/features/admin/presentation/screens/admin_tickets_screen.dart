import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_theme.dart';
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
      return title.contains(query) ||
          phone.contains(query) ||
          name.contains(query);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('مدیریت تیکت‌ها'),
        centerTitle: true,
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadTickets();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'جستجوی تیکت...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusOptions.map((option) {
                      final isSelected = _statusFilter == option['value'];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(option['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _statusFilter = option['value']!;
                              _loading = true;
                            });
                            _loadTickets();
                          },
                          selectedColor: AppTheme.snappPrimary.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: AppTheme.snappPrimary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تیکتی یافت نشد',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[index];
                        return _buildTicketCard(ticket);
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket['title'] ?? 'بدون عنوان',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket['service_title'] ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    profile?['full_name'] ?? 'کاربر ناشناس',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    profile?['phone_number'] ?? '-',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
