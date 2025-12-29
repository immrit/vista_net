import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/billing_service.dart';
import '../widgets/billing_widget.dart';
import '../config/billing_config.dart';

// Define a provider for the BillingService singleton
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService();
});

/// Example usage of Cafe Bazaar billing in your app
class BillingUsageExample extends StatelessWidget {
  const BillingUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Usage Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Simple Purchase Button
            const Text(
              '1. Simple Purchase Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BillingWidget(
              productId: BillingConfig.products['premium_upgrade']!,
              title: BillingConfig.getProductTitle('premium_upgrade'),
              description: BillingConfig.getProductDescription(
                'premium_upgrade',
              ),
              price: BillingConfig.getProductPrice('premium_upgrade'),
              buttonText: 'خرید پریمیوم',
              buttonColor: Colors.green,
              onPurchaseSuccess: () {
                debugPrint('Premium upgrade purchased!');
              },
            ),
            const SizedBox(height: 24),

            // Example 2: Premium Feature with Lock
            const Text(
              '2. Premium Feature (Locked)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PremiumFeature(
              productId: BillingConfig.products['unlock_features']!,
              unlockMessage:
                  'برای دسترسی به این ویژگی، ابتدا آن را خریداری کنید',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.star, color: Colors.blue, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'ویژگی پیشرفته',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text('این ویژگی فقط برای کاربران پریمیوم در دسترس است'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 3: Subscription Status
            const Text(
              '3. Subscription Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SubscriptionStatus(
              productId: BillingConfig.products['monthly_subscription']!,
              activeWidget: Container(
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
                    Text('اشتراک فعال است'),
                  ],
                ),
              ),
              inactiveWidget: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('اشتراک غیرفعال است'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 4: Remove Ads Button
            const Text(
              '4. Remove Ads Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BillingWidget(
              productId: BillingConfig.products['remove_ads']!,
              title: BillingConfig.getProductTitle('remove_ads'),
              description: BillingConfig.getProductDescription('remove_ads'),
              price: BillingConfig.getProductPrice('remove_ads'),
              buttonText: 'حذف تبلیغات',
              buttonColor: Colors.orange,
              onPurchaseSuccess: () {
                // Hide ads in your app
                debugPrint('Ads removed!');
              },
            ),
            const SizedBox(height: 24),

            // Example 5: Navigation to Billing Screen
            const Text(
              '5. Navigate to Billing Screen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/billing');
              },
              icon: const Icon(Icons.payment),
              label: const Text('مدیریت خریدها'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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

/// Example of integrating billing into an existing screen
class HomeScreenWithBilling extends ConsumerWidget {
  const HomeScreenWithBilling({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Premium indicator in app bar
          Consumer(
            builder: (context, ref, child) {
              final billingService = ref.watch(billingServiceProvider);
              final isPremium = billingService.isProductPurchased(
                'premium_upgrade',
              );
              return IconButton(
                icon: Icon(
                  isPremium ? Icons.star : Icons.star_border,
                  color: isPremium ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/billing');
                },
                tooltip: isPremium ? 'پریمیوم' : 'ارتقاء به پریمیوم',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Regular content
          Expanded(
            child: ListView(
              children: [
                const ListTile(
                  leading: Icon(Icons.home),
                  title: Text('صفحه اصلی'),
                ),
                const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('تنظیمات'),
                ),

                // Premium feature
                PremiumFeature(
                  productId: 'premium_upgrade',
                  child: const ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('ویژگی پریمیوم'),
                    subtitle: Text(
                      'این ویژگی فقط برای کاربران پریمیوم در دسترس است',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom banner (ads) - only show if ads not removed
          SubscriptionStatus(
            productId: 'remove_ads',
            activeWidget: const SizedBox.shrink(), // Hide ads
            inactiveWidget: Container(
              height: 60,
              color: Colors.grey.shade300,
              child: const Center(child: Text('تبلیغات')),
            ),
          ),
        ],
      ),
    );
  }
}
