import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/announcement.dart'; // (Asegúrate que el nombre de tu app sea habitechs)
import 'package:habitechs/data/services/api_service.dart';

class AnnouncementRepository {
  final Dio _dio;

  AnnouncementRepository(this._dio);

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
}

// Proveedor de Riverpod para este repositorio
final announcementRepoProvider = Provider<AnnouncementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnnouncementRepository(dio);
});
