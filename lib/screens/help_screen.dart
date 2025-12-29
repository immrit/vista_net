import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.snappLightGray,
      appBar: AppBar(
        title: const Text('راهنما و پشتیبانی'),
        backgroundColor: AppTheme.snappPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            title: 'سوالات متداول',
            items: [
              _buildHelpItem(
                question: 'چگونه تیکت جدید ایجاد کنم؟',
                answer:
                    'برای ایجاد تیکت جدید، از صفحه خدمات، خدمت مورد نظر خود را انتخاب کرده و فرم درخواست را پر کنید.',
              ),
              _buildHelpItem(
                question: 'چگونه وضعیت تیکت خود را پیگیری کنم؟',
                answer:
                    'از صفحه تیکت‌ها می‌توانید وضعیت تمام تیکت‌های خود را مشاهده کنید.',
              ),
              _buildHelpItem(
                question: 'چگونه با پشتیبانی تماس بگیرم؟',
                answer:
                    'از صفحه خانه یا تیکت‌ها، دکمه "چت با پشتیبانی" را انتخاب کنید.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHelpSection(
            title: 'تماس با ما',
            items: [
              _buildContactItem(
                icon: Icons.phone_rounded,
                title: 'تلفن پشتیبانی',
                subtitle: '021-12345678',
                onTap: () {},
              ),
              _buildContactItem(
                icon: Icons.email_rounded,
                title: 'ایمیل',
                subtitle: 'support@vistanet.ir',
                onTap: () {},
              ),
              _buildContactItem(
                icon: Icons.chat_rounded,
                title: 'چت آنلاین',
                subtitle: 'پشتیبانی 24 ساعته',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.snappDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildHelpItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.snappDark,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.snappGray,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.snappPrimary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.snappDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.snappGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.snappGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


