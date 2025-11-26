import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/repositories/booking_repository.dart';
// --- Estados Simples de la UI ---

// 1. Guarda el "Aménity" (área) que el usuario seleccionó
// (Por ahora, lo seteamos en "Parrillero A" por defecto)
final selectedAmenityProvider = StateProvider<String>((ref) => 'Parrillero A');

// 2. Guarda el día que el usuario está viendo en el calendario
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 3. Guarda el día que el usuario seleccionó (tocó)
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

// --- Proveedor de Datos (con Lógica) ---

// 4. Obtiene los días OCUPADOS desde la API
// Usamos .family para pasarle el 'amenityName'
final bookedDatesProvider = FutureProvider.autoDispose
    .family<List<DateTime>, String>((ref, amenityName) async {
  // Observa el mes que el usuario está viendo
  final focusedMonth = ref.watch(focusedDayProvider);
  final repo = ref.watch(bookingRepoProvider);

  // Llama al repositorio
  return repo.getBookedDates(amenityName, focusedMonth);
});

// --- Proveedor de Acciones (para el botón "Reservar") ---

// 5. El "Cerebro" que maneja la ACCIÓN de reservar
// (Maneja el estado de carga/error del *botón*)
final bookingActionProvider =
    StateNotifierProvider<BookingActionNotifier, AsyncValue<void>>((ref) {
  return BookingActionNotifier(ref);
});

class BookingActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BookingActionNotifier(this._ref)
      : super(const AsyncData(null)); // Estado inicial = "OK"

  Future<void> createBooking() async {
    // 1. Obtener los datos actuales de los otros providers
    final amenity = _ref.read(selectedAmenityProvider);
    final day = _ref.read(selectedDayProvider);

    if (day == null) {
      // No hacer nada si no se seleccionó un día
      return;
    }

    // 2. Poner el estado en "Cargando"
    state = const AsyncLoading();

    // 3. Llamar al repositorio (en un try/catch)
    try {
      final repo = _ref.read(bookingRepoProvider);
      await repo.createBooking(amenity, day);

      // 4. ÉXITO: Volver al estado "OK"
      state = const AsyncData(null);

      // 5. Refrescar la lista de días ocupados (para que muestre la nueva reserva)
      _ref.invalidate(bookedDatesProvider(amenity));
      // También refrescamos la lista de "Mis Reservas" (que haremos luego)
      // _ref.invalidate(myBookingsProvider);
    } catch (e, stack) {
      // 5. ERROR: Guardar el error
      state = AsyncError(e, stack);
    }
  }
}
