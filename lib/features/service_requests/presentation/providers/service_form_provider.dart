import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/service_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/ticket_repository.dart';

// Repository Provider is imported from ticket_repository.dart

// State
class ServiceFormState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final Service? service;
  final Map<String, dynamic> formData; // Stores dynamic field values
  final List<PlatformFile> selectedFiles; // Stores picked files
  final double uploadProgress;

  ServiceFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.service,
    this.formData = const {},
    this.selectedFiles = const [],
    this.uploadProgress = 0.0,
  });

  ServiceFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    Service? service,
    Map<String, dynamic>? formData,
    List<PlatformFile>? selectedFiles,
    double? uploadProgress,
  }) {
    return ServiceFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      service: service ?? this.service,
      formData: formData ?? this.formData,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

// Notifier
class ServiceFormNotifier extends StateNotifier<ServiceFormState> {
  final TicketRepository _repository;
  final Ref _ref;

  ServiceFormNotifier(this._repository, this._ref) : super(ServiceFormState());

  Future<void> loadServiceFields(String serviceId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = await _repository.getServiceWithFields(serviceId);
      state = state.copyWith(isLoading: false, service: service);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateField(String key, dynamic value) {
    final newFormData = Map<String, dynamic>.from(state.formData);
    newFormData[key] = value;
    state = state.copyWith(formData: newFormData);
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any, // Allow any file type or restrict as needed
      );

      if (result != null) {
        final newFiles = [...state.selectedFiles, ...result.files];
        state = state.copyWith(selectedFiles: newFiles);
      }
    } catch (e) {
      state = state.copyWith(error: 'خطا در انتخاب فایل: $e');
    }
  }

  void removeFile(PlatformFile file) {
    final newFiles = state.selectedFiles.where((f) => f != file).toList();
    state = state.copyWith(selectedFiles: newFiles);
  }

  Future<bool> submitForm() async {
    if (state.service == null) return false;

    // 1. Get userId from AuthProvider (Custom Auth)
    // 1. Get userId from AuthProvider (Custom Auth)
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn || authState.userId == null) {
      state = state.copyWith(error: 'User ID is null. Please log in again.');
      throw Exception('User ID is null. Please log in again.');
    }
    final userId = authState.userId!;

    state = state.copyWith(
      isSubmitting: true,
      error: null,
      uploadProgress: 0.1,
    );

    try {
      // 2. Upload Files
      List<String> uploadedUrls = [];
      if (state.selectedFiles.isNotEmpty) {
        for (var file in state.selectedFiles) {
          if (file.path != null) {
            final url = await _repository.uploadFile(File(file.path!));
            uploadedUrls.add(url);
          }
        }
      }
      state = state.copyWith(uploadProgress: 0.5);

      // 3. Submit Ticket via RPC
      await _repository.submitTicket(
        userId: userId,
        serviceId: state.service!.id,
        title: state.formData['title'] ?? 'درخواست ${state.service!.title}',
        description: state.formData['description'] ?? '',
        fileUrls: uploadedUrls,
        formData: state.formData,
      );

      state = state.copyWith(isSubmitting: false, uploadProgress: 1.0);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = ServiceFormState();
  }
}

final serviceFormProvider =
    StateNotifierProvider.autoDispose<ServiceFormNotifier, ServiceFormState>((
      ref,
    ) {
      final repository = ref.watch(ticketRepositoryProvider);
      return ServiceFormNotifier(repository, ref);
    });
