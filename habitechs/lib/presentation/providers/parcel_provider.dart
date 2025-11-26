import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/repositories/access_repository.dart';

// Provider para la ACCIÓN de registrar un paquete
final parcelActionProvider =
    StateNotifierProvider.autoDispose<ParcelActionNotifier, AsyncValue<void>>(
        (ref) {
  return ParcelActionNotifier(ref);
});

class ParcelActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ParcelActionNotifier(this._ref) : super(const AsyncData(null));

  Future<void> registerParcel(String residentEmail, String description) async {
    state = const AsyncLoading(); // Cargando
    try {
      final repo = _ref.read(accessRepoProvider);
      await repo.registerParcel(residentEmail, description);

      // ÉXITO
      state = const AsyncData(null);
    } catch (e, stack) {
      // ERROR
      state = AsyncError(e, stack);
    }
  }
}
