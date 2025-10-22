import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/ticket_model.dart';

class TicketDetailsDialog extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailsDialog({super.key, required this.ticket});

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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(ticket.status),
                      color: _getStatusColor(ticket.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'جزئیات تیکت',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.snappDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket.status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.getStatusText(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Service Title
              _buildInfoRow(
                icon: Icons.category,
                label: 'نوع خدمت',
                value: ticket.serviceTitle,
              ),
              const Divider(height: 24),

              // Title
              _buildInfoRow(
                icon: Icons.title,
                label: 'عنوان',
                value: ticket.title,
              ),
              const Divider(height: 24),

              // Description
              _buildInfoSection(
                icon: Icons.description,
                label: 'توضیحات',
                value: ticket.description,
              ),
              const Divider(height: 24),

              // Created At
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'تاریخ ثبت',
                value: _formatDate(ticket.createdAt),
              ),

              if (ticket.updatedAt != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.update,
                  label: 'آخرین بروزرسانی',
                  value: _formatDate(ticket.updatedAt!),
                ),
              ],

              if (ticket.response != null && ticket.response!.isNotEmpty) ...[
                const Divider(height: 24),
                _buildInfoSection(
                  icon: Icons.message,
                  label: 'پاسخ',
                  value: ticket.response!,
                  valueColor: AppTheme.snappPrimary,
                ),
              ],

              const SizedBox(height: 24),

              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.snappPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'بستن',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.snappPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.snappGray),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.snappDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.snappPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.snappGray),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (valueColor ?? AppTheme.snappDark).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? AppTheme.snappDark,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
