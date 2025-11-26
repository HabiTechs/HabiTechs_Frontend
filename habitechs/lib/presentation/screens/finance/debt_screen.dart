import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/widgets/empty_state_widget.dart';
import 'package:iconsax/iconsax.dart';

// Provider local simulado para evitar errores de compilación y mostrar el estado vacío
final debtsProvider = FutureProvider<List<String>>((ref) async {
  // Aquí conectarías con tu servicio real. Por ahora retornamos lista vacía.
  await Future.delayed(const Duration(milliseconds: 300));
  return [];
});

class DebtBody extends ConsumerWidget {
  const DebtBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (debts) {
          if (debts.isEmpty) {
            // ✅ AQUÍ ESTÁ LA SOLUCIÓN: Usamos el widget en lugar de la animación fallida
            return const EmptyStateWidget(
              icon: Iconsax.wallet_check,
              title: '¡Estás al día!',
              subtitle: 'No tienes deudas ni pagos pendientes.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              return const Card(child: ListTile(title: Text("Deuda")));
            },
          );
        },
      ),
    );
  }
}
