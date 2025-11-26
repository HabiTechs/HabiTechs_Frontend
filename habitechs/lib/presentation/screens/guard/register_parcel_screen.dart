import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/parcel_provider.dart';
import 'package:iconsax/iconsax.dart';

class RegisterParcelScreen extends ConsumerStatefulWidget {
  const RegisterParcelScreen({super.key});

  @override
  ConsumerState<RegisterParcelScreen> createState() =>
      _RegisterParcelScreenState();
}

class _RegisterParcelScreenState extends ConsumerState<RegisterParcelScreen> {
  final _emailController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Llamar al "cerebro"
    await ref.read(parcelActionProvider.notifier).registerParcel(
          _emailController.text.trim(),
          _descController.text.trim(),
        );

    // Si sigue "vivo" (mounted) y NO hubo error, mostrar éxito
    if (mounted && !ref.read(parcelActionProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Paquete registrado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      _emailController.clear();
      _descController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // "Mirar" el estado de la acción
    final parcelState = ref.watch(parcelActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Paquete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Iconsax.box_add, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Ingresa los datos del paquete',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email del Residente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.user_search),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (ej. Caja de Amazon)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Iconsax.document_text),
              ),
            ),
            const SizedBox(height: 24),

            // Mostrar error si la API falla (ej. "Residente no encontrado")
            if (parcelState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Error: ${parcelState.error.toString()}",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            // Botón de envío
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: parcelState.isLoading ? null : _submit,
              child: parcelState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
