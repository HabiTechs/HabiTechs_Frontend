import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/booking_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAmenity = ref.watch(selectedAmenityProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final bookedDatesAsync = ref.watch(bookedDatesProvider(selectedAmenity));
    final bookingActionState = ref.watch(bookingActionProvider);

    final amenities = ['Parrillero A', 'Salón de Fiestas', 'Piscina'];

    // ¡SIN SCAFFOLD NI APPBAR! - El HomeScreen lo maneja
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- 1. Selector de Área (Amenity) ---
          DropdownButtonFormField<String>(
            value: selectedAmenity,
            decoration: const InputDecoration(
              labelText: 'Área Común',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Iconsax.building_3),
            ),
            items: amenities.map((String amenity) {
              return DropdownMenuItem<String>(
                value: amenity,
                child: Text(amenity),
              );
            }).toList(),
            onChanged: (String? newValue) {
              ref.read(selectedAmenityProvider.notifier).state = newValue!;
              ref.read(selectedDayProvider.notifier).state = null;
            },
          ),
          const SizedBox(height: 20),

          // --- 2. El Calendario ---
          Card(
            elevation: 2,
            child: TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (newSelectedDay, newFocusedDay) {
                ref.read(selectedDayProvider.notifier).state = newSelectedDay;
                ref.read(focusedDayProvider.notifier).state = newFocusedDay;
              },
              onPageChanged: (newFocusedDay) {
                ref.read(focusedDayProvider.notifier).state = newFocusedDay;
              },
              eventLoader: (day) {
                return bookedDatesAsync.when(
                  data: (bookedDates) {
                    for (var bookedDate in bookedDates) {
                      if (isSameDay(bookedDate, day)) {
                        return [Container()];
                      }
                    }
                    return [];
                  },
                  loading: () => [],
                  error: (e, s) => [],
                );
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.red[700],
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- 3. El Botón de Reservar ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: (selectedDay == null || bookingActionState.isLoading)
                ? null
                : () {
                    ref.read(bookingActionProvider.notifier).createBooking();
                  },
            child: bookingActionState.isLoading
                ? const CircularProgressIndicator()
                : Text(selectedDay == null
                    ? 'Selecciona un día'
                    : 'Reservar para ${DateFormat('dd/MM/yyyy').format(selectedDay)}'),
          ),

          if (bookingActionState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Error: ${bookingActionState.error.toString()}",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
