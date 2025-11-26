import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/repositories/access_repository.dart'; // Re-usamos el repo de Acceso

// Provider para la ACCIÓN de escanear un QR
final scanActionProvider =
    StateNotifierProvider.autoDispose<ScanActionNotifier, AsyncValue<String?>>(
        (ref) {
  return ScanActionNotifier(ref);
});

class ScanActionNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;
  ScanActionNotifier(this._ref)
      : super(const AsyncData(null)); // Estado inicial

  // Llama al repositorio con el token del QR
  Future<void> checkInVisit(String qrToken) async {
    state = const AsyncLoading(); // Cargando
    try {
      final repo = _ref.read(accessRepoProvider);
      // ¡Necesitamos un método 'checkIn' en el repo! (Lo añadiremos en el Paso 2)
      final successMessage = await repo.checkInVisit(qrToken);

      // ÉXITO: Guardamos el mensaje (ej. "Check-in exitoso")
      state = AsyncData(successMessage);
    } catch (e, stack) {
      // ERROR: Guardamos el mensaje (ej. "QR inválido")
      state = AsyncError(e, stack);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
