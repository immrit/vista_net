import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/wallet_repository.dart';

// Provider for Repository
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return WalletRepository(supabase);
});

// State for Wallet Balance
class WalletState {
  final double balance;
  final bool isLoading;
  final String? error;

  const WalletState({this.balance = 0.0, this.isLoading = false, this.error});

  WalletState copyWith({double? balance, bool? isLoading, String? error}) {
    return WalletState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier for Wallet
class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  final String? _userId;

  WalletNotifier(this._repository, this._userId) : super(const WalletState()) {
    if (_userId != null) {
      refreshBalance();
    }
  }

  Future<void> refreshBalance() async {
    if (_userId == null) return;

    // Don't set loading to true to avoid UI flickering on refresh, mainly for background updates
    // But for initial load we might want it. Let's keep it silent for now or minimalistic.
    try {
      final balance = await _repository.getBalance(_userId);
      state = state.copyWith(balance: balance, error: null);
    } catch (e) {
      state = state.copyWith(error: 'خطا در دریافت موجودی');
    }
  }

  // متد برای ادمین جهت افزایش موجودی (می‌تواند در یک پرووایدر جداگانه ادمین باشد، اما اینجا هم کار راه انداز است)
  // توجه: این متد موجودی State کاربر جاری را تغییر نمی‌دهد، بلکه برای عملیات ادمین روی دیگران است.
  // برای سادگی، فعلاً عملیات ادمین را مستقیم از Repository در UI صدا می‌زنیم یا پرووایدر جداگانه می‌سازیم.
  // اما اگر کاربر خودش کیف پولش را شارژ کند (در آینده)، این متد مفید است.
}

// Provider for Wallet Notifier
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  final repository = ref.watch(walletRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return WalletNotifier(repository, userId);
});
