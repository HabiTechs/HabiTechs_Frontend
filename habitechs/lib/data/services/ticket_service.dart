import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habitechs/core/config/app_config.dart';

// Definición del Modelo para asegurar que compile
class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String? imageUrl;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.imageUrl,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Open',
      imageUrl: json['imageUrl'],
    );
  }
}

class TicketService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  // Si AppConfig da error, cambia _baseUrl por tu URL directa ej: "https://tu-api.com"
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // 1. Obtener mis tickets
  Future<List<TicketModel>> getMyTickets() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Tickets/my-tickets',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } catch (e) {
      // Retornamos lista vacía en caso de error para no romper la UI, o lanzamos excepción
      // throw Exception('Error al cargar tickets: $e');
      return [];
    }
  }

  // 2. CREAR TICKET
  Future<void> createTicket(
      {required String title, required String description, File? image}) async {
    try {
      final token = await _getToken();

      final formData = FormData.fromMap({
        'title': title,
        'description': description,
      });

      if (image != null) {
        String fileName = image.path.split('/').last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image.path, filename: fileName),
        ));
      }

      await _dio.post(
        '$_baseUrl/api/Tickets',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } catch (e) {
      throw Exception('Error al crear ticket: $e');
    }
  }
}
