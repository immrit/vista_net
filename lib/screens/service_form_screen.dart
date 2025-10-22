import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/service_model.dart';
import '../models/service_field_model.dart';
import '../services/service_api.dart';
import '../services/ticket_service.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service service;

  const ServiceFormScreen({super.key, required this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ServiceApi _serviceApi = ServiceApi();
  final TicketService _ticketService = TicketService();

  final Map<String, dynamic> _formData = {};
  List<ServiceField> _serviceFields = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final serviceWithFields = await _serviceApi.getServiceWithFields(
        widget.service.id,
      );

      setState(() {
        _serviceFields = serviceWithFields.fields;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری فرم: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // اطلاعات خدمت
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.service.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (widget.service.isPaidService) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'هزینه: ${widget.service.costAmount.toStringAsFixed(0)} تومان',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // فرم
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // فیلدهای اصلی
                _buildBasicFields(),

                const SizedBox(height: 16),

                // فیلدهای پویا
                if (_serviceFields.isNotEmpty) ...[
                  const Text(
                    'اطلاعات تکمیلی',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._serviceFields.map((field) => _buildDynamicField(field)),
                ],

                const SizedBox(height: 24),

                // دکمه ارسال
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'ارسال درخواست',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اطلاعات درخواست',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // عنوان درخواست
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'عنوان درخواست',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفاً عنوان درخواست را وارد کنید';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // توضیحات
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'توضیحات درخواست',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'لطفاً توضیحات درخواست را وارد کنید';
            }
            return null;
          },
        ),

        // فیلدهای خاص خدمت
        if (widget.service.requiresNationalId) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'کد ملی',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSaved: (value) => _formData['national_id'] = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفاً کد ملی را وارد کنید';
              }
              if (value.length != 10) {
                return 'کد ملی باید 10 رقم باشد';
              }
              return null;
            },
          ),
        ],

        if (widget.service.requiresPersonalCode) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'کد پرسنلی',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            onSaved: (value) => _formData['personal_code'] = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفاً کد پرسنلی را وارد کنید';
              }
              return null;
            },
          ),
        ],

        if (widget.service.requiresAddress) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'آدرس',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
            onSaved: (value) => _formData['address'] = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفاً آدرس را وارد کنید';
              }
              return null;
            },
          ),
        ],

        if (widget.service.requiresBirthDate) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'تاریخ تولد',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(),
            onSaved: (value) => _formData['birth_date'] = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفاً تاریخ تولد را انتخاب کنید';
              }
              return null;
            },
          ),
        ],
      ],
    );
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
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
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
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.email:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  if (!value.contains('@')) {
                    return 'ایمیل معتبر نیست';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.phone:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.date:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDateForField(field),
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.select:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.arrow_drop_down),
          ),
          items: field.options.map((option) {
            return DropdownMenuItem(
              value: option.toString(),
              child: Text(option.toString()),
            );
          }).toList(),
          onChanged: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.textarea:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.fieldLabel,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_snippet),
          ),
          maxLines: 3,
          onSaved: (value) => _formData[field.fieldName] = value,
          validator: field.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${field.fieldLabel} الزامی است';
                  }
                  return null;
                }
              : null,
        );

      case FieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.fieldLabel),
          value: _formData[field.fieldName] ?? false,
          onChanged: (value) {
            setState(() {
              _formData[field.fieldName] = value ?? false;
            });
          },
        );

      case FieldType.file:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.fieldLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _selectFile(field),
              icon: const Icon(Icons.attach_file),
              label: const Text('انتخاب فایل'),
            ),
            if (_formData[field.fieldName] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'فایل انتخاب شده: ${_formData[field.fieldName]}',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
          ],
        );
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _formData['birth_date'] = date.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectDateForField(ServiceField field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _formData[field.fieldName] = date.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectFile(ServiceField field) async {
    // TODO: پیاده‌سازی انتخاب فایل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قابلیت آپلود فایل به زودی اضافه خواهد شد')),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isSubmitting = true;
      });

      await _ticketService.createTicket(
        serviceId: widget.service.id,
        serviceTitle: widget.service.title,
        title: _titleController.text,
        description: _descriptionController.text,
        nationalId: _formData['national_id'],
        personalCode: _formData['personal_code'],
        address: _formData['address'],
        birthDate: _formData['birth_date'] != null
            ? DateTime.parse(_formData['birth_date'])
            : null,
        dynamicFields: _formData,
        details: {
          'service_requirements': {
            'requires_documents': widget.service.requiresDocuments,
            'requires_national_id': widget.service.requiresNationalId,
            'requires_personal_code': widget.service.requiresPersonalCode,
            'requires_phone_verification':
                widget.service.requiresPhoneVerification,
            'requires_address': widget.service.requiresAddress,
            'requires_birth_date': widget.service.requiresBirthDate,
          },
          'processing_time_days': widget.service.processingTimeDays,
          'cost_amount': widget.service.costAmount,
          'is_paid_service': widget.service.isPaidService,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درخواست شما با موفقیت ارسال شد'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ارسال درخواست: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
