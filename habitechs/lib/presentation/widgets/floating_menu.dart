import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitechs/main.dart' hide kTeal, kOxfordBlue;
import 'package:habitechs/presentation/providers/auth_provider.dart';
import 'package:habitechs/presentation/screens/home/home_screen.dart'
    hide kTeal, kOxfordBlue; // Importamos home_screen para currentUserProvider
import 'package:habitechs/presentation/screens/about/about_screen.dart';
import 'package:habitechs/presentation/screens/privacy/privacy_policy_screen.dart';
import 'package:habitechs/presentation/screens/location/share_location_screen.dart';
import 'package:habitechs/core/utils/tutorial_keys.dart';
import 'package:iconsax/iconsax.dart';

// Colores locales
const Color kTeal = Colors.teal;
const Color kOxfordBlue = Color(0xFF002147);

// Provider para controlar el estado del sub-menú expandible de Administración
final adminMenuExpandedProvider = StateProvider<bool>((ref) => false);

class FloatingMenu extends ConsumerWidget {
  const FloatingMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 80.0;

    final menuWidth = (screenWidth * 0.65).clamp(260.0, 300.0);
    final availableHeight = screenHeight - topPadding - bottomNavHeight - 32;
    final maxMenuHeight = availableHeight.clamp(400.0, 600.0);

