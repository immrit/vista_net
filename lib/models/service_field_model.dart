enum FieldType {
  text,
  number,
  email,
  phone,
  date,
  select,
  textarea,
  file,
  checkbox,
}

class ServiceField {
  final String id;
  final String serviceId;
  final String fieldName;
  final String fieldLabel;
  final FieldType fieldType;
  final bool isRequired;
  final String? placeholder;
  final Map<String, dynamic> validationRules;
  final List<dynamic> options;
  final int sortOrder;
  final DateTime createdAt;

  ServiceField({
    required this.id,
    required this.serviceId,
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldType,
    required this.isRequired,
    this.placeholder,
    required this.validationRules,
    required this.options,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ServiceField.fromJson(Map<String, dynamic> json) {
    return ServiceField(
      id: json['id'],
      serviceId: json['service_id'],
      fieldName: json['field_name'],
      fieldLabel: json['field_label'],
      fieldType: FieldType.values.firstWhere(
        (e) => e.toString().split('.').last == json['field_type'],
        orElse: () => FieldType.text,
      ),
      isRequired: json['is_required'] ?? false,
      placeholder: json['placeholder'],
      validationRules: Map<String, dynamic>.from(
        json['validation_rules'] ?? {},
      ),
      options: List<dynamic>.from(json['options'] ?? []),
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'field_name': fieldName,
      'field_label': fieldLabel,
      'field_type': fieldType.toString().split('.').last,
      'is_required': isRequired,
      'placeholder': placeholder,
      'validation_rules': validationRules,
      'options': options,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}






