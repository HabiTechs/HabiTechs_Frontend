// Archivo: lib/presentation/providers/finance_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Aseguramos que los nombres coincidan con los nuevos archivos
import 'package:habitechs/data/models/expense_model.dart';
import 'package:habitechs/data/models/operational_expense_model.dart';
import 'package:habitechs/data/services/finance_service.dart'; // Tu servicio HTTP

final financeServiceProvider = Provider((ref) => FinanceService());

// 1. Deudas del Residente
final myDebtsProvider =
    FutureProvider.autoDispose<List<ExpenseModel>>((ref) async {
  final service = ref.read(financeServiceProvider);
  return await service.getMyDebts();
});

// 2. Gastos Operacionales del Condominio (Para Admin)
final operationalExpensesProvider =
    FutureProvider.autoDispose<List<OperationalExpenseModel>>((ref) async {
  final service = ref.read(financeServiceProvider);
  return await service
      .getOperationalExpenses(); // Asumiendo que este método existe en FinanceService
});

// 3. Métricas del Admin Dashboard
final adminDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.read(financeServiceProvider);
  // Asumiendo que este método devuelve el JSON de métricas del Dashboard
  return await service.getAdminDashboardMetrics();
});

// 4. Controlador CRUD para Gastos Operacionales
class OpExController extends StateNotifier<AsyncValue<void>> {
  final FinanceService _service;
  final Ref _ref;

  OpExController(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> createOpEx(
      {required String title, required double amount, File? proofImage}) async {
    state = const AsyncValue.loading();
    try {
      // Necesitarás implementar este método en FinanceService
      // await _service.createOperationalExpense(title: title, amount: amount, proofImage: proofImage);

      state = const AsyncValue.data(null);

      // Invalidamos la lista de gastos y el dashboard al crear uno nuevo
      _ref.invalidate(operationalExpensesProvider);
      _ref.invalidate(adminDashboardProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final opExControllerProvider =
    StateNotifierProvider<OpExController, AsyncValue<void>>((ref) {
  return OpExController(ref.read(financeServiceProvider), ref);
});
