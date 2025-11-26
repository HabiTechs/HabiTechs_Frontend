import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/core/config/app_config.dart'; // Importa tu config
import 'package:habitechs/data/storage/secure_storage_service.dart'; // Importa la bóveda

// 1. El proveedor del "Mesero" (Dio)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl, // Usa la URL de tu config
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 2. Obtener acceso a la bóveda
  final storage = ref.read(secureStorageProvider);

  // 3. ¡EL INTERCEPTOR! (El "Guardia de Seguridad")
  dio.interceptors.add(
    InterceptorsWrapper(
      // --- Se ejecuta ANTES de cada petición ---
      onRequest: (options, handler) async {
        // No necesitamos token para login o register
        if (options.path.contains('/auth/')) {
          return handler.next(options); // Dejar pasar
        }

        // Para todas las demás, buscamos el token
        final token = await storage.readToken();

        if (token != null) {
          // ¡Lo adjuntamos! (El "Bearer ey...")
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // Dejar pasar
      },

      // --- Se ejecuta SI hay un ERROR ---
      onError: (DioException e, handler) async {
        // Si el error es 401 (Token inválido o expirado)
        if (e.response?.statusCode == 401) {
          // Podríamos implementar lógica de "refresh token" aquí
          // Por ahora, solo borramos el token y forzamos el logout
          await storage.deleteToken();
          // (El Router se encargará de redirigir a /login)
        }
        return handler.next(e); // Dejar pasar el error
      },
    ),
  );

  return dio;
});
