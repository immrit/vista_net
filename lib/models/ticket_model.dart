enum TicketStatus {
  pending, // در انتظار بررسی
  processing, // در حال پردازش
  completed, // تکمیل شده
  cancelled, // لغو شده
  rejected, // رد شده
}

class TicketModel {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceTitle;
  final String title;
  final String description;

  // فیلدهای خاص درخواست
  final String? nationalId;
  final String? personalCode;
  final String? address;
  final DateTime? birthDate;

  // فایل‌های آپلود شده
  final List<Map<String, dynamic>> uploadedFiles;

  // فیلدهای پویا
  final Map<String, dynamic> dynamicFields;

  // جزئیات درخواست
  final Map<String, dynamic> details;
  final TicketStatus status;

  // پاسخ و پیگیری
  final String? response;
  final String? adminNotes;
  final String? assignedTo;

  // زمان‌بندی
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? dueDate;

  TicketModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.title,
    required this.description,
    this.nationalId,
    this.personalCode,
    this.address,
    this.birthDate,
    required this.uploadedFiles,
    required this.dynamicFields,
    required this.details,
    required this.status,
    this.response,
    this.adminNotes,
    this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.dueDate,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      serviceId: json['service_id'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      nationalId: json['national_id'],
      personalCode: json['personal_code'],
      address: json['address'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      uploadedFiles: List<Map<String, dynamic>>.from(
        json['uploaded_files'] ?? [],
      ),
      dynamicFields: Map<String, dynamic>.from(json['dynamic_fields'] ?? {}),
      details: json['details'] ?? {},
      status: _statusFromString(json['status']),
      response: json['response'],
      adminNotes: json['admin_notes'],
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
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
      'national_id': nationalId,
      'personal_code': personalCode,
      'address': address,
      'birth_date': birthDate?.toIso8601String(),
      'uploaded_files': uploadedFiles,
      'dynamic_fields': dynamicFields,
      'details': details,
      'status': _statusToString(status),
      'response': response,
      'admin_notes': adminNotes,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
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
      case 'rejected':
        return TicketStatus.rejected;
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
      case TicketStatus.rejected:
        return 'rejected';
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
      case TicketStatus.rejected:
        return 'رد شده';
    }
  }
}
