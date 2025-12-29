import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../models/service_field_model.dart';
import '../../../../config/app_theme.dart';
import '../providers/service_form_provider.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceTitle;

  const NewRequestScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
  });

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load service details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(serviceFormProvider.notifier)
          .loadServiceFields(widget.serviceId);
    });
  }

  @override
  void deactivate() {
    // Optional: clear state when leaving
    // ref.read(serviceFormProvider.notifier).reset();
    // Handled by autoDispose
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceFormProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.serviceTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : state.service == null
          ? const Center(child: Text('Service not found'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 20),
                  _buildBasicFields(state),
                  const SizedBox(height: 20),
                  if (state.service!.fields.isNotEmpty) ...[
                    const Text(
                      'اطلاعات تکمیلی',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.service!.fields.map(
                      (field) => _buildDynamicField(field, state),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildAttachmentsSection(state),
                  const SizedBox(height: 30),
                  _buildSubmitButton(state),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ServiceFormState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.service!.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.service!.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          if (state.service!.isPaidService) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                'هزینه: ${intl.NumberFormat('#,###').format(state.service!.costAmount)} تومان',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicFields(ServiceFormState state) {
    return Column(
      children: [
        _buildTextField(
          label: 'عنوان درخواست',
          icon: Icons.title,
          onChanged: (val) =>
              ref.read(serviceFormProvider.notifier).updateField('title', val),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'عنوان الزامی است' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'توضیحات',
          icon: Icons.description,
          maxLines: 3,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField('description', val),
          validator: (val) =>
              (val == null || val.isEmpty) ? 'توضیحات الزامی است' : null,
        ),
        if (state.service!.requiresNationalId) ...[
          const SizedBox(height: 16),
          _buildTextField(
            label: 'کد ملی',
            icon: Icons.badge,
            keyboardType: TextInputType.number,
            onChanged: (val) => ref
                .read(serviceFormProvider.notifier)
                .updateField('national_id', val),
            validator: (val) =>
                (val == null || val.length != 10) ? 'کد ملی ۱۰ رقم است' : null,
          ),
        ],
      ],
    );
  }

  Widget _buildDynamicField(ServiceField field, ServiceFormState state) {
    // If fieldType is file, we skip it here as we have a generic attachments section
    // OR we could render a text saying "Please attach file below"
    if (field.fieldType == FieldType.file) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildFieldByType(field, state),
    );
  }

  Widget _buildFieldByType(ServiceField field, ServiceFormState state) {
    switch (field.fieldType) {
      case FieldType.text:
      case FieldType.email:
      case FieldType.phone:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.text_fields,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) => (val == null || val.isEmpty) ? 'الزامی است' : null
              : null,
        );

      case FieldType.number:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) => (val == null || val.isEmpty) ? 'الزامی است' : null
              : null,
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.fieldLabel),
          value: state.formData[field.fieldName] ?? false,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          contentPadding: EdgeInsets.zero,
        );

      default:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.input,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
        );
    }
  }

  Widget _buildAttachmentsSection(ServiceFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'پیوست‌ها',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.selectedFiles.isNotEmpty)
          ...state.selectedFiles.map((file) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ref.read(serviceFormProvider.notifier).removeFile(file);
                    },
                  ),
                ],
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(serviceFormProvider.notifier).pickFiles();
          },
          icon: const Icon(Icons.add),
          label: const Text('افزودن فایل'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSubmitButton(ServiceFormState state) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: state.isSubmitting
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  final success = await ref
                      .read(serviceFormProvider.notifier)
                      .submitForm();

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('درخواست با موفقیت ثبت شد'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state.error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطا: ${state.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.snappPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'در حال ارسال (${(state.uploadProgress * 100).toInt()}%)',
                  ),
                ],
              )
            : const Text('ثبت درخواست', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
