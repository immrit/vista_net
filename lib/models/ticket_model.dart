enum TicketStatus {
  pending, // در انتظار بررسی
  processing, // در حال پردازش
  completed, // تکمیل شده
  cancelled, // لغو شده
}

class TicketModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceTitle;
  final String title;
  final String description;
  final Map<String, dynamic> details;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? response;

  TicketModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.title,
    required this.description,
    required this.details,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.response,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      details: json['details'] ?? {},
      status: _statusFromString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      response: json['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'title': title,
      'description': description,
      'details': details,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'response': response,
    };
  }

  static TicketStatus _statusFromString(String? status) {
    switch (status) {
      case 'pending':
        return TicketStatus.pending;
      case 'processing':
        return TicketStatus.processing;
      case 'completed':
        return TicketStatus.completed;
      case 'cancelled':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.pending;
    }
  }

  static String _statusToString(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'pending';
      case TicketStatus.processing:
        return 'processing';
      case TicketStatus.completed:
        return 'completed';
      case TicketStatus.cancelled:
        return 'cancelled';
    }
  }

  String getStatusText() {
    switch (status) {
      case TicketStatus.pending:
        return 'در انتظار بررسی';
      case TicketStatus.processing:
        return 'در حال پردازش';
      case TicketStatus.completed:
        return 'تکمیل شده';
      case TicketStatus.cancelled:
        return 'لغو شده';
    }
  }
}
