import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/repositories/access_repository.dart';

// Usamos un StateNotifier para manejar el estado (inicial, cargando, datos, error)
// El estado será un String (el token del QR) que puede ser nulo
final qrCodeProvider =
    StateNotifierProvider.autoDispose<QrCodeNotifier, AsyncValue<String?>>(
        (ref) {
  return QrCodeNotifier(ref);
});

class QrCodeNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  // Empezamos sin QR (null) y sin error (AsyncData)
  QrCodeNotifier(this._ref) : super(const AsyncData(null));

  Future<void> generateQr(String visitorName) async {
    // 1. Poner estado en "Cargando"
    state = const AsyncLoading();

    // 2. Llamar al repositorio (en un try/catch)
    try {
      final repo = _ref.read(accessRepoProvider);
      final qrToken = await repo.generateQrCode(visitorName);

      // 3. ÉXITO: Guardar el token del QR en el estado
      state = AsyncData(qrToken);
    } catch (e, stack) {
      // 4. ERROR: Guardar el mensaje de error
      state = AsyncError(e, stack);
    }
  }

  // Función para "limpiar" el QR y volver a la pantalla de formulario
  void reset() {
    state = const AsyncData(null);
  }
}
