import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_document_model.dart';
import '../../data/repositories/document_repository.dart';

// Repository Provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

// State
class DocumentsState {
  final bool isLoading;
  final List<UserDocument> documents;
  final String? error;

  DocumentsState({
    this.isLoading = true,
    this.documents = const [],
    this.error,
  });

  DocumentsState copyWith({
    bool? isLoading,
    List<UserDocument>? documents,
    String? error,
  }) {
    return DocumentsState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      error: error ?? this.error,
    );
  }
}

// Controller
class DocumentsController extends StateNotifier<DocumentsState> {
  final DocumentRepository _repository;

  DocumentsController(this._repository) : super(DocumentsState()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final documents = await _repository.getUserDocuments();
      state = state.copyWith(isLoading: false, documents: documents);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadDocument({
    required File file,
    required String title,
    required String fileType,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final newDoc = await _repository.uploadDocument(
        file: file,
        title: title,
        fileType: fileType,
      );
      // Determine if we should append or refresh. Appending is faster.
      state = state.copyWith(
        isLoading: false,
        documents: [newDoc, ...state.documents],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteDocument(String id, String fileUrl) async {
    try {
      // Optimistic update? No, let's wait for success to be safe, but show loading.
      state = state.copyWith(isLoading: true, error: null);
      await _repository.deleteDocument(id, fileUrl);

      final updatedList = state.documents.where((d) => d.id != id).toList();
      state = state.copyWith(isLoading: false, documents: updatedList);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final documentsProvider =
    StateNotifierProvider<DocumentsController, DocumentsState>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return DocumentsController(repository);
    });
