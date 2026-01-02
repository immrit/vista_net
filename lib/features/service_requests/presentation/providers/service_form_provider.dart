import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/service_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/ticket_repository.dart';

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
        type: FileType.any,
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

    // 1. Get userId and fullName from AuthProvider
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn || authState.userId == null) {
      state = state.copyWith(error: 'لطفاً وارد حساب کاربری شوید');
      throw Exception('User not logged in');
    }
    final userId = authState.userId!;

    // 2. Auto-generate title: [Service Title] - [User Name]
    final userName = authState.fullName ?? 'کاربر';
    final autoTitle = '${state.service!.title} - $userName';

    // 3. Get description from formData if exists, otherwise use default
    final description =
        state.formData['description']?.toString() ??
        'ارسال شده از طریق اپلیکیشن';

    state = state.copyWith(
      isSubmitting: true,
      error: null,
      uploadProgress: 0.1,
    );

    try {
      // 4. Upload Files
      List<String> uploadedUrls = [];
      if (state.selectedFiles.isNotEmpty) {
        final totalFiles = state.selectedFiles.length;
        for (var i = 0; i < totalFiles; i++) {
          final file = state.selectedFiles[i];
          if (file.path != null) {
            final url = await _repository.uploadFile(File(file.path!));
            uploadedUrls.add(url);
            // Update progress: 10% to 50% for file uploads
            final progress = 0.1 + (0.4 * (i + 1) / totalFiles);
            state = state.copyWith(uploadProgress: progress);
          }
        }
      } else {
        state = state.copyWith(uploadProgress: 0.5);
      }

      // 5. Submit Ticket
      await _repository.submitTicket(
        userId: userId,
        serviceId: state.service!.id,
        title: autoTitle,
        description: description,
        dynamicFields: state.formData,
        fileUrls: uploadedUrls,
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
