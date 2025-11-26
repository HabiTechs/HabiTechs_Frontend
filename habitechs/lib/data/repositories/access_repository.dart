import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/services/api_service.dart';

class AccessRepository {
  final Dio _dio;
  AccessRepository(this._dio);

  // --- MÉTODO EXISTENTE (Para Residente) ---
  // Llama a POST /api/access/visit/generate-qr
  Future<String> generateQrCode(String visitorName) async {
    try {
      final response = await _dio.post(
        '/api/access/visit/generate-qr',
        data: {'visitorName': visitorName},
      );
      if (response.statusCode == 200) {
        return response.data['qrCode'] as String;
      }
      throw Exception('Error al generar QR');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }

  // --- MÉTODO EXISTENTE (Para Guardia) ---
  // Llama a POST /api/access/visit/check-in
  Future<String> checkInVisit(String qrToken) async {
    try {
      final response = await _dio.post(
        '/api/access/visit/check-in', // El endpoint del Guardia
        data: {'qrCodeToken': qrToken},
      );
      if (response.statusCode == 200) {
        // Devuelve el mensaje de éxito (ej. "Check-in de 'Juan' exitoso")
        return response.data['message'] as String;
      }
      throw Exception('Error al registrar visita');
    } on DioException catch (e) {
      // Devuelve el mensaje de error (ej. "QR inválido")
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }

  // --- ¡ESTE ES EL MÉTODO QUE FALTABA! (Para Guardia) ---
  // Llama a POST /api/parcels/register
  Future<void> registerParcel(String residentEmail, String description) async {
    try {
      final response = await _dio.post(
        '/api/parcels/register',
        data: {
          'residentEmail': residentEmail,
          'description': description,
        },
      );
      // El backend devuelve 201 Created, no necesitamos devolver nada
      if (response.statusCode != 201) {
        throw Exception('Error al registrar paquete');
      }
    } on DioException catch (e) {
      // Manejar el error de Dev 1 (ej. "Residente no encontrado")
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }
}

// Provider de Riverpod (no cambia)
final accessRepoProvider = Provider<AccessRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AccessRepository(dio);
});
