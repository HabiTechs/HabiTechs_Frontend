import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habitechs/main.dart'
    hide kTeal, kOxfordBlue; // CORRECCIÓN: Ocultar para evitar conflicto
import 'package:habitechs/data/services/ticket_service.dart'; // Importamos el servicio y modelo
import 'package:habitechs/presentation/widgets/top_toast.dart'; // Importamos la notificación
import 'package:habitechs/presentation/widgets/empty_state_widget.dart'; // Importamos el widget de vacío
import 'package:iconsax/iconsax.dart';

// Definición local de colores
const Color kTeal = Colors.teal;
const Color kOxfordBlue = Color(0xFF002147);

// --- DEFINICIÓN DE PROVIDERS LOCALES ---
final ticketServiceProvider = Provider<TicketService>((ref) => TicketService());

final myTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final service = ref.watch(ticketServiceProvider);
  return service.getMyTickets();
});
// ------------------------------------------------------------------

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kOxfordBlue,
        onPressed: () => _showCreateTicketDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tickets) {
          if (tickets.isEmpty) {
            // Usamos el widget de estado vacío si existe, sino un fallback
            return const EmptyStateWidget(
              icon: Iconsax.ticket,
              title: 'No tienes tickets reportados',
              subtitle: 'Crea uno nuevo con el botón (+)',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              Color statusColor = Colors.grey;
              if (ticket.status == 'Open') statusColor = Colors.orange;
              if (ticket.status == 'Closed') statusColor = Colors.green;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(Iconsax.ticket, color: statusColor, size: 20),
                  ),
                  title: Text(ticket.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(ticket.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateTicketDialog(ref: ref),
    );
  }
}

class _CreateTicketDialog extends StatefulWidget {
  final WidgetRef ref;
  const _CreateTicketDialog({required this.ref});

  @override
  State<_CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<_CreateTicketDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final service = widget.ref.read(ticketServiceProvider);

      await service.createTicket(
          title: _titleController.text,
          description: _descController.text,
          image: _selectedImage);

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo

        showTopToast(context,
            title: "¡Ticket Creado!",
            body: "El administrador revisará tu reporte pronto.");

        widget.ref.invalidate(myTicketsProvider); // Recargar lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Reportar Nuevo Ticket", textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Asunto (ej. Foco quemado)",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción del problema",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey),
                          Text("Adjuntar foto (Opcional)",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kTeal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text("Enviar Reporte",
                    style: TextStyle(color: Colors.white)),
          ),
        )
      ],
    );
  }
}
