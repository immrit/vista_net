import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/ticket_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/ticket_repository.dart';

final myTicketsProvider = FutureProvider.autoDispose<List<TicketModel>>((
  ref,
) async {
  // Get userId from custom auth state
  final authState = ref.watch(authProvider);

  // If not logged in or no userId, return empty list
  if (!authState.isLoggedIn || authState.userId == null) {
    return [];
  }

  final repository = ref.watch(ticketRepositoryProvider);
  return repository.getUserTickets(authState.userId!);
});
