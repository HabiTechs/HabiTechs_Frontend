import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitechs/main.dart'; // Para colores kOxfordBlue, kTeal
import 'package:habitechs/presentation/providers/auth_provider.dart';
import 'package:habitechs/presentation/providers/guard_provider.dart'; // Métricas
import 'package:iconsax/iconsax.dart';

class GuardHomeScreen extends ConsumerWidget {
  const GuardHomeScreen({super.key});

  // Helper para diálogo de salida
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar Turno"),
        content: const Text("¿Deseas finalizar tu sesión de guardia?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(guardMetricsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: kOxfordBlue,
        title: const Text("Panel de Guardia",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.white),
            tooltip: "Cerrar Turno",
            onPressed: () => _showLogoutDialog(context, ref),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN 1: RESUMEN DEL DÍA ---
            const Text("Resumen del Turno",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kOxfordBlue)),
            const SizedBox(height: 12),

            metricsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Error cargando métricas: $err",
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (metrics) => Row(
                children: [
                  Expanded(
                      child: _buildMetricCard(
                          "Entradas",
                          metrics['EntriesToday'].toString(),
                          Colors.green,
                          Iconsax.login)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildMetricCard(
                          "Salidas",
                          metrics['ExitsToday'].toString(),
                          Colors.orange,
                          Iconsax.logout)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildMetricCard(
                          "Paquetes",
                          metrics['PendingParcels'].toString(),
                          Colors.blue,
                          Iconsax.box)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN 2: ACCIONES RÁPIDAS ---
            const Text("Operaciones",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kOxfordBlue)),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              title: "Escanear QR",
              subtitle: "Registrar ingreso o salida de visita",
              icon: Iconsax.scan_barcode,
              color: kTeal,
              onTap: () => context.push('/guard/scan-qr'),
            ),

            const SizedBox(height: 16),

            _buildActionCard(
              context,
              title: "Registrar Paquete",
              subtitle: "Recepción de encomiendas y delivery",
              icon: Iconsax.box_add,
              color: kOxfordBlue,
              onTap: () => context.push('/guard/register-parcel'),
            ),

            const SizedBox(height: 16),

            // Botón secundario para bitácora completa (si existe la pantalla)
            OutlinedButton.icon(
              onPressed: () {
                // Navegar a historial completo si lo tienes
                // context.push('/guard/logs');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Historial completo próximamente")));
              },
              icon: const Icon(Iconsax.clipboard_text, size: 18),
              label: const Text("Ver Bitácora Completa"),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                  foregroundColor: Colors.grey[700],
                  minimumSize: const Size(double.infinity, 48)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
