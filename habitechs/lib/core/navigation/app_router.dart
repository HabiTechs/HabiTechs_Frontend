import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/storage/secure_storage_service.dart';
import 'package:habitechs/presentation/providers/auth_provider.dart';
import 'package:habitechs/presentation/screens/auth/edit_profile_screen.dart'; // Importar
// --- Importar TODAS las pantallas ---
import 'package:habitechs/presentation/screens/admin/admin_home_screen.dart';
// Auth & Splash
import 'package:habitechs/presentation/screens/auth/login_screen.dart';
import 'package:habitechs/presentation/screens/splash/splash_screen.dart';

// Residente
import 'package:habitechs/presentation/screens/home/home_screen.dart';
// import 'package:habitechs/presentation/screens/finance/debt_screen.dart';

// Guardia
import 'package:habitechs/presentation/screens/guard/guard_home_screen.dart';
import 'package:habitechs/presentation/screens/guard/scan_qr_screen.dart';
import 'package:habitechs/presentation/screens/guard/register_parcel_screen.dart';

// Admin
import 'package:habitechs/presentation/screens/admin/admin_home_screen.dart';
import 'package:habitechs/presentation/screens/admin/manage_tickets_screen.dart';
import 'package:habitechs/presentation/screens/admin/create_announcement_screen.dart';
import 'package:habitechs/presentation/screens/admin/create_expense_screen.dart';
import 'package:habitechs/presentation/screens/admin/manage_roles_screen.dart';
import 'package:habitechs/presentation/screens/admin/manage_expenses_screen.dart';

// Comunes (Contactos y Chat)
import 'package:habitechs/presentation/screens/contacts/contacts_screen.dart';
import 'package:habitechs/presentation/screens/community/chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final storage = ref.read(secureStorageProvider);

  return GoRouter(
    redirect: (BuildContext context, GoRouterState state) async {
      final location = state.matchedLocation;

      // Splash mientras carga
      if (authState == AuthStatus.unknown) {
        return '/splash';
      }

      // No autenticado -> Login
      if (authState == AuthStatus.unauthenticated) {
        return location == '/login' ? null : '/login';
      }

      // Autenticado -> Redirigir según Rol
      if (authState == AuthStatus.authenticated) {
        final role = await storage.readRole();

        // Solo redirige si intenta ir a login o splash estando ya logueado
        if (location == '/login' || location == '/splash') {
          if (role == 'Guardia') return '/guard/home';
          if (role == 'Admin') return '/admin/home';
          return '/home'; // Residente por defecto
        }
      }
      return null;
    },
    routes: [
      // --- Rutas Base ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin-panel',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      // --- Rutas de Residente ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      // GoRoute(
      //   path: '/debt',
      //   builder: (context, state) => const DebtScreen(),
      // ),

      // --- Rutas de Guardia ---
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/guard/home',
        builder: (context, state) => const GuardHomeScreen(),
      ),
      GoRoute(
        path: '/guard/scan-qr',
        builder: (context, state) => const ScanQrScreen(),
      ),
      GoRoute(
        path: '/guard/register-parcel',
        builder: (context, state) => const RegisterParcelScreen(),
      ),

      // --- Rutas de Admin ---
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/manage-tickets',
        builder: (context, state) => const ManageTicketsScreen(),
      ),
      GoRoute(
        path: '/admin/create-announcement',
        builder: (context, state) => const CreateAnnouncementScreen(),
      ),
      GoRoute(
        path: '/admin/create-expense',
        builder: (context, state) => const CreateExpenseScreen(),
      ),
      GoRoute(
        path: '/admin/manage-roles',
        builder: (context, state) => const ManageRolesScreen(),
      ),
      GoRoute(
        path: '/admin/manage-expenses',
        builder: (context, state) => const ManageExpensesScreen(),
      ),

      // --- RUTAS COMUNES ---

      // 1. Contactos (ACTUALIZADO PARA RECIBIR FILTRO)
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (context, state) {
          // Extraemos el filtro del mapa "extra" (ej: {'roleFilter': 'Administrador'})
          final extra = state.extra as Map<String, dynamic>?;
          final filter = extra?['roleFilter'] as String?;

          return ContactsScreen(roleFilter: filter);
        },
      ),

      // 2. Chat
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          // Recibimos ID y Nombre del usuario destino
          final extra = state.extra as Map<String, String>? ?? {};
          return ChatScreen(
            otherUserId: extra['userId'] ?? '',
            otherUserName: extra['userName'] ?? 'Usuario',
          );
        },
      ),
    ],
    initialLocation: '/splash',
  );
});
