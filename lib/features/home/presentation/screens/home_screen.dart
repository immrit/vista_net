import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../services/service_api.dart';
import '../../../../services/popular_services_api.dart';
import '../../../../models/service_model.dart';
import '../../../../models/ticket_model.dart'; // Add TicketModel
import '../../../../widgets/app_logo.dart';

import '../../../service_requests/presentation/providers/my_tickets_provider.dart';
import '../../../tickets/presentation/screens/ticket_chat_screen.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../widgets/service_icon.dart';
import '../../../services/presentation/providers/local_favorites_provider.dart';

import '../../../../widgets/shimmer_loading.dart';
import '../../../main/presentation/providers/main_scaffold_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ServiceApi _serviceApi = ServiceApi();
  final PopularServicesApi _popularServicesApi = PopularServicesApi();
  List<Service> _popularServices = [];
  List<Service> _allServices = []; // For filtering favorites
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadPopularServices();
  }

  Future<void> _loadPopularServices() async {
    try {
      final popularServices = await _popularServicesApi.getPopularServices(
        limit: 8,
      );

      final allServices = await _serviceApi.getAllActiveServices();

      if (!mounted) return;

      setState(() {
        _popularServices = popularServices.isNotEmpty
            ? popularServices
            : allServices.take(8).toList();
        _allServices = allServices;
        _isLoadingServices = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingServices = false);
    }
  }

  bool _loading = false;

  Future<void> _loadData() async {
    if (_loading) return;
    setState(() => _loading = true);

    // Refresh wallet balance
    await ref.read(walletProvider.notifier).refreshBalance();

    setState(() => _loading = false);
  }

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    int? selectedAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 20),
              // Title
              Text(
                'افزایش موجودی کیف پول',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                  color: AppTheme.snappPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'مبلغ مورد نظر را انتخاب کنید',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Vazir',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Predefined amounts
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [50000, 100000, 200000, 500000].map((amount) {
                  final isSelected = selectedAmount == amount;
                  final formattedAmount = NumberFormat(
                    '#,###',
                    'fa_IR',
                  ).format(amount);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        selectedAmount = amount;
                        amountController.text = amount.toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.snappPrimary
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.snappPrimary
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        '$formattedAmount تومان',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Custom amount input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Vazir',
                ),
                decoration: InputDecoration(
                  hintText: 'یا مبلغ دلخواه وارد کنید',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Vazir',
                    fontSize: 14,
                  ),
                  suffixText: 'تومان',
                  suffixStyle: const TextStyle(
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.snappPrimary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setModalState(() {
                    selectedAmount = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 24),
              // Proceed button
              ElevatedButton(
                onPressed: selectedAmount != null && selectedAmount! > 0
                    ? () {
                        Navigator.pop(context);
                        _initiatePayment(selectedAmount!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.snappPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'پرداخت و شارژ کیف پول',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazir',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'پرداخت از طریق کافه بازار انجام می‌شود',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'Vazir',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initiatePayment(int amount) {
    // TODO: Integrate with Cafe Bazaar when ready
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'درگاه پرداخت به زودی فعال می‌شود. مبلغ انتخابی: ${NumberFormat('#,###', 'fa_IR').format(amount)} تومان',
          style: const TextStyle(fontFamily: 'Vazir'),
        ),
        backgroundColor: AppTheme.snappPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch tickets provider
    final ticketsAsync = ref.watch(myTicketsProvider);
    // Watch favorites provider
    final favoritesState = ref.watch(localFavoritesProvider);
    final userFavoriteServices = _allServices
        .where((s) => favoritesState.favoriteIds.contains(s.id))
        .toList();

    // Responsive logo size
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate size as percentage of width, clamped to safe limits
    final responsiveLogoSize = (screenWidth * 0.25).clamp(80.0, 110.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppLogo(
          showTitle: true,
          size: responsiveLogoSize,
          useTransparent: true,
          textStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          // Menu button
          Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () {
                  ref
                      .read(mainScaffoldKeyProvider)
                      .currentState
                      ?.openEndDrawer();
                },
                tooltip: 'منو',
                splashRadius: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      // endDrawer: const HamburgerMenu(), // Moved to MainScreen for correct z-index
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            100,
          ), // Bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),

              _buildSectionTitle('خدمات پرکاربرد', Icons.grid_view_rounded),
              const SizedBox(height: 16),
              _buildServicesGrid(),

              // User favorites section (only show if user has favorites)
              if (userFavoriteServices.isNotEmpty) ...[
                const SizedBox(height: 30),
                _buildSectionTitle(
                  'علاقه‌مندی‌های شما',
                  Icons.favorite_rounded,
                ),
                const SizedBox(height: 16),
                _buildUserFavoritesGrid(userFavoriteServices),
              ],

              const SizedBox(height: 30),

              _buildSectionTitle(
                'درخواست‌های اخیر',
                Icons.confirmation_number_rounded,
              ),
              const SizedBox(height: 16),
              _buildActiveTickets(ticketsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Watch wallet provider
    final walletState = ref.watch(walletProvider);
    final formattedBalance = NumberFormat(
      '#,###',
      'fa_IR',
    ).format(walletState.balance);

    // Watch currentUser provider
    final user = ref.watch(currentUserProvider);
    final userName = user?['full_name'] as String? ?? 'کاربر';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.snappPrimary,
            const Color(0xFF00C896), // Lighter Teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.snappPrimary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سلام، $userName عزیز', // Placeholder name
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'خوش آمدید',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _loadData(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'موجودی کیف پول',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontFamily: 'Vazir',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$formattedBalance تومان',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showTopUpDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16, color: AppTheme.snappPrimary),
                      const SizedBox(width: 4),
                      Text(
                        'افزایش موجودی',
                        style: TextStyle(
                          color: AppTheme.snappPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Vazir',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.snappPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazir',
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid() {
    if (_isLoadingServices) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 30) / 4;
          return Wrap(
            spacing: 10,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: List.generate(8, (index) {
              return SizedBox(
                width: itemWidth,
                child: Column(
                  children: [
                    const ShimmerLoading.circular(size: 64),
                    const SizedBox(height: 8),
                    ShimmerLoading.rectangular(
                      height: 12,
                      width: itemWidth * 0.8,
                    ),
                  ],
                ),
              );
            }),
          );
        },
      );
    }

    if (_popularServices.isEmpty) {
      return const Center(child: Text('خدمتی یافت نشد'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 30) / 4; // 4 items per row

        return Wrap(
          spacing: 10,
          runSpacing: 20,
          alignment: WrapAlignment.start,
          children: _popularServices.map((service) {
            return SizedBox(
              width: itemWidth,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ServiceIcon(
                        imageUrl: service.imageUrl,
                        iconName: service.icon,
                        containerSize: 64,
                        size: 30,
                        isNew:
                            DateTime.now()
                                .difference(service.createdAt)
                                .inDays <
                            7,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/service-form',
                                arguments: service,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserFavoritesGrid(List<Service> userFavoriteServices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 30) / 4;

        return Wrap(
          spacing: 10,
          runSpacing: 20,
          alignment: WrapAlignment.start,
          children: userFavoriteServices.map((service) {
            return SizedBox(
              width: itemWidth,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ServiceIcon(
                        imageUrl: service.imageUrl,
                        iconName: service.icon,
                        containerSize: 64,
                        size: 30,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/service-form',
                                arguments: service,
                              );
                            },
                            onLongPress: () {
                              ref
                                  .read(localFavoritesProvider.notifier)
                                  .removeFavorite(service.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'از علاقه‌مندی‌ها حذف شد',
                                    style: TextStyle(fontFamily: 'Vazir'),
                                  ),
                                  duration: Duration(seconds: 1),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Favorite indicator
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActiveTickets(AsyncValue<List<TicketModel>> ticketsAsync) {
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Text(
                'درخواست فعالی ندارید',
                style: TextStyle(color: Colors.grey, fontFamily: 'Vazir'),
              ),
            ),
          );
        }

        final recentTickets = tickets.take(5).toList();

        return SizedBox(
          height: 140, // Height for horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentTickets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final ticket = recentTickets[index];
              final statusColor = _getTicketStatusColor(ticket.status);

              return Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketChatScreen(
                            ticketId: ticket.id,
                            ticketTitle: ticket.title,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTicketStatusText(ticket.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Vazir',
                                ),
                              ),
                            ),
                            Text(
                              '#${ticket.id.substring(0, 4)}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          ticket.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Vazir',
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${Jalali.fromDateTime(ticket.createdAt).formatter.yyyy}/${Jalali.fromDateTime(ticket.createdAt).formatter.mm}/${Jalali.fromDateTime(ticket.createdAt).formatter.dd}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontFamily: 'Vazir',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoading.rectangular(height: 20, width: 80),
                    ShimmerLoading.rectangular(height: 12, width: 40),
                  ],
                ),
                ShimmerLoading.rectangular(height: 16, width: 150),
                ShimmerLoading.rectangular(height: 12, width: 100),
              ],
            ),
          ),
        ),
      ),
      error: (e, s) => Text('Error: $e'),
    );
  }

  Color _getTicketStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.processing:
        return Colors.blue;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.rejected:
        return Colors.red;
      case TicketStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getTicketStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'در انتظار';
      case TicketStatus.processing:
        return 'در حال بررسی';
      case TicketStatus.completed:
        return 'تکمیل شده';
      case TicketStatus.rejected:
        return 'رد شده';
      case TicketStatus.cancelled:
        return 'لغو شده';
    }
  }
}
