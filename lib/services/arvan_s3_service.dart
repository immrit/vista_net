import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as path;

class ArvanCloudService {
  static const String _bucketName = 'vista-net';
  static const String _endPoint = 's3.ir-thr-at1.arvanstorage.ir';
  static const String _accessKey = '4f4716fb-fa84-4ae7-9c8b-34d2a0896cdf';
  static const String _secretKey =
      'a6b4db27b4c54bfa46cbc4fd8a4ba2079e2da0cd2800acdc80dd758f8b2c1ec5';

  late final Minio _minio;

  ArvanCloudService() {
    _minio = Minio(
      endPoint: _endPoint,
      accessKey: _accessKey,
      secretKey: _secretKey,
      useSSL: true,
    );
  }

  /// Uploads a file to ArvanCloud and returns the public URL.
  ///
  /// [file] is the file to upload.
  /// [folder] is the folder path ('chat', 'services', etc.).
  Future<String> uploadFile(File file, {String folder = 'uploads'}) async {
    try {
      final fileName = path.basename(file.path);
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final objectKey = '$folder/$uniqueName';

      // Read file bytes and convert to Uint8List stream for Minio
      final stream = file.openRead().map((chunk) => Uint8List.fromList(chunk));
      final length = await file.length();

      await _minio.putObject(_bucketName, objectKey, stream, size: length);

      // Return public URL
      // Arvan public URL format: https://bucket.endpoint/key
      return 'https://$_bucketName.$_endPoint/$objectKey';
    } catch (e) {
      throw Exception('Failed to upload file to ArvanCloud: $e');
    }
  }

  /// Generates a presigned URL for downloading/viewing a private file (if needed).
  Future<String> getPresignedUrl(String objectKey) {
    return _minio.presignedGetObject(_bucketName, objectKey);
  }
}
