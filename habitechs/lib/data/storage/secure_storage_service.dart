import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Un servicio simple para manejar el almacenamiento seguro
class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  // También guardamos el rol para saber qué UI mostrar
  Future<void> saveRoles(List<String> roles) async {
    // Para este proyecto, solo nos importa el primer rol
    if (roles.isNotEmpty) {
      await _storage.write(key: _roleKey, value: roles[0]);
    }
  }

  Future<String?> readRole() async {
    return await _storage.read(key: _roleKey);
  }
}

// Proveedor de Riverpod para acceder a este servicio
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
