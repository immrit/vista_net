import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

/// سرویس ذخیره‌سازی نشست با استفاده از Hive
class SessionStorageService {
  static const String _boxName = 'session_box';
  static const String _sessionKey = 'user_session';

  static Box? _box;

  /// اینیشیالایز Hive و باز کردن Box
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      debugPrint('[SessionStorage] ✅ Initialized successfully');
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Init error: $e');
    }
  }

  /// ذخیره نشست کاربر
  static Future<bool> saveSession(UserSession session) async {
    try {
      if (_box == null) await init();
      await _box!.put(_sessionKey, session.toMap());
      debugPrint('[SessionStorage] ✅ Session saved: ${session.userId}');
      return true;
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Save error: $e');
      return false;
    }
  }

  /// بازیابی نشست
  static Future<UserSession?> getSession() async {
    try {
      if (_box == null) await init();
      final data = _box!.get(_sessionKey);
      if (data == null) {
        debugPrint('[SessionStorage] ℹ️ No session found');
        return null;
      }
      final session = UserSession.fromMap(data);
      debugPrint('[SessionStorage] ✅ Session loaded: ${session.userId}');
      return session;
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Load error: $e');
      return null;
    }
  }

  /// بررسی وجود نشست
  static Future<bool> hasSession() async {
    try {
      if (_box == null) await init();
      return _box!.containsKey(_sessionKey);
    } catch (e) {
      return false;
    }
  }

  /// پاک کردن نشست
  static Future<void> clearSession() async {
    try {
      if (_box == null) await init();
      await _box!.delete(_sessionKey);
      debugPrint('[SessionStorage] ✅ Session cleared');
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Clear error: $e');
    }
  }

  /// بروزرسانی بخشی از نشست
  static Future<bool> updateSession({
    String? userId,
    String? phoneNumber,
    String? fullName,
    bool? isLoggedIn,
    String? refreshToken,
  }) async {
    try {
      final current = await getSession();
      if (current == null) return false;

      final updated = current.copyWith(
        userId: userId,
        phoneNumber: phoneNumber,
        fullName: fullName,
        isLoggedIn: isLoggedIn,
        refreshToken: refreshToken,
        lastLoginAt: DateTime.now(),
      );

      return await saveSession(updated);
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Update error: $e');
      return false;
    }
  }

  /// بستن Box (برای cleanup)
  static Future<void> close() async {
    try {
      await _box?.close();
      _box = null;
    } catch (e) {
      debugPrint('[SessionStorage] ❌ Close error: $e');
    }
  }
}
