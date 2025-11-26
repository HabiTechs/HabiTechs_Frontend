import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// (Asegúrate de que el nombre de tu app 'habitechs' sea correcto)
import 'package:habitechs/data/models/announcement.dart';
import 'package:habitechs/data/services/api_service.dart';

class AnnouncementRepository {
  final Dio _dio;

  AnnouncementRepository(this._dio);

  // --- MÉTODO EXISTENTE (Para Residente) ---
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _dio.get('/api/announcements');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar anuncios');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // --- ¡MÉTODO NUEVO! (Para Admin) ---
  // Llama a POST /api/announcements (Admin)
  Future<void> createAnnouncement(String title, String content) async {
    try {
      final response = await _dio.post(
        '/api/announcements',
        data: {'title': title, 'content': content},
      );
      // Dev 1 devuelve 201 Created
      if (response.statusCode != 201) {
        throw Exception('Error al crear anuncio');
      }
    } on DioException catch (e) {
      // Captura el error de Dev 1 (ej. "Título es requerido")
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }
}

// Proveedor de Riverpod para este repositorio (no cambia)
final announcementRepoProvider = Provider<AnnouncementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnnouncementRepository(dio);
});
