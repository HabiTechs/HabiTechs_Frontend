import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habitechs/core/config/app_config.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  final String _baseUrl =
      AppConfig.apiBaseUrl; // Asegúrate que esto apunte a tu backend

  // Obtener Token
  Future<String?> _getToken() async => await _storage.read(key: 'jwt_token');

  // 1. Obtener Conversación
  Future<List<ChatMessageModel>> getConversation(String otherUserId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/api/Chat/conversation/$otherUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => ChatMessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar chat: $e');
    }
  }

  // 2. Enviar Mensaje (Texto e Imagen)
  Future<void> sendMessage({
    required String receiverId,
    String? message,
    File? imageFile,
  }) async {
    try {
      final token = await _getToken();

      // Preparamos el Form-Data para subir archivos
      final formData = FormData.fromMap({
        'ReceiverId': receiverId,
        if (message != null && message.isNotEmpty) 'Message': message,
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'Image',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      await _dio.post(
        '$_baseUrl/api/Chat',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data', // Importante para fotos
        }),
      );
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }
}
