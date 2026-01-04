import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../models/service_model.dart';
import '../../../../models/service_field_model.dart';
import '../../../../services/service_api.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/arvan_upload_service.dart';
import '../../../../config/app_theme.dart';
import '../../../documents/presentation/providers/documents_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../widgets/shimmer_loading.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final Service service;

  const ServiceFormScreen({super.key, required this.service});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceApi _serviceApi = ServiceApi();
  final TicketService _ticketService = TicketService();

  // State
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Data
  final Map<String, dynamic> _formData = {};
  final Map<String, File> _selectedFiles = {};
  final Map<String, String> _uploadedFileUrls = {};
  List<ServiceField> _serviceFields = [];

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      setState(() => _isLoading = true);
      final serviceWithFields = await _serviceApi.getServiceWithFields(
        widget.service.id,
      );
      setState(() {
        _serviceFields = serviceWithFields.fields;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری فرم: $e')));
      }
    }
  }

  // Check if documents step is needed
  bool get _needsDocumentsStep {
    final hasFileFields = _serviceFields.any(
      (f) => f.fieldType == FieldType.file,
    );
    return hasFileFields || widget.service.requiresDocuments;
  }

  // Get total steps count
  int get _totalSteps => _needsDocumentsStep ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.service.title),
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress Bar Shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerLoading.circular(size: 40),
                      Expanded(
                        child: Container(height: 2, color: Colors.grey[200]),
                      ),
                      const ShimmerLoading.circular(size: 40),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Form Fields Shimmer
                  ShimmerLoading.rectangular(
                    height: 56,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShimmerLoading.rectangular(
                    height: 56,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShimmerLoading.rectangular(
                    height: 56,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Spacer(),
                  ShimmerLoading.rectangular(
                    height: 50,
                    width: double.infinity,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.snappPrimary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    child: Form(key: _formKey, child: _buildCurrentStep()),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          _buildStepIndicator(0, 'اطلاعات'),
          _buildConnector(0),
          if (_needsDocumentsStep) ...[
            _buildStepIndicator(1, 'مدارک'),
            _buildConnector(1),
            _buildStepIndicator(2, 'بررسی'),
          ] else
            _buildStepIndicator(1, 'بررسی'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.snappPrimary : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.snappPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.snappDark : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22, left: 4, right: 4),
        color: isActive ? AppTheme.snappPrimary : Colors.grey[200],
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_needsDocumentsStep) {
      switch (_currentStep) {
        case 0:
          return _buildInfoStep();
        case 1:
          return _buildDocumentsStep();
        case 2:
          return _buildReviewStep();
        default:
          return Container();
      }
    } else {
      switch (_currentStep) {
        case 0:
          return _buildInfoStep();
        case 1:
          return _buildReviewStep();
        default:
          return Container();
      }
    }
  }

  Widget _buildInfoStep() {
    // Filter non-file fields for the info step
    final nonFileFields = _serviceFields
        .where((f) => f.fieldType != FieldType.file)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'اطلاعات درخواست',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'لطفاً اطلاعات درخواست را تکمیل کنید',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Dynamic Fields - render ALL from service.fields (non-file)
        if (nonFileFields.isNotEmpty) ...nonFileFields.map(_buildDynamicField),

        // If no dynamic fields defined, show a message
        if (nonFileFields.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[400], size: 40),
                const SizedBox(height: 12),
                const Text(
                  'این سرویس نیاز به اطلاعات تکمیلی ندارد',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    final fileFields = _serviceFields
        .where((f) => f.fieldType == FieldType.file)
        .toList();

    if (fileFields.isEmpty && !widget.service.requiresDocuments) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[100],
            ),
            const SizedBox(height: 16),
            const Text('نیازی به ارسال مدرک برای این درخواست نیست'),
            const SizedBox(height: 8),
            TextButton(onPressed: _nextStep, child: const Text('مرحله بعد')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'بارگذاری مدارک',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'لطفاً مدارک مورد نیاز را بارگذاری کنید',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        ...fileFields.map(_buildFileField),
      ],
    );
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'بررسی و ارسال',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'لطفاً اطلاعات را بررسی کنید',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Show all entered field data
        ..._serviceFields.where((f) => f.fieldType != FieldType.file).map((
          field,
        ) {
          final value = _formData[field.fieldName];
          if (value == null || (value is String && value.isEmpty)) {
            return const SizedBox.shrink();
          }

          String displayValue = value.toString();
          if (value is DateTime) {
            final jalali = Jalali.fromDateTime(value);
            displayValue = '${jalali.year}/${jalali.month}/${jalali.day}';
          } else if (value is bool) {
            displayValue = value ? 'بله' : 'خیر';
          }

          return _buildReviewCard(field.fieldLabel, displayValue);
        }),

        const SizedBox(height: 16),
        Text(
          'مدارک پیوست شده:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (_uploadedFileUrls.isEmpty)
          const Text('بدون فایل پیوست', style: TextStyle(color: Colors.grey)),
        ..._uploadedFileUrls.entries.map((e) {
          final fieldLabel =
              _serviceFields
                  .where((f) => f.fieldName == e.key)
                  .map((f) => f.fieldLabel)
                  .firstOrNull ??
              e.key;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(
                Icons.attach_file,
                color: AppTheme.snappPrimary,
              ),
              title: Text(fieldLabel),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        }),

        if (widget.service.isPaidService) ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'هزینه سرویس',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.service.costAmount.toStringAsFixed(0)} تومان',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'با تایید نهایی، به درگاه پرداخت هدایت خواهید شد.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewCard(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  'مرحله قبل',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.snappPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isLastStep ? 'ثبت درخواست' : 'مرحله بعد',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
    }

    // Check for required files in documents step
    if (_needsDocumentsStep && _currentStep == 1) {
      final requiredFiles = _serviceFields.where(
        (f) => f.fieldType == FieldType.file && f.isRequired,
      );
      for (var f in requiredFiles) {
        if (!_uploadedFileUrls.containsKey(f.fieldName)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لطفاً ${f.fieldLabel} را بارگذاری کنید')),
          );
          return;
        }
      }
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Widget _buildDynamicField(ServiceField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildFieldByType(field),
    );
  }

  Widget _buildFieldByType(ServiceField field) {
    switch (field.fieldType) {
      case FieldType.text:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.text_fields),
          ),
          initialValue: _formData[field.fieldName]?.toString(),
          onSaved: (v) => _formData[field.fieldName] = v,
          validator: field.isRequired
              ? (v) =>
                    v?.isEmpty == true ? '${field.fieldLabel} الزامی است' : null
              : null,
        );

      case FieldType.email:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder ?? 'example@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          initialValue: _formData[field.fieldName]?.toString(),
          onSaved: (v) => _formData[field.fieldName] = v,
          validator: field.isRequired
              ? (v) {
                  if (v?.isEmpty == true) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(v ?? '')) {
                    return 'ایمیل نامعتبر است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.phone:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder ?? '09123456789',
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          initialValue: _formData[field.fieldName]?.toString(),
          onSaved: (v) => _formData[field.fieldName] = v,
          validator: field.isRequired
              ? (v) {
                  if (v?.isEmpty == true) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  if (!RegExp(r'^09\d{9}$').hasMatch(v ?? '')) {
                    return 'شماره موبایل نامعتبر است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.number:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          initialValue: _formData[field.fieldName]?.toString(),
          onSaved: (v) => _formData[field.fieldName] = v,
          validator: field.isRequired
              ? (v) =>
                    v?.isEmpty == true ? '${field.fieldLabel} الزامی است' : null
              : null,
        );

      case FieldType.textarea:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            prefixIcon: const Icon(Icons.notes),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          initialValue: _formData[field.fieldName]?.toString(),
          onSaved: (v) => _formData[field.fieldName] = v,
          validator: field.isRequired
              ? (v) =>
                    v?.isEmpty == true ? '${field.fieldLabel} الزامی است' : null
              : null,
        );

      case FieldType.select:
        return _buildDropdownField(field);

      case FieldType.date:
        return _buildDateField(field);

      case FieldType.checkbox:
        return _buildCheckboxField(field);

      case FieldType.file:
        // File fields are handled in documents step
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownField(ServiceField field) {
    final options = field.options.map((e) => e.toString()).toList();
    final currentValue = _formData[field.fieldName]?.toString();

    return DropdownButtonFormField<String>(
      initialValue: options.contains(currentValue) ? currentValue : null,
      decoration: InputDecoration(
        labelText: field.fieldLabel,
        prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: (val) {
        setState(() => _formData[field.fieldName] = val);
      },
      onSaved: (val) => _formData[field.fieldName] = val,
      validator: field.isRequired
          ? (val) => (val == null || val.isEmpty)
                ? '${field.fieldLabel} الزامی است'
                : null
          : null,
    );
  }

  Widget _buildDateField(ServiceField field) {
    final selectedDate = _formData[field.fieldName] as DateTime?;
    String displayText = field.placeholder ?? 'انتخاب تاریخ';

    if (selectedDate != null) {
      final jalali = Jalali.fromDateTime(selectedDate);
      displayText = '${jalali.year}/${jalali.month}/${jalali.day}';
    }

    return InkWell(
      onTap: () => _selectDate(field),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.fieldLabel,
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: selectedDate != null ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(ServiceField field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _formData[field.fieldName] as DateTime? ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _formData[field.fieldName] = picked);
    }
  }

  Widget _buildCheckboxField(ServiceField field) {
    final isChecked = _formData[field.fieldName] == true;

    return CheckboxListTile(
      title: Text(field.fieldLabel),
      subtitle: field.placeholder != null ? Text(field.placeholder!) : null,
      value: isChecked,
      onChanged: (val) {
        setState(() => _formData[field.fieldName] = val ?? false);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppTheme.snappPrimary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFileField(ServiceField field) {
    final uploadedUrl = _uploadedFileUrls[field.fieldName];
    final selectedFile = _selectedFiles[field.fieldName];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field.fieldLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (field.isRequired)
                const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),

          if (uploadedUrl != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'فایل با موفقیت آپلود شد',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.green),
                    onPressed: () => setState(
                      () => _uploadedFileUrls.remove(field.fieldName),
                    ),
                  ),
                ],
              ),
            )
          else if (selectedFile != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.insert_drive_file,
                color: AppTheme.snappPrimary,
              ),
              title: Text(selectedFile.path.split('/').last),
              subtitle: Text(
                '${(selectedFile.lengthSync() / 1024).toStringAsFixed(0)} KB',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    setState(() => _selectedFiles.remove(field.fieldName)),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFile(field),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('انتخاب فایل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDigitalSafePicker(field),
                    icon: const Icon(Icons.folder_special),
                    label: const Text('گاوصندوق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.snappPrimary.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: AppTheme.snappPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (selectedFile != null && uploadedUrl == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _uploadFile(field),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('آپلود نهایی'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDigitalSafePicker(ServiceField field) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final docsState = ref.watch(documentsProvider);

          return Container(
            padding: const EdgeInsets.all(16),
            height: 400,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'انتخاب از گاوصندوق',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (docsState.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (docsState.documents.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'سندی یافت نشد',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: docsState.documents.length,
                      itemBuilder: (ctx, i) {
                        final doc = docsState.documents[i];
                        return ListTile(
                          leading: Icon(
                            doc.fileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: AppTheme.snappPrimary,
                          ),
                          title: Text(doc.title),
                          onTap: () {
                            setState(() {
                              _uploadedFileUrls[field.fieldName] = doc.fileUrl;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickFile(ServiceField field) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('انتخاب فایل', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('گالری تصاویر'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(
                    () => _selectedFiles[field.fieldName] = File(image.path),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('دوربین'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(
                    () => _selectedFiles[field.fieldName] = File(image.path),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.insert_drive_file,
                color: Colors.orange,
              ),
              title: const Text('فایل (PDF/Doc)'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx'],
                );
                if (result != null && result.files.single.path != null) {
                  setState(
                    () => _selectedFiles[field.fieldName] = File(
                      result.files.single.path!,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(ServiceField field) async {
    final file = _selectedFiles[field.fieldName];
    if (file == null) return;
    try {
      setState(() => _isSubmitting = true);
      final url = await ArvanUploadService.uploadFile(
        file,
        'tickets/${widget.service.id}',
        customFileName:
            '${field.fieldName}_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() => _uploadedFileUrls[field.fieldName] = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در آپلود: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitForm() async {
    // Payment Logic
    if (widget.service.isPaidService) {
      final paid = await _showPaymentDialog();
      if (!paid) return;
    }

    try {
      setState(() => _isSubmitting = true);

      // Auto-generate title from service name and user name
      final authState = ref.read(authProvider);
      final userName = authState.fullName ?? 'کاربر';
      final autoTitle = '${widget.service.title} - $userName';

      // Get description from dynamic fields if exists
      final description =
          _formData['description']?.toString() ?? 'ارسال شده از طریق اپلیکیشن';

      await _ticketService.createTicket(
        serviceId: widget.service.id,
        serviceTitle: widget.service.title,
        title: autoTitle,
        description: description,
        dynamicFields: {..._formData, ..._uploadedFileUrls},
        details: {'cost': widget.service.costAmount},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درخواست با موفقیت ثبت شد'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _showPaymentDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('پرداخت هزینه'),
            content: Text(
              'مبلغ ${widget.service.costAmount.toStringAsFixed(0)} تومان برای این درخواست کسر خواهد شد.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('پرداخت و ثبت'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
