import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/expense.dart';
import 'package:habitechs/data/services/api_service.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class FinanceRepository {
  final Dio _dio;
  FinanceRepository(this._dio);

  // --- MÉTODOS PARA EL RESIDENTE ---

  // Llama a GET /api/finance/my-debt
  Future<List<Expense>> getMyDebt() async {
    try {
      final response = await _dio.get('/api/finance/my-debt');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Expense.fromJson(json)).toList();
      }
      throw Exception('Error al cargar deudas');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // --- MÉTODOS PARA EL ADMIN ---

  // Llama a GET /api/finance/all (Admin)
  Future<List<Expense>> getAllExpenses() async {
    try {
      final response = await _dio.get('/api/finance/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Expense.fromJson(json)).toList();
      }
      throw Exception('Error al cargar todas las expensas');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Llama a POST /api/finance/charge (Admin)
  Future<void> createExpense(
      String email, String title, double amount, DateTime date) async {
    try {
      final response = await _dio.post(
        '/api/finance/charge',
        data: {
          'residentEmail': email,
          'title': title,
          'description':
              'Cargo de administración', // (Podemos añadir esto al formulario)
          'amount': amount,
          'dueDate': DateFormat('yyyy-MM-dd').format(date),
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Error al cargar expensa');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }

  // Llama a PUT /api/finance/{id}/mark-as-paid (Admin)
  // (Este es nuestro "Pago Simulado")
  Future<void> markExpenseAsPaid(String expenseId) async {
    try {
      final response = await _dio.put('/api/finance/$expenseId/mark-as-paid');
      if (response.statusCode != 200) {
        throw Exception('Error al marcar como pagado');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }

  // ¡NO INCLUIMOS NADA DE STRIPE/MP, TAL COMO PEDISTE!
  // Future<String> createPaymentSession(String expenseId) async { ... }
}

// Provider de Riverpod (no cambia)
final financeRepoProvider = Provider<FinanceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FinanceRepository(dio);
});
