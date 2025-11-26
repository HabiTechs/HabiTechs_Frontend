import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/qr_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_nameController.text.trim().isEmpty) return;
    ref.read(qrCodeProvider.notifier).generateQr(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(qrCodeProvider);

    // ¡SIN SCAFFOLD NI APPBAR! - El HomeScreen lo maneja
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: qrState.when(
          data: (qrToken) {
            if (qrToken == null) {
              return _buildForm(context);
            }
            return _buildQrCode(context, qrToken);
          },
          loading: () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/loading.json', width: 150),
              const Text('Generando QR...'),
            ],
          ),
          error: (e, s) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 80),
              const SizedBox(height: 16),
              Text(
                'Error al generar QR: ${e.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generate,
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/login_building.json', width: 200),
        const Text(
          'Ingresa el nombre de tu visita',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Visitante',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Iconsax.user),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _generate,
          child: const Text('Generar QR'),
        ),
      ],
    );
  }

  Widget _buildQrCode(BuildContext context, String qrToken) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¡QR Generado!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Muestra este código al guardia de seguridad.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: QrImageView(
            data: qrToken,
            version: QrVersions.auto,
            size: 250.0,
          ),
        ),
        const SizedBox(height: 16),
        Text('Para: ${_nameController.text.trim()}'),
        const SizedBox(height: 20),
        // Botón para resetear y generar otro QR
        OutlinedButton.icon(
          onPressed: () {
            _nameController.clear();
            ref.read(qrCodeProvider.notifier).reset();
          },
          icon: const Icon(Iconsax.refresh),
          label: const Text('Generar Nuevo QR'),
        ),
      ],
    );
  }
}
