import 'service_field_model.dart';

class Service {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String icon;
  final bool isActive;

  // تنظیمات خاص هر خدمت
  final bool requiresDocuments;
  final bool requiresNationalId;
  final bool requiresPersonalCode;
  final bool requiresPhoneVerification;
  final bool requiresAddress;
  final bool requiresBirthDate;

  // تنظیمات فایل
  final int maxFileSizeMb;
  final List<String> allowedFileTypes;
  final int maxFilesCount;

  // تنظیمات زمان و هزینه
  final int processingTimeDays;
  final double costAmount;
  final bool isPaidService;

  // فیلدهای پویا
  final List<dynamic> customFields;
  final Map<String, dynamic> validationRules;
  final Map<String, dynamic> formConfig;

  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  // فیلدهای پویا از جدول جداگانه
  final List<ServiceField> fields;

  Service({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.icon,
    required this.isActive,
    required this.requiresDocuments,
    required this.requiresNationalId,
    required this.requiresPersonalCode,
    required this.requiresPhoneVerification,
    required this.requiresAddress,
    required this.requiresBirthDate,
    required this.maxFileSizeMb,
    required this.allowedFileTypes,
    required this.maxFilesCount,
    required this.processingTimeDays,
    required this.costAmount,
    required this.isPaidService,
    required this.customFields,
    required this.validationRules,
    required this.formConfig,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.fields = const [],
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'] ?? 'description',
      isActive: json['is_active'] ?? true,
      requiresDocuments: json['requires_documents'] ?? false,
      requiresNationalId: json['requires_national_id'] ?? false,
      requiresPersonalCode: json['requires_personal_code'] ?? false,
      requiresPhoneVerification: json['requires_phone_verification'] ?? false,
      requiresAddress: json['requires_address'] ?? false,
      requiresBirthDate: json['requires_birth_date'] ?? false,
      maxFileSizeMb: json['max_file_size_mb'] ?? 10,
      allowedFileTypes: List<String>.from(
        json['allowed_file_types'] ?? ['pdf', 'jpg', 'png'],
      ),
      maxFilesCount: json['max_files_count'] ?? 5,
      processingTimeDays: json['processing_time_days'] ?? 3,
      costAmount: (json['cost_amount'] ?? 0).toDouble(),
      isPaidService: json['is_paid_service'] ?? false,
      customFields: List<dynamic>.from(json['custom_fields'] ?? []),
      validationRules: Map<String, dynamic>.from(
        json['validation_rules'] ?? {},
      ),
      formConfig: Map<String, dynamic>.from(json['form_config'] ?? {}),
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'requires_documents': requiresDocuments,
      'requires_national_id': requiresNationalId,
      'requires_personal_code': requiresPersonalCode,
      'requires_phone_verification': requiresPhoneVerification,
      'requires_address': requiresAddress,
      'requires_birth_date': requiresBirthDate,
      'max_file_size_mb': maxFileSizeMb,
      'allowed_file_types': allowedFileTypes,
      'max_files_count': maxFilesCount,
      'processing_time_days': processingTimeDays,
      'cost_amount': costAmount,
      'is_paid_service': isPaidService,
      'custom_fields': customFields,
      'validation_rules': validationRules,
      'form_config': formConfig,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Service copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? description,
    String? icon,
    bool? isActive,
    bool? requiresDocuments,
    bool? requiresNationalId,
    bool? requiresPersonalCode,
    bool? requiresPhoneVerification,
    bool? requiresAddress,
    bool? requiresBirthDate,
    int? maxFileSizeMb,
    List<String>? allowedFileTypes,
    int? maxFilesCount,
    int? processingTimeDays,
    double? costAmount,
    bool? isPaidService,
    List<dynamic>? customFields,
    Map<String, dynamic>? validationRules,
    Map<String, dynamic>? formConfig,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ServiceField>? fields,
  }) {
    return Service(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      requiresDocuments: requiresDocuments ?? this.requiresDocuments,
      requiresNationalId: requiresNationalId ?? this.requiresNationalId,
      requiresPersonalCode: requiresPersonalCode ?? this.requiresPersonalCode,
      requiresPhoneVerification:
          requiresPhoneVerification ?? this.requiresPhoneVerification,
      requiresAddress: requiresAddress ?? this.requiresAddress,
      requiresBirthDate: requiresBirthDate ?? this.requiresBirthDate,
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      maxFilesCount: maxFilesCount ?? this.maxFilesCount,
      processingTimeDays: processingTimeDays ?? this.processingTimeDays,
      costAmount: costAmount ?? this.costAmount,
      isPaidService: isPaidService ?? this.isPaidService,
      customFields: customFields ?? this.customFields,
      validationRules: validationRules ?? this.validationRules,
      formConfig: formConfig ?? this.formConfig,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fields: fields ?? this.fields,
    );
  }
}
