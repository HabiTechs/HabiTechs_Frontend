import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/booking.dart';
import 'package:habitechs/data/services/api_service.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  // Llama a GET /api/booking/availability
  Future<List<DateTime>> getBookedDates(
      String amenityName, DateTime month) async {
    try {
      final response = await _dio.get(
        '/api/booking/availability',
        queryParameters: {
          'amenityName': amenityName,
          // La API espera un DateOnly (YYYY-MM-DD), enviamos el primer día del mes
          'month': DateFormat('yyyy-MM-dd').format(month),
        },
      );

      if (response.statusCode == 200) {
        // La API devuelve una lista de strings ["2025-11-20", "2025-11-25"]
        final List<dynamic> dateStrings = response.data;
        return dateStrings.map((dateStr) => DateTime.parse(dateStr)).toList();
      }
      throw Exception('Error al cargar fechas');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Llama a POST /api/booking
  Future<void> createBooking(String amenityName, DateTime date) async {
    try {
      final response = await _dio.post(
        '/api/booking',
        data: {
          'amenityName': amenityName,
          // La API espera un DateOnly (YYYY-MM-DD)
          'bookingDate': DateFormat('yyyy-MM-dd').format(date),
        },
      );

      // 201 Created = Éxito
      if (response.statusCode != 201) {
        throw Exception('Error al crear la reserva');
      }
      // No necesitamos devolver nada, solo saber que funcionó
    } on DioException catch (e) {
      // Manejar el error de colisión (400 Bad Request)
      if (e.response?.statusCode == 400) {
        // Devuelve el mensaje de error de Dev 1
        throw Exception(e.response?.data['message'] ?? 'Error desconocido');
      }
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Llama a GET /api/booking/my-bookings
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _dio.get('/api/booking/my-bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      throw Exception('Error al cargar mis reservas');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }
}

// Proveedor de Riverpod
final bookingRepoProvider = Provider<BookingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingRepository(dio);
});
