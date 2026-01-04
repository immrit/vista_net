import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../config/app_theme.dart';
import '../providers/documents_provider.dart';
import '../../../../models/user_document_model.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentsProvider);
    final controller = ref.read(documentsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کیف مدارک من (گاوصندوق)'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: state.isLoading && state.documents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.documents.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: state.documents.length,
              itemBuilder: (context, index) {
                return _buildDocumentCard(
                  context,
                  state.documents[index],
                  controller,
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentSheet(context, ref),
        label: const Text('افزودن مدرک'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.snappPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'هنوز مدرکی اضافه نکرده‌اید',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'مدارک خود را اینجا امن نگه دارید',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    UserDocument doc,
    DocumentsController controller,
  ) {
    final isImage =
        doc.fileType == 'image' ||
        doc.fileType == 'jpg' ||
        doc.fileType == 'png';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Open preview or details
          // For now just show full screen image dialog if image
          if (isImage) {
            showDialog(
              context: context,
              builder: (_) => Dialog(child: Image.network(doc.fileUrl)),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: isImage
                    ? Image.network(
                        doc.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.red[50], // PDF/File background
                        child: const Center(
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 48,
                            color: Colors.red,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () => _confirmDelete(context, controller, doc),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DocumentsController controller,
    UserDocument doc,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مدرک'),
        content: const Text('آیا از حذف این مدرک مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteDocument(doc.id, doc.fileUrl);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddDocumentForm(),
    );
  }
}

class _AddDocumentForm extends ConsumerStatefulWidget {
  const _AddDocumentForm();

  @override
  ConsumerState<_AddDocumentForm> createState() => _AddDocumentFormState();
}

class _AddDocumentFormState extends ConsumerState<_AddDocumentForm> {
  final _titleController = TextEditingController();
  File? _selectedFile;
  String _fileType = 'image'; // 'image' or 'pdf'
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _fileType = 'image';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileType = 'pdf';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'افزودن مدرک جدید',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان مدرک (مثلاً کارت ملی)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('انتخاب تصویر'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor:
                        _fileType == 'image' && _selectedFile != null
                        ? Colors.blue.withValues(alpha: 0.1)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('انتخاب PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: _fileType == 'pdf' && _selectedFile != null
                        ? Colors.red.withValues(alpha: 0.1)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 8),
            Text(
              'فایل انتخاب شده: ${_selectedFile!.path.split('/').last}',
              style: const TextStyle(fontSize: 12, color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isUploading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppTheme.snappPrimary,
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('ذخیره مدرک'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً عنوان و فایل را انتخاب کنید')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final success = await ref
        .read(documentsProvider.notifier)
        .uploadDocument(
          file: _selectedFile!,
          title: _titleController.text,
          fileType: _fileType,
        );

    setState(() => _isUploading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('مدرک با موفقیت ذخیره شد')));
    }
  }
}
