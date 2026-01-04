import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../config/app_theme.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final query = _searchQuery.toLowerCase();
    return _users.where((u) {
      final name = (u['full_name'] ?? '').toString().toLowerCase();
      final phone = (u['phone_number'] ?? '').toString();
      final nationalId = (u['national_id'] ?? '').toString();
      return name.contains(query) ||
          phone.contains(query) ||
          nationalId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount = _users.where((u) => u['is_verified'] == true).length;
    final unverifiedCount = _users.length - verifiedCount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('مدیریت کاربران'),
        centerTitle: true,
        backgroundColor: AppTheme.snappPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildMiniStat('کل', _users.length, Colors.blue),
                const SizedBox(width: 12),
                _buildMiniStat('تایید شده', verifiedCount, Colors.green),
                const SizedBox(width: 12),
                _buildMiniStat('تایید نشده', unverifiedCount, Colors.orange),
              ],
            ),
          ),

          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجوی کاربر...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Users List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'کاربری یافت نشد',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isVerified = user['is_verified'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showUserDetails(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.snappPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (user['full_name'] ?? 'ک').toString().isNotEmpty
                        ? (user['full_name'] ?? 'ک').toString()[0]
                        : 'ک',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.snappPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['full_name'] ?? 'بدون نام',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(
                          isVerified ? Icons.verified : Icons.pending,
                          size: 18,
                          color: isVerified ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['phone_number'] ?? '-',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                tooltip: 'افزایش موجودی',
                onPressed: () => _showAddBalanceDialog(user),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddBalanceDialog(Map<String, dynamic> user) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController(
      text: 'شارژ توسط ادمین',
    );
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('افزایش موجودی ${user['full_name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'مبلغ (تومان)',
                  hintText: 'مثلاً ۵۰۰۰۰',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'توضیحات (اختیاری)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('مبلغ نامعتبر است')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        await ref
                            .read(walletRepositoryProvider)
                            .addBalance(
                              targetUserId: user['id'],
                              amount: amount,
                              description: descriptionController.text,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('موجودی با موفقیت افزایش یافت'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('خطا: $e')));
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('افزایش'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.snappPrimary, AppTheme.snappSecondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      (user['full_name'] ?? 'ک').toString().isNotEmpty
                          ? (user['full_name'] ?? 'ک').toString()[0]
                          : 'ک',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  user['full_name'] ?? 'بدون نام',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildDetailRow(
                'شماره تلفن',
                user['phone_number'] ?? '-',
                Icons.phone,
              ),
              _buildDetailRow(
                'کد ملی',
                user['national_id'] ?? '-',
                Icons.badge,
              ),
              _buildDetailRow(
                'وضعیت',
                user['is_verified'] == true ? 'تایید شده ✓' : 'تایید نشده',
                Icons.verified_user,
              ),
              _buildDetailRow(
                'تاریخ ثبت‌نام',
                _formatDate(user['created_at']),
                Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.snappPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.snappPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final jalali = Jalali.fromDateTime(date);
      return '${jalali.formatter.yyyy}/${jalali.formatter.mm}/${jalali.formatter.dd}';
    } catch (e) {
      return '-';
    }
  }
}
