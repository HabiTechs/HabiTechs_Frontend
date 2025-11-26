import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/ticket.dart';
import 'package:habitechs/data/repositories/ticket_repository.dart';

// --- Provider para la LISTA de tickets ---
final myTicketsProvider = FutureProvider.autoDispose<List<Ticket>>((ref) async {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getMyTickets();
});

// --- Provider para la ACCIÓN de crear un ticket ---
final ticketActionProvider =
    StateNotifierProvider.autoDispose<TicketActionNotifier, AsyncValue<void>>(
        (ref) {
  return TicketActionNotifier(ref);
});

class TicketActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  TicketActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> createTicket(String title, String description) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(ticketRepoProvider);
      await repo.createTicket(title, description);

      // ÉXITO
      state = const AsyncData(null);

      // Refrescar la lista de tickets
      _ref.invalidate(myTicketsProvider);
    } catch (e, stack) {
      // ERROR
      state = AsyncError(e, stack);
    }
  }
}
