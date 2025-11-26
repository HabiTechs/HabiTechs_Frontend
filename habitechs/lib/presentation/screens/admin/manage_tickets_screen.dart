import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/presentation/providers/admin_provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class ManageTicketsScreen extends ConsumerWidget {
  const ManageTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(allTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Tickets'),
      ),
      body: ticketsAsync.when(
        loading: () => Center(
            child: Lottie.asset('assets/animations/loading.json', width: 150)),
        error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(child: Text('No hay tickets reportados.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allTicketsProvider),
            child: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final bool isOpen = ticket.status == 'Open';

                return Card(
                  color: isOpen ? Colors.white : Colors.grey[200],
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(ticket.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Reportado por: ${ticket.requesterEmail}\n${ticket.description}'),
                    isThreeLine: true,
                    trailing: isOpen
                        ? ElevatedButton(
                            child: const Text('Cerrar'),
                            onPressed: () {
                              ref
                                  .read(closeTicketActionProvider.notifier)
                                  .execute({'id': ticket.id});
                            },
                          )
                        : const Icon(Iconsax.tick_circle, color: Colors.green),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
