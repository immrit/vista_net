import 'dart:io';
import 'dart:typed_data';
import '../config/app_config.dart';

class ArvanUploadService {
  // آپلود تصویر
  static Future<String> uploadImage(
    File imageFile,
    String folder, {
    String? customFileName,
  }) async {
    // TODO: پیاده‌سازی آپلود به آروان کلود
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی آپلود
    return 'https://example.com/uploaded-image.jpg';
  }

  // آپلود فایل
  static Future<String> uploadFile(
    File file,
    String folder, {
    String? customFileName,
  }) async {
    // TODO: پیاده‌سازی آپلود به آروان کلود
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی آپلود
    return 'https://example.com/uploaded-file.pdf';
  }

  // آپلود فایل از بایت‌ها
  static Future<String> uploadFileFromBytes(
    Uint8List bytes,
    String fileName,
    String folder,
    String contentType,
  ) async {
    // TODO: پیاده‌سازی آپلود به آروان کلود
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی آپلود
    return 'https://example.com/uploaded-file.pdf';
  }

  // حذف فایل
  static Future<void> deleteFile(String fileUrl) async {
    // TODO: پیاده‌سازی حذف از آروان کلود
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی حذف
  }

  // بررسی اعتبار فایل
  static bool isValidImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return AppConfig.allowedImageTypes.contains(extension);
  }

  static bool isValidDocumentFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return AppConfig.allowedDocumentTypes.contains(extension);
  }

  // بررسی اندازه فایل
  static bool isValidFileSize(int fileSizeInBytes) {
    final maxSizeInBytes = AppConfig.maxFileSizeMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }
}
