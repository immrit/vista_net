import 'package:flutter/material.dart';
import '../services/service_payment_service.dart';
import '../widgets/service_payment_widget.dart' as payment_widget;
import '../models/service_model.dart';

/// Example usage of service payment in your app
class ServicePaymentUsageExample extends StatelessWidget {
  const ServicePaymentUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample service for demonstration
    final sampleService = Service(
      id: 'sample_service_1',
      categoryId: 'category_1',
      title: 'سرویس نمونه',
      description: 'توضیحات سرویس نمونه',
      icon: 'description',
      isActive: true,
      requiresDocuments: false,
      requiresNationalId: true,
      requiresPersonalCode: false,
      requiresPhoneVerification: false,
      requiresAddress: false,
      requiresBirthDate: false,
      maxFileSizeMb: 10,
      allowedFileTypes: ['pdf', 'jpg'],
      maxFilesCount: 5,
      processingTimeDays: 3,
      costAmount: 50000.0, // 50,000 تومان
      isPaidService: true,
      customFields: [],
      validationRules: {},
      formConfig: {},
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('مثال استفاده از پرداخت سرویس')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Service Payment Widget
            const Text(
              '1. ویجت پرداخت سرویس',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            payment_widget.ServicePaymentWidget(
              service: sampleService,
              showAsButton: false,
              onPaymentSuccess: () {
                print('Service payment successful!');
              },
              onPaymentError: () {
                print('Service payment failed!');
              },
            ),
            const SizedBox(height: 24),

            // Example 2: Service Payment Status
            const Text(
              '2. وضعیت پرداخت سرویس',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            payment_widget.ServicePaymentStatus(
              serviceId: sampleService.id,
              paidWidget: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('سرویس پرداخت شده است'),
                  ],
                ),
              ),
              unpaidWidget: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.payment, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('سرویس نیاز به پرداخت دارد'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 3: Payment Button
            const Text(
              '3. دکمه پرداخت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            payment_widget.ServicePaymentWidget(
              service: sampleService,
              showAsButton: true,
              buttonText: 'پرداخت سرویس',
              buttonColor: Colors.green,
              onPaymentSuccess: () {
                print('Payment successful!');
              },
            ),
            const SizedBox(height: 24),

            // Example 4: Check Payment Status Programmatically
            const Text(
              '4. بررسی وضعیت پرداخت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final paymentService = ServicePaymentService();
                final isPaid = paymentService.isServicePaid(sampleService.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isPaid ? 'سرویس پرداخت شده است' : 'سرویس پرداخت نشده است',
                    ),
                    backgroundColor: isPaid ? Colors.green : Colors.orange,
                  ),
                );
              },
              child: const Text('بررسی وضعیت پرداخت'),
            ),
            const SizedBox(height: 24),

            // Example 5: Navigation to Service Payments Screen
            const Text(
              '5. صفحه مدیریت پرداخت‌ها',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/service-payments');
              },
              icon: const Icon(Icons.payment),
              label: const Text('مدیریت پرداخت سرویس‌ها'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of integrating service payment into a service list
class ServiceListWithPayment extends StatelessWidget {
  const ServiceListWithPayment({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample services
    final services = [
      Service(
        id: 'service_1',
        categoryId: 'category_1',
        title: 'سرویس رایگان',
        description: 'این سرویس رایگان است',
        icon: 'description',
        isActive: true,
        requiresDocuments: false,
        requiresNationalId: false,
        requiresPersonalCode: false,
        requiresPhoneVerification: false,
        requiresAddress: false,
        requiresBirthDate: false,
        maxFileSizeMb: 10,
        allowedFileTypes: ['pdf'],
        maxFilesCount: 3,
        processingTimeDays: 1,
        costAmount: 0.0,
        isPaidService: false,
        customFields: [],
        validationRules: {},
        formConfig: {},
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Service(
        id: 'service_2',
        categoryId: 'category_1',
        title: 'سرویس پولی',
        description: 'این سرویس نیاز به پرداخت دارد',
        icon: 'description',
        isActive: true,
        requiresDocuments: true,
        requiresNationalId: true,
        requiresPersonalCode: false,
        requiresPhoneVerification: false,
        requiresAddress: false,
        requiresBirthDate: false,
        maxFileSizeMb: 20,
        allowedFileTypes: ['pdf', 'jpg', 'png'],
        maxFilesCount: 10,
        processingTimeDays: 5,
        costAmount: 100000.0, // 100,000 تومان
        isPaidService: true,
        customFields: [],
        validationRules: {},
        formConfig: {},
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('لیست سرویس‌ها')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final paymentService = ServicePaymentService();
          final isPaid = paymentService.isServicePaid(service.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: service.isPaidService
                    ? (isPaid ? Colors.green : Colors.orange)
                    : Colors.blue,
                child: Icon(
                  service.isPaidService
                      ? (isPaid ? Icons.check : Icons.payment)
                      : Icons.free_breakfast,
                  color: Colors.white,
                ),
              ),
              title: Text(service.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.description),
                  if (service.isPaidService) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${service.costAmount.toStringAsFixed(0)} تومان',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isPaid)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'پرداخت شده',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              trailing: service.isPaidService && !isPaid
                  ? ElevatedButton(
                      onPressed: () {
                        // Navigate to service form with payment
                        Navigator.pushNamed(
                          context,
                          '/service-form',
                          arguments: service,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('پرداخت'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Navigate to service form
                        Navigator.pushNamed(
                          context,
                          '/service-form',
                          arguments: service,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(service.isPaidService ? 'مشاهده' : 'استفاده'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
