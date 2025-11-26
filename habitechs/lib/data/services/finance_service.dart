import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habitechs/core/config/app_config.dart'; // Tu archivo de configuración
import 'package:habitechs/data/models/expense_model.dart'; // Modelo de Deuda
import 'package:habitechs/data/models/operational_expense_model.dart'; // Modelo de Gasto Operacional
import 'package:habitechs/data/models/payment_instruction_model.dart'; // Modelo de Instrucciones de Pago

class FinanceService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // Helper para manejar errores Dio y extraer mensajes del Backend
  dynamic _handleDioError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message =
          e.response!.data['message'] ?? 'Error desconocido del servidor.';
      return Exception(message);
    }
    return Exception('Error de red o conexión: ${e.message}');
  }

  // ===========================================
  // 1. LECTURA DE DATOS (RESIDENTE & ADMIN)
  // ===========================================

  // [RESIDENTE] Obtener Mis Deudas Pendientes
  Future<List<ExpenseModel>> getMyDebts() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Finance/my-debt',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // [ADMIN] Obtener Lista de Gastos Operacionales
  Future<List<OperationalExpenseModel>> getOperationalExpenses() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Finance/operational-expense',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data
          .map((json) => OperationalExpenseModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // [ADMIN] Obtener Dashboard de Métricas
  Future<Map<String, dynamic>> getAdminDashboardMetrics() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Finance/dashboard',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // [RESIDENTE/ADMIN] Obtener Instrucciones de Pago (QR/Banco)
  Future<PaymentInstructionModel> getPaymentInfo() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Finance/payment-info',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return PaymentInstructionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ===========================================
  // 2. ESCRITURA Y ACCIONES
  // ===========================================

  // [RESIDENTE] Registrar Transferencia (Subir Comprobante)
  Future<void> registerTransfer(String expenseId, File proofImage) async {
    try {
      final token = await _getToken();

      String fileName = proofImage.path.split('/').last;

      FormData formData = FormData.fromMap({
        "ExpenseId": expenseId, // Backend DTO espera Guid
        "ProofImage": await MultipartFile.fromFile(
          proofImage.path,
          filename: fileName,
        ),
      });

      await _dio.post(
        '$_baseUrl/api/Finance/register-transfer',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // [ADMIN] Crear Gasto Operacional
  Future<void> createOperationalExpense(
      {required String title, required double amount, File? proofImage}) async {
    try {
      final token = await _getToken();

      FormData formData = FormData.fromMap({
        "Title": title,
        "Amount": amount,
      });

      if (proofImage != null) {
        formData.files.add(MapEntry(
          'ProofImage', // Debe coincidir con el DTO en C#
          await MultipartFile.fromFile(proofImage.path),
        ));
      }

      await _dio.post(
        '$_baseUrl/api/Finance/operational-expense',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
