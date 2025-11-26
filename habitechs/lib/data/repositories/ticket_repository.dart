import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/ticket.dart';
import 'package:habitechs/data/services/api_service.dart';

class TicketRepository {
  final Dio _dio;
  TicketRepository(this._dio);

  // --- MÉTODO EXISTENTE (Para Residente) ---
  // Llama a GET /api/tickets/my-tickets
  Future<List<Ticket>> getMyTickets() async {
    try {
      final response = await _dio.get('/api/tickets/my-tickets');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Ticket.fromJson(json)).toList();
      }
      throw Exception('Error al cargar tickets');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // --- MÉTODO EXISTENTE (Para Residente) ---
  // Llama a POST /api/tickets
  Future<void> createTicket(String title, String description) async {
    try {
      final response = await _dio.post(
        '/api/tickets',
        data: {
          'title': title,
          'description': description,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Error al crear el ticket');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }

  // --- ¡CÓDIGO RESTANTE AÑADIDO! (Para Admin) ---

  // Llama a GET /api/tickets (Admin)
  Future<List<Ticket>> getAllTickets() async {
    try {
      final response = await _dio.get('/api/tickets');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Ticket.fromJson(json)).toList();
      }
      throw Exception('Error al cargar todos los tickets');
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }

  // Llama a PUT /api/tickets/{id}/close (Admin)
  Future<void> closeTicket(String ticketId) async {
    try {
      // Nota: Dev 1 no espera un 'body', solo la URL
      final response = await _dio.put('/api/tickets/$ticketId/close');
      if (response.statusCode != 200) {
        throw Exception('Error al cerrar ticket');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de red');
    }
  }
}

// Provider (no cambia)
final ticketRepoProvider = Provider<TicketRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TicketRepository(dio);
});
