import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازخورد و پیشنهادات'),
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // امتیازدهی
              const Text(
                'امتیاز کلی شما از اپلیکیشن:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRatingSection(),

              const SizedBox(height: 24),

              // متن بازخورد
              const Text(
                'نظرات و پیشنهادات شما:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  hintText: 'نظرات و پیشنهادات خود را اینجا بنویسید...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.feedback),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نظرات خود را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // دکمه ارسال
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.snappPrimary,
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
                          'ارسال بازخورد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // اطلاعات تماس
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'راه‌های ارتباطی:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('📧 ایمیل: support@vistanet.com'),
                      const Text('📱 تلفن: 021-12345678'),
                      const Text('🌐 وب‌سایت: www.vistanet.com'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = rating;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              rating <= _selectedRating ? Icons.star : Icons.star_border,
              size: 32,
              color: rating <= _selectedRating ? Colors.amber : Colors.grey,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      // شبیه‌سازی ارسال بازخورد
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('بازخورد شما با موفقیت ارسال شد'),
            backgroundColor: Colors.green,
          ),
        );

        _feedbackController.clear();
        setState(() {
          _selectedRating = 5;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ارسال بازخورد: $e'),
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
    _feedbackController.dispose();
    super.dispose();
  }
}
