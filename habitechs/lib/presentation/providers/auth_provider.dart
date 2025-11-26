import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:habitechs/data/services/api_service.dart';
import 'package:habitechs/data/storage/secure_storage_service.dart';
import 'package:habitechs/data/models/user.dart'; // Tu modelo User

// --- Estado de Autenticación ---
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

// --- Notifier de Autenticación ---
class AuthNotifier extends StateNotifier<AuthStatus> {
  final Dio _dio;
  final SecureStorageService _storage;
  User? _currentUser; // Guardamos el usuario actual

  AuthNotifier(this._dio, this._storage) : super(AuthStatus.unknown) {
    _checkAuthStatus();
  }

  User? get currentUser => _currentUser;

  Future<void> _checkAuthStatus() async {
    final token = await _storage.readToken();
    if (token != null) {
      await _loadUserData();
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _dio.get('/api/Users/me');
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        state = AuthStatus.authenticated;
      }
    } catch (e) {
      await logout();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/Auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        final roles = (response.data['roles'] as List).cast<String>();

        await _storage.saveToken(token);
        await _storage.saveRoles(roles);

        // Si el login devuelve datos del usuario
        if (response.data['user'] != null) {
          _currentUser = User.fromJson(response.data['user']);
        } else {
          await _loadUserData(); // Cargarlo desde /me
        }

        state = AuthStatus.authenticated;
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return "Email o contraseña inválidos";
      }
      return "Error de red. Intenta de nuevo.";
    }
    return "Error desconocido.";
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    _currentUser = null;
    state = AuthStatus.unauthenticated;
  }

  void updateUser(User user) {
    _currentUser = user;
    // Forzar actualización de estado (opcional)
    state = AuthStatus.authenticated;
  }
}

// --- Provider Principal ---
final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(dio, storage);
});

// --- Providers Auxiliares (Provider simple, NO FutureProvider) ---
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider.notifier).currentUser;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.roles.contains('Administrador') ?? false;
});
