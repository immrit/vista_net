/// مدل نشست کاربر برای ذخیره‌سازی در Hive
class UserSession {
  final String id;
  final String? userId;
  final String? phoneNumber;
  final String? fullName;
  final bool isLoggedIn;
  final DateTime? lastLoginAt;
  final String? refreshToken;

  UserSession({
    required this.id,
    this.userId,
    this.phoneNumber,
    this.fullName,
    this.isLoggedIn = false,
    this.lastLoginAt,
    this.refreshToken,
  });

  /// تبدیل به Map برای ذخیره در Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'isLoggedIn': isLoggedIn,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'refreshToken': refreshToken,
    };
  }

  /// ساخت از Map
  factory UserSession.fromMap(Map<dynamic, dynamic> map) {
    return UserSession(
      id: map['id'] ?? 'default',
      userId: map['userId'],
      phoneNumber: map['phoneNumber'],
      fullName: map['fullName'],
      isLoggedIn: map['isLoggedIn'] ?? false,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.tryParse(map['lastLoginAt'])
          : null,
      refreshToken: map['refreshToken'],
    );
  }

  /// کپی با مقادیر جدید
  UserSession copyWith({
    String? id,
    String? userId,
    String? phoneNumber,
    String? fullName,
    bool? isLoggedIn,
    DateTime? lastLoginAt,
    String? refreshToken,
  }) {
    return UserSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  /// نشست خالی
  factory UserSession.empty() {
    return UserSession(id: 'empty', isLoggedIn: false);
  }

  @override
  String toString() {
    return 'UserSession(userId: $userId, phone: $phoneNumber, loggedIn: $isLoggedIn)';
  }
}
