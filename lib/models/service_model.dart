class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'description',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'is_active': isActive,
    };
  }
}
