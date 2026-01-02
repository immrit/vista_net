/// Admin Constants
/// این فایل شامل ثابت‌های مربوط به ادمین است

class AdminConstants {
  // Admin User ID - Only this user gets admin access
  static const String adminUserId = '26fc3140-8611-4fa0-985a-f6b3bce7148c';

  // Admin Phone Number
  static const String adminPhoneNumber = '+989399504718';

  // Check if a user is admin
  static bool isAdmin(String? userId) {
    return userId == adminUserId;
  }

  // Check if phone is admin
  static bool isAdminPhone(String? phone) {
    if (phone == null) return false;
    // Normalize phone for comparison
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return normalized == adminPhoneNumber ||
        normalized == '09399504718' ||
        normalized == '9399504718';
  }
}
