import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/user_document_model.dart';
// import 'package:path/path.dart' as path; // For file extension if needed, or just split string

class DocumentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserDocument>> getUserDocuments() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('user_documents')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserDocument.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error loading documents: $e');
    }
  }

  Future<UserDocument> uploadDocument({
    required File file,
    required String title,
    required String fileType, // 'image' or 'pdf'
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Upload file to Storage
      final String fileExt = file.path.split('.').last;
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$title.$fileExt';
      final String storagePath = '${user.id}/$fileName';

      await _supabase.storage
          .from('user-docs')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get Public URL
      final String publicUrl = _supabase.storage
          .from('user-docs')
          .getPublicUrl(storagePath);

      // 2. Insert metadata to Database
      final response = await _supabase
          .from('user_documents')
          .insert({
            'user_id': user.id,
            'title': title,
            'file_url': publicUrl,
            'file_type': fileType,
            'size_bytes': await file.length(),
            // 'storage_path': storagePath, // Useful for deletion later if API allows
          })
          .select()
          .single();

      return UserDocument.fromJson(response);
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  Future<void> deleteDocument(String documentId, String fileUrl) async {
    try {
      // 1. Delete from DB
      await _supabase.from('user_documents').delete().eq('id', documentId);

      // 2. Delete from Storage
      // Extract path from URL or pass it.
      // URL: .../user-docs/userId/filename
      // We need to robustly extract the path.
      // For now, let's assume standard Supabase URL structure.
      // Or better, just delete the record. Storage cleanup can be done separately or we try to parse.
      // Let's try to parse the path from the URL for completeness.

      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      // pathSegments usually: storage/v1/object/public/user-docs/userId/filename
      // We need 'userId/filename'

      final bucketIndex = pathSegments.indexOf('user-docs');
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from('user-docs').remove([storagePath]);
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }
}
