import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitechs/presentation/screens/home/home_screen.dart'
    hide kTeal, kOxfordBlue; // CORRECCIÓN: Ocultar para evitar conflicto con la definición local
import 'package:iconsax/iconsax.dart';

// Definición local de colores
const Color kTeal = Colors.teal;

// Esta es la Pestaña 0: El Dashboard Principal
class InicioBody extends ConsumerWidget {
  const InicioBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void goToTab(int tabIndex) {
      ref.read(selectedTabProvider.notifier).state = tabIndex;
    }

    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildMenuCard(
          context: context,
          icon: Iconsax.notification,
          title: 'Anuncios',
          subtitle: 'Avisos de la comunidad',
          onTap: () => goToTab(1), // ✅ Pestaña 1: Anuncios
        ),
        _buildMenuCard(
          context: context,
          icon: Iconsax.scan_barcode,
          title: 'Mi QR',
          subtitle: 'Código de acceso',
          onTap: () => goToTab(5), // ✅ Pestaña 5: QR
        ),
        _buildMenuCard(
          context: context,
          icon: Iconsax.message_question,
          title: 'Tickets',
          subtitle: 'Reportes y solicitudes',
          onTap: () => goToTab(4), // ✅ Pestaña 4: Tickets
        ),
        _buildMenuCard(
          context: context,
          icon: Iconsax.calendar_1,
          title: 'Reservas',
          subtitle: 'Áreas comunes',
          onTap: () => goToTab(3), // ✅ Pestaña 3: Reservas
        ),
        _buildMenuCard(
          context: context,
          icon: Iconsax.wallet_money,
          title: 'Finanzas',
          subtitle: 'Pagos y estados',
          onTap: () => goToTab(2), // ✅ Pestaña 2: Finanzas
        ),
        _buildMenuCard(
          context: context,
          icon: Iconsax.call,
          title: 'Contactos',
          subtitle: 'Directorio',
          onTap: () => context.push('/contacts'),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kTeal, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
