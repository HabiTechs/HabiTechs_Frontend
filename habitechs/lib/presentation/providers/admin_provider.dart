import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/ticket.dart';
import 'package:habitechs/data/models/expense.dart';
import 'package:habitechs/data/repositories/ticket_repository.dart';
import 'package:habitechs/data/repositories/finance_repository.dart';
import 'package:habitechs/data/repositories/announcement_repository.dart';
import 'package:habitechs/data/repositories/identity_repository.dart';

// --- Providers de LECTURA (GET) ---

// 1. Provider que llama a GET /api/tickets (todos)
final allTicketsProvider =
    FutureProvider.autoDispose<List<Ticket>>((ref) async {
  return ref.watch(ticketRepoProvider).getAllTickets();
});

// 2. Provider que llama a GET /api/finance/all (todas las expensas)
final allExpensesProvider =
    FutureProvider.autoDispose<List<Expense>>((ref) async {
  return ref.watch(financeRepoProvider).getAllExpenses();
});

// --- Providers de ACCIÓN (POST/PUT) ---
// (¡CORREGIDOS! Ya no pasan 'ref' al constructor)

// 3. Provider para la ACCIÓN de crear anuncio
final announcementActionProvider =
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>(
        (ref) {
  // Pasa la función de callback
  return AdminActionNotifier((data) => ref
      .read(announcementRepoProvider)
      .createAnnouncement(data['title'], data['content']));
});

// 4. Provider para la ACCIÓN de cerrar un ticket
final closeTicketActionProvider =
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>(
        (ref) {
  // Pasa la función de callback
  return AdminActionNotifier(
      (data) => ref.read(ticketRepoProvider).closeTicket(data['id']));
});

// 5. Provider para la ACCIÓN de cargar expensa
final expenseActionProvider =
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>(
        (ref) {
  // Pasa la función de callback
  return AdminActionNotifier((data) => ref
      .read(financeRepoProvider)
      .createExpense(
          data['email'], data['title'], data['amount'], data['date']));
});

// 6. Provider para la ACCIÓN de asignar rol de guardia
final assignRoleActionProvider =
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>(
        (ref) {
  // Pasa la función de callback
  return AdminActionNotifier(
      (data) => ref.read(identityRepoProvider).assignGuardRole(data['email']));
});

// 7. Provider para la ACCIÓN de marcar como pagado (Simulación)
final markAsPaidActionProvider =
    StateNotifierProvider.autoDispose<AdminActionNotifier, AsyncValue<void>>(
        (ref) {
  // Pasa la función de callback
  return AdminActionNotifier(
      (data) => ref.read(financeRepoProvider).markExpenseAsPaid(data['id']));
});

// --- Notificador GENÉRICO para Acciones de Admin ---
// (¡CORREGIDO! Ya no guarda 'ref')
typedef AdminActionCallback = Future<void> Function(Map<String, dynamic> data);

class AdminActionNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminActionCallback _actionCallback;

  // --- CONSTRUCTOR CORREGIDO ---
  // (Quitamos _ref de aquí)
  AdminActionNotifier(this._actionCallback) : super(const AsyncData(null));

  Future<void> execute(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _actionCallback(data);
      state = const AsyncData(null); // Éxito
    } catch (e, stack) {
      state = AsyncError(e, stack); // Error
    }
  }
}
