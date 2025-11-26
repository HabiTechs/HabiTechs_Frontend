import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:habitechs/core/config/app_config.dart'; // Tu archivo de configuración

// --- Servicio Local para obtener métricas ---
class GuardService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  Future<Map<String, int>> getMetrics() async {
    try {
      final token = await _getToken();
      if (token == null) return {};

      final response = await _dio.get(
        '$_baseUrl/api/Guard/metrics',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data as Map<String, dynamic>;

      // Mapeamos los datos del Backend (EntriesToday, PendingParcels, etc.)
      return {
        'EntriesToday': data['entriesToday'] as int? ?? 0,
        'ExitsToday': data['exitsToday'] as int? ?? 0,
        'PendingParcels': data['pendingParcels'] as int? ?? 0,
        'ActiveVisits': data['activeVisits'] as int? ?? 0,
      };
    } catch (e) {
      throw Exception('Error al cargar métricas del guardia: $e');
    }
  }
}

// --- Provider que expone el estado ---
final guardMetricsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final service = GuardService();
  return await service.getMetrics();
});
