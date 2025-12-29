import 'package:flutter/material.dart';
import '../models/ticket_model.dart';

class EnhancedTicketsTable extends StatefulWidget {
  final List<TicketModel> tickets;
  final Function(TicketModel)? onTicketTap;
  final Function(String)? onStatusChange;
  final bool showActions;

  const EnhancedTicketsTable({
    super.key,
    required this.tickets,
    this.onTicketTap,
    this.onStatusChange,
    this.showActions = true,
  });

  @override
  State<EnhancedTicketsTable> createState() => _EnhancedTicketsTableState();
}

class _EnhancedTicketsTableState extends State<EnhancedTicketsTable> {
  String _sortColumn = 'created_at';
  bool _sortAscending = false;
  String _searchQuery = '';
  String _statusFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  List<TicketModel> get _filteredTickets {
    List<TicketModel> filtered = widget.tickets;

    // فیلتر جستجو
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (ticket) =>
                ticket.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                ticket.serviceTitle.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (ticket.nationalId?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // فیلتر وضعیت
    if (_statusFilter != 'all') {
      final status = TicketStatus.values.firstWhere(
        (s) => s.toString().split('.').last == _statusFilter,
        orElse: () => TicketStatus.pending,
      );
      filtered = filtered.where((ticket) => ticket.status == status).toList();
    }

    // مرتب‌سازی
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortColumn) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'service_title':
          comparison = a.serviceTitle.compareTo(b.serviceTitle);
          break;
        case 'status':
          comparison = a.status.toString().compareTo(b.status.toString());
          break;
        case 'created_at':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          // هدر جدول با جستجو و فیلتر
          _buildTableHeader(),

          // محتوای جدول
          Expanded(
            child: _filteredTickets.isEmpty
                ? _buildEmptyState()
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // نوار جستجو و فیلتر
          Row(
            children: [
              // جستجو
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'جستجو در تیکت‌ها...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              // فیلتر وضعیت
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _statusFilter,
                  decoration: InputDecoration(
                    labelText: 'وضعیت',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('همه')),
                    const DropdownMenuItem(
                      value: 'pending',
                      child: Text('در انتظار'),
                    ),
                    const DropdownMenuItem(
                      value: 'processing',
                      child: Text('در حال پردازش'),
                    ),
                    const DropdownMenuItem(
                      value: 'completed',
                      child: Text('تکمیل شده'),
                    ),
                    const DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('لغو شده'),
                    ),
                    const DropdownMenuItem(
                      value: 'rejected',
                      child: Text('رد شده'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value ?? 'all';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // آمار
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalTickets = widget.tickets.length;
    final pendingTickets = widget.tickets
        .where((t) => t.status == TicketStatus.pending)
        .length;
    final processingTickets = widget.tickets
        .where((t) => t.status == TicketStatus.processing)
        .length;
    final completedTickets = widget.tickets
        .where((t) => t.status == TicketStatus.completed)
        .length;

    return Row(
      children: [
        _buildStatItem('کل', totalTickets, Colors.blue),
        const SizedBox(width: 16),
        _buildStatItem('در انتظار', pendingTickets, Colors.orange),
        const SizedBox(width: 16),
        _buildStatItem('در حال پردازش', processingTickets, Colors.blue),
        const SizedBox(width: 16),
        _buildStatItem('تکمیل شده', completedTickets, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'تیکتی یافت نشد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هیچ تیکتی با این فیلترها یافت نشد',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
        columns: [
          _buildDataColumn('عنوان', 'title'),
          _buildDataColumn('خدمت', 'service_title'),
          _buildDataColumn('وضعیت', 'status'),
          _buildDataColumn('تاریخ ایجاد', 'created_at'),
          if (widget.showActions) const DataColumn(label: Text('عملیات')),
        ],
        rows: _filteredTickets.map((ticket) => _buildDataRow(ticket)).toList(),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, String columnId) {
    final isSorted = _sortColumn == columnId;

    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (isSorted)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Colors.blue,
            ),
        ],
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnId;
          _sortAscending = ascending;
        });
      },
    );
  }

  DataRow _buildDataRow(TicketModel ticket) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              ticket.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              ticket.serviceTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(_buildStatusChip(ticket.status)),
        DataCell(
          Text(
            _formatDate(ticket.createdAt),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        if (widget.showActions)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16),
                  onPressed: () => widget.onTicketTap?.call(ticket),
                  tooltip: 'مشاهده جزئیات',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, ticket),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'change_status',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('تغییر وضعیت'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 16),
                          SizedBox(width: 8),
                          Text('جزئیات'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(TicketStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
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
      case TicketStatus.cancelled:
        return Colors.red;
      case TicketStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'در انتظار';
      case TicketStatus.processing:
        return 'در حال پردازش';
      case TicketStatus.completed:
        return 'تکمیل شده';
      case TicketStatus.cancelled:
        return 'لغو شده';
      case TicketStatus.rejected:
        return 'رد شده';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, TicketModel ticket) {
    switch (action) {
      case 'change_status':
        _showStatusChangeDialog(ticket);
        break;
      case 'view_details':
        widget.onTicketTap?.call(ticket);
        break;
    }
  }

  void _showStatusChangeDialog(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغییر وضعیت تیکت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TicketStatus.values.map((status) {
            return RadioListTile<TicketStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: ticket.status,
              onChanged: (value) {
                if (value != null) {
                  widget.onStatusChange?.call(value.toString().split('.').last);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
