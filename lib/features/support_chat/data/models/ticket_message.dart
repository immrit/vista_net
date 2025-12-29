class TicketMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'voice', 'file'
  final DateTime createdAt;
  final bool isAdmin;
  final String? mediaUrl;
  final Map<String, dynamic>? metadata;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isAdmin,
    this.mediaUrl,
    this.metadata,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isAdmin: json['is_admin'] ?? false,
      mediaUrl: json['media_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_admin': isAdmin,
      'media_url': mediaUrl,
      'metadata': metadata,
    };
  }
}