    final isAdmin = ref.watch(isAdminProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAdminMenuExpanded = ref.watch(adminMenuExpandedProvider);

    final userName = currentUser?.fullName ?? 'Usuario';
    final userEmail = currentUser?.email ?? 'correo@ejemplo.com';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final photoUrl = currentUser?.photoUrl;

    return Positioned(
      top: topPadding + 8,
      left: 8,
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: menuWidth,
          constraints: BoxConstraints(
            maxHeight: maxMenuHeight,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFE), Color(0xFFF0F8FF)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kTeal.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              // --- Header ---
              Container(
                key: TutorialKeys.menuPerfil,
                padding: const EdgeInsets.only(
                    top: 16, left: 20, right: 20, bottom: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kOxfordBlue, Color(0xFF003366)],
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  border: Border(
                      bottom:
                          BorderSide(color: kTeal.withOpacity(0.3), width: 2)),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => ref
                            .read(floatingMenuProvider.notifier)
                            .state = false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(floatingMenuProvider.notifier).state = false;
                        context.push('/edit-profile');
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                      colors: [kTeal, Color(0xFF17a2a2)]),
                                  image: photoUrl != null && photoUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(photoUrl),
                                          fit: BoxFit.cover)
                                      : null,
                                ),
                                child: (photoUrl == null || photoUrl.isEmpty)
                                    ? Center(
                                        child: Text(userInitial,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)))
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: const Icon(Iconsax.edit_2,
                                      size: 10, color: kTeal),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis),
                                Text(userEmail,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Lista de Opciones ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // INICIO
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.home,
                          title: 'Inicio',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            ref.read(selectedTabProvider.notifier).state = 0;
                            context.go('/home');
                          }),

                      // ✨ NUEVO: ADMINISTRACIÓN (SOLO PARA ADMINS)
                      if (isAdmin) ...[
                        _buildExpandableMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.slider_horizontal,
                          title: 'Administración',
                          isExpanded: isAdminMenuExpanded,
                          textColor: Colors.deepOrange,
                          iconColor: Colors.deepOrange,
                          onTap: () {
                            ref.read(adminMenuExpandedProvider.notifier).state =
                                !isAdminMenuExpanded;
                          },
                        ),

                        // Sub-menú de Administración (6 opciones)
                        if (isAdminMenuExpanded) ...[
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.notification,
                            title: 'Publicar Anuncio',
                            subtitle: 'Comunicados generales (con foto)',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/create-announcement');
                            },
                          ),
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.message_question,
                            title: 'Gestionar Tickets',
                            subtitle:
                                'Revisar y cerrar reportes de residentes (con evidencia)',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/manage-tickets');
                            },
                          ),
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.receipt_edit,
                            title: 'Registrar Gasto Operativo',
                            subtitle:
                                'Facturas de luz, agua, servicios (para Balance)',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/create-expense');
                            },
                          ),
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.wallet_check,
                            title: 'Validar Pagos Pendientes',
                            subtitle:
                                'Aprobar o rechazar comprobantes de transferencia QR',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/manage-expenses');
                            },
                          ),
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.user_octagon,
                            title: 'Asignar Roles',
                            subtitle: 'Promover Administrador o Guardia',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/manage-roles');
                            },
                          ),
                          _buildSubMenuItem(
                            context: context,
                            ref: ref,
                            icon: Iconsax.receipt_disscount,
                            title: 'Gestionar Expensas',
                            subtitle: 'Crear, editar o auditar deudas',
                            onTap: () {
                              ref.read(floatingMenuProvider.notifier).state =
                                  false;
                              context.push('/admin/manage-expenses');
                            },
                          ),
                        ],
                      ],

                      // FINANZAS
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.wallet_money,
                          title: 'Finanzas',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            ref.read(selectedTabProvider.notifier).state = 2;
                            context.go('/home');
                          }),

                      // CONTACTOS
                      _buildMenuItem(
                          key: TutorialKeys.menuContactos,
                          context: context,
                          ref: ref,
                          icon: Iconsax.call,
                          title: 'Contactos',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            context.push('/contacts');
                          }),

                      // CHAT ADMIN (Redirige a Contactos con filtro)
                      _buildMenuItem(
                          key: TutorialKeys.menuChatAdmin,
                          context: context,
                          ref: ref,
                          icon: Iconsax.message,
                          title: 'Chat con Administrador',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            context.push('/contacts',
                                extra: {'roleFilter': 'Administrador'});
                          }),

                      // CHAT SEGURIDAD (Redirige a Contactos con filtro)
                      _buildMenuItem(
                          key: TutorialKeys.menuChatSeguridad,
                          context: context,
                          ref: ref,
                          icon: Iconsax.shield_tick,
                          title: 'Chat con Seguridad',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            context.push('/contacts',
                                extra: {'roleFilter': 'Guardia'});
                          }),

                      // COMPARTIR UBICACIÓN
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.location,
                          title: 'Compartir Ubicación',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ShareLocationScreen()));
                          }),

                      // TUTORIAL ASISTIDO
                      _buildMenuItem(
                          key: TutorialKeys.menuTutorial,
                          context: context,
                          ref: ref,
                          icon: Iconsax.book,
                          title: 'Tutorial Asistido',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            // Disparar tutorial
                            ref.read(tutorialTriggerProvider.notifier).state++;
                          }),

                      // SOBRE HABITEX
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.info_circle,
                          title: 'Sobre HabiTex',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutScreen()));
                          }),

                      // POLÍTICA DE PRIVACIDAD
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.shield_cross,
                          title: 'Política de Privacidad',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen()));
                          }),

                      // AJUSTES
                      _buildMenuItem(
                          context: context,
                          ref: ref,
                          icon: Iconsax.setting_2,
                          title: 'Ajustes',
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            context.push('/settings');
                          }),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),

                      // SALIR
                      _buildMenuItem(
                          key: TutorialKeys.menuSalir,
                          context: context,
                          ref: ref,
                          icon: Iconsax.logout,
                          title: 'Salir',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: () {
                            ref.read(floatingMenuProvider.notifier).state =
                                false;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saliendo...')));
                            ref.read(authProvider.notifier).logout();
                            context.go('/login');
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para item normal
  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Key? key,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
              const SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para item expandible con flecha
  Widget _buildExpandableMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? Colors.grey[800])),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 20,
                color: iconColor ?? Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para sub-items (con indentación)
  Widget _buildSubMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.only(left: 40, right: 12, top: 10, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800])),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
