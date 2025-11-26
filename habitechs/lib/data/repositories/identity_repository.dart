import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/services/api_service.dart';

class IdentityRepository {
  final Dio _dio;
  IdentityRepository(this._dio);

  // Llama a POST /api/auth/assign-guard-role (Admin)
  Future<String> assignGuardRole(String email) async {
    try {
      final response = await _dio.post(
        '/api/auth/assign-guard-role',
        data: email, // La API de Dev 1 espera un string simple
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return response.data['message'] as String;
      }
      throw Exception('Error al asignar rol');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }
}

// Provider
final identityRepoProvider = Provider<IdentityRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return IdentityRepository(dio);
});
