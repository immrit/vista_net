import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';
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
          ? Center(child: Text('خطا: ${state.error}'))
          : state.service == null
          ? const Center(child: Text('سرویس یافت نشد'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 24),

                  // Dynamic Fields Section
                  if (state.service!.fields.isNotEmpty) ...[
                    _buildSectionTitle('اطلاعات درخواست'),
                    const SizedBox(height: 12),
                    ...state.service!.fields.map(
                      (field) => _buildDynamicField(field, state),
                    ),
                  ],

                  // Attachments - ONLY if service requires documents
                  if (state.service!.requiresDocuments) ...[
                    const SizedBox(height: 20),
                    _buildAttachmentsSection(state),
                  ],

                  const SizedBox(height: 30),
                  _buildSubmitButton(state),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: AppTheme.snappPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.service!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.orange[800],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'هزینه: ${intl.NumberFormat('#,###').format(state.service!.costAmount)} تومان',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (state.service!.processingTimeDays > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'زمان پردازش: ${state.service!.processingTimeDays} روز کاری',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicField(ServiceField field, ServiceFormState state) {
    // Skip file fields - handled by attachments section
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
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.text_fields,
          placeholder: field.placeholder,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) => (val == null || val.isEmpty)
                    ? '${field.fieldLabel} الزامی است'
                    : null
              : null,
        );

      case FieldType.email:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.email_outlined,
          placeholder: field.placeholder ?? 'example@email.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) {
                  if (val == null || val.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(val)) {
                    return 'ایمیل نامعتبر است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.phone:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.phone_outlined,
          placeholder: field.placeholder ?? '09123456789',
          keyboardType: TextInputType.phone,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) {
                  if (val == null || val.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  if (!RegExp(r'^09\d{9}$').hasMatch(val)) {
                    return 'شماره موبایل نامعتبر است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.number:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.numbers,
          placeholder: field.placeholder,
          keyboardType: TextInputType.number,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) => (val == null || val.isEmpty)
                    ? '${field.fieldLabel} الزامی است'
                    : null
              : null,
        );

      case FieldType.textarea:
        return _buildTextField(
          label: field.fieldLabel,
          icon: Icons.notes,
          placeholder: field.placeholder,
          maxLines: 4,
          onChanged: (val) => ref
              .read(serviceFormProvider.notifier)
              .updateField(field.fieldName, val),
          validator: field.isRequired
              ? (val) => (val == null || val.isEmpty)
                    ? '${field.fieldLabel} الزامی است'
                    : null
              : null,
        );

      case FieldType.select:
        return _buildDropdownField(field, state);

      case FieldType.date:
        return _buildDateField(field, state);

      case FieldType.checkbox:
        return _buildCheckboxField(field, state);

      case FieldType.file:
        // Handled by attachments section
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownField(ServiceField field, ServiceFormState state) {
    final options = field.options.map((e) => e.toString()).toList();
    final currentValue = state.formData[field.fieldName]?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: options.contains(currentValue) ? currentValue : null,
        decoration: InputDecoration(
          labelText: field.fieldLabel,
          prefixIcon: Icon(Icons.arrow_drop_down_circle_outlined, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            ref
                .read(serviceFormProvider.notifier)
                .updateField(field.fieldName, val);
          }
        },
        validator: field.isRequired
            ? (val) => (val == null || val.isEmpty)
                  ? '${field.fieldLabel} الزامی است'
                  : null
            : null,
      ),
    );
  }

  Widget _buildDateField(ServiceField field, ServiceFormState state) {
    final selectedDate = state.formData[field.fieldName] as DateTime?;
    String displayText = field.placeholder ?? 'انتخاب تاریخ';

    if (selectedDate != null) {
      final jalali = Jalali.fromDateTime(selectedDate);
      displayText = '${jalali.year}/${jalali.month}/${jalali.day}';
    }

    return InkWell(
      onTap: () => _selectDate(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldLabel,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayText,
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.black
                          : Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(ServiceField field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('fa', 'IR'),
    );

    if (picked != null) {
      ref
          .read(serviceFormProvider.notifier)
          .updateField(field.fieldName, picked);
    }
  }

  Widget _buildCheckboxField(ServiceField field, ServiceFormState state) {
    final isChecked = state.formData[field.fieldName] == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(field.fieldLabel),
        subtitle: field.placeholder != null ? Text(field.placeholder!) : null,
        value: isChecked,
        onChanged: (val) => ref
            .read(serviceFormProvider.notifier)
            .updateField(field.fieldName, val ?? false),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.snappPrimary,
      ),
    );
  }

  Widget _buildAttachmentsSection(ServiceFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('پیوست‌ها'),
        const SizedBox(height: 8),
        Text(
          'حداکثر ${state.service!.maxFilesCount} فایل (${state.service!.allowedFileTypes.join(', ')})',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.attach_file,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.size > 0)
                          Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () {
                      ref.read(serviceFormProvider.notifier).removeFile(file);
                    },
                  ),
                ],
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: state.selectedFiles.length >= state.service!.maxFilesCount
              ? null
              : () {
                  ref.read(serviceFormProvider.notifier).pickFiles();
                },
          icon: const Icon(Icons.add),
          label: Text(
            state.selectedFiles.isEmpty ? 'افزودن فایل' : 'افزودن فایل دیگر',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
    String? placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildSubmitButton(ServiceFormState state) {
    return SizedBox(
      width: double.infinity,
      height: 54,
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
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text('ثبت درخواست', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }
}
