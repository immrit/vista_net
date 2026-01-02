class UserDocument {
  final String id;
  final String userId;
  final String title;
  final String fileUrl;
  final String fileType;
  final DateTime createdAt;
  final int sizeBytes;

  UserDocument({
    required this.id,
    required this.userId,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.createdAt,
    this.sizeBytes = 0,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      fileUrl: json['file_url'],
      fileType: json['file_type'] ?? 'unknown',
      createdAt: DateTime.parse(json['created_at']),
      sizeBytes: json['size_bytes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'file_url': fileUrl,
      'file_type': fileType,
      'created_at': createdAt.toIso8601String(),
      'size_bytes': sizeBytes,
    };
  }
}
