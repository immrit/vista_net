import 'package:flutter/material.dart';

enum NotificationPriority { low, medium, high, urgent }

enum NotificationStatus { draft, scheduled, sent, failed }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String? createdBy;
  final Map<String, dynamic> metadata;
  final List<String> targetUsers; // خالی = همه کاربران
  final bool isActive;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.priority,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
    this.sentAt,
    this.createdBy,
    required this.metadata,
    required this.targetUsers,
    required this.isActive,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['image_url'],
      priority: priorityFromString(json['priority']),
      status: statusFromString(
        json['status'],
      ), // اگر status وجود نداشته باشد، default به draft تنظیم می‌شود
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      createdBy: json['created_by'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      targetUsers: List<String>.from(json['target_users'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'image_url': imageUrl,
      'priority': priorityToString(priority),
      'status': statusToString(status),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'created_by': createdBy,
      'metadata': metadata,
      'target_users': targetUsers,
      'is_active': isActive,
    };
  }

  static NotificationPriority priorityFromString(String? priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'medium':
        return NotificationPriority.medium;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.medium;
    }
  }

  static String priorityToString(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.medium:
        return 'medium';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.urgent:
        return 'urgent';
    }
  }

  static NotificationStatus statusFromString(String? status) {
    switch (status) {
      case 'draft':
        return NotificationStatus.draft;
      case 'scheduled':
        return NotificationStatus.scheduled;
      case 'sent':
        return NotificationStatus.sent;
      case 'failed':
        return NotificationStatus.failed;
      default:
        return NotificationStatus.draft;
    }
  }

  static String statusToString(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.draft:
        return 'draft';
      case NotificationStatus.scheduled:
        return 'scheduled';
      case NotificationStatus.sent:
        return 'sent';
      case NotificationStatus.failed:
        return 'failed';
    }
  }

  String getPriorityText() {
    switch (priority) {
      case NotificationPriority.low:
        return 'کم';
      case NotificationPriority.medium:
        return 'متوسط';
      case NotificationPriority.high:
        return 'زیاد';
      case NotificationPriority.urgent:
        return 'فوری';
    }
  }

  String getStatusText() {
    switch (status) {
      case NotificationStatus.draft:
        return 'پیش‌نویس';
      case NotificationStatus.scheduled:
        return 'زمان‌بندی شده';
      case NotificationStatus.sent:
        return 'ارسال شده';
      case NotificationStatus.failed:
        return 'ناموفق';
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case NotificationStatus.draft:
        return Colors.grey;
      case NotificationStatus.scheduled:
        return Colors.blue;
      case NotificationStatus.sent:
        return Colors.green;
      case NotificationStatus.failed:
        return Colors.red;
    }
  }
}
