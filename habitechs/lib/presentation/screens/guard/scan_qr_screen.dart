import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/scan_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // ¡El escáner!

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanComplete = false; // Flag para evitar escaneos múltiples

  // Función que se llama cuando el escáner detecta un QR
  void _onDetect(BarcodeCapture capture) {
    if (_isScanComplete) return; // Si ya estamos procesando uno, ignora

    final String? code = capture.barcodes.first.rawValue;

    if (code != null) {
      setState(() {
        _isScanComplete = true; // Bloquea el escáner
      });
      // Llama al "cerebro" (provider) para validar el token
      ref.read(scanActionProvider.notifier).checkInVisit(code);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Mirar" el estado de la API (cargando, éxito, error)
    final scanState = ref.watch(scanActionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR de Visita')),
      body: Stack(
        children: [
          // --- El Escáner (Capa 1) ---
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect, // Llama a _onDetect cuando ve un QR
          ),

          // --- UI de Guía (Capa 2) ---
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // --- UI de Resultado (Capa 3, superpuesta) ---
          // Muestra el resultado de la API (Cargando, Éxito, Error)
          if (_isScanComplete)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: scanState.when(
                  // --- ESTADO DE CARGA ---
                  loading: () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/animations/loading.json',
                          width: 100),
                      const Text('Validando QR...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),

                  // --- ESTADO DE ERROR ---
                  error: (e, s) => _buildResult(
                    context,
                    'assets/animations/error.json', // (Descargar Lottie de "error")
                    "Error: ${e.toString()}",
                    Colors.red,
                  ),

                  // --- ESTADO DE ÉXITO ---
                  data: (message) => _buildResult(
                    context,
                    'assets/animations/success.json', // (Descargar Lottie de "success")
                    message ?? "¡Éxito!",
                    Colors.green,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  // Helper: Widget para mostrar el resultado (Éxito o Error)
  Widget _buildResult(
      BuildContext context, String lottieAsset, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(lottieAsset, width: 150, repeat: false),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Resetear todo para el siguiente escaneo
              ref.read(scanActionProvider.notifier).reset();
              setState(() {
                _isScanComplete = false;
              });
            },
            child: const Text('Escanear Siguiente'),
          )
        ],
      ),
    );
  }
}
