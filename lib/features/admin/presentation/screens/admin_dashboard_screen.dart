import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../config/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _totalTickets = 0;
  int _openTickets = 0;
  int _todayTickets = 0;
  // ignore: unused_field
  int _completedTickets = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get all tickets count
      final allResponse = await supabase.from('tickets').select('id');
      final total = (allResponse as List).length;

      // Get open tickets count
      final openResponse = await supabase.from('tickets').select('id').inFilter(
        'status',
        ['open', 'in_progress', 'pending'],
      );
      final open = (openResponse as List).length;

      // Get today's tickets
      final todayResponse = await supabase
          .from('tickets')
          .select('id')
          .gte('created_at', today);
      final todayCount = (todayResponse as List).length;

      // Get completed tickets
      final completedResponse = await supabase
          .from('tickets')
          .select('id')
          .eq('status', 'completed');
      final completed = (completedResponse as List).length;

      if (mounted) {
        setState(() {
          _totalTickets = total;
          _openTickets = open;
          _todayTickets = todayCount;
          _completedTickets = completed;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('داشبورد مدیریت'),
        centerTitle: true,
        backgroundColor: AppTheme.snappPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'خلاصه وضعیت',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          'کل تیکت‌ها',
                          _totalTickets,
                          Icons.folder_copy_outlined,
                          Colors.blue,
                          Colors.lightBlueAccent,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'تیکت‌های باز',
                          _openTickets,
                          Icons.access_time_filled,
                          Colors.orange,
                          Colors.orangeAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          'تیکت‌های امروز',
                          _todayTickets,
                          Icons.today,
                          Colors.purple,
                          Colors.purpleAccent,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'کاربران فعال',
                          0, // Placeholder
                          Icons.people_outline,
                          Colors.teal,
                          Colors.tealAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'دسترسی سریع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildQuickAction(
                      'مدیریت خدمات',
                      'افزودن و ویرایش خدمات موجود',
                      Icons.category_outlined,
                      Colors.indigo,
                      () {
                        // Quick action navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('به زودی...')),
                        );
                      },
                    ),
                    _buildQuickAction(
                      'گزارشات مالی',
                      'مشاهده تراکنش‌ها و درآمدها',
                      Icons.bar_chart_rounded,
                      Colors.green,
                      () {
                        // Quick action navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('به زودی...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
    IconData icon,
    Color color1,
    Color color2,
  ) {
    return Expanded(
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color1.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Vazir',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Vazir',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'Vazir',
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
