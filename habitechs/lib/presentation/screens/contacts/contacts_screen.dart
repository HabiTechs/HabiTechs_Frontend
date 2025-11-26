import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const Color kOxfordBlue = Color(0xFF002147);
const Color kTeal = Colors.teal;

class ContactModel {
  final String id;
  final String fullName;
  final String role;
  final String phoneNumber;
  final String email;

  ContactModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.phoneNumber,
    required this.email,
  });
}

class ContactsScreen extends StatefulWidget {
  // Recibimos un filtro opcional (ej: "Administrador" o "Guardia")
  final String? roleFilter;
  final bool showAppBar; // Controla si se muestra la barra propia

  const ContactsScreen({
    super.key,
    this.roleFilter,
    this.showAppBar =
        true, // Por defecto SÍ se muestra (para cuando entras desde el menú flotante)
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // Simulamos datos de la BD
  final List<ContactModel> allContacts = [
    ContactModel(
      id: 'admin-1',
      fullName: 'Juan Pérez',
      role: 'Administrador',
      phoneNumber: '77712345',
      email: 'admin@habitechs.com',
    ),
    ContactModel(
      id: 'admin-2',
      fullName: 'Ana Gómez',
      role: 'Administrador',
      phoneNumber: '77799999',
      email: 'ana.admin@habitechs.com',
    ),
    ContactModel(
      id: 'guardia-1',
      fullName: 'Carlos Guardia',
      role: 'Guardia',
      phoneNumber: '60012345',
      email: 'guardia@habitechs.com',
    ),
    ContactModel(
      id: 'guardia-2',
      fullName: 'Pedro Vigilante',
      role: 'Guardia',
      phoneNumber: '60054321',
      email: 'pedro@habitechs.com',
    ),
  ];

  // Lista filtrada que se mostrará en pantalla
  List<ContactModel> get displayedContacts {
    if (widget.roleFilter == null) {
      return allContacts; // Mostrar todos
    }
    // Mostrar solo los que coinciden con el rol
    return allContacts.where((c) => c.role == widget.roleFilter).toList();
  }

  // Título dinámico según el filtro
  String get screenTitle {
    if (widget.roleFilter == 'Administrador') return 'Administradores';
    if (widget.roleFilter == 'Guardia') return 'Seguridad';
    return 'Contactos';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    var whatsappUrl = "whatsapp://send?phone=591$phoneNumber&text=Hola";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      // Fallback simple
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsToShow = displayedContacts;

    return Scaffold(
      // Si showAppBar es false, pasamos null para no mostrar la barra (evita duplicados en Home)
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                screenTitle,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: kOxfordBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            )
          : null,
      backgroundColor: const Color(0xFFF5F7FA),

      // CORRECCIÓN: Quitamos columnas extra, directo el ListView
      body: contactsToShow.isEmpty
          ? Center(child: Text("No hay contactos de tipo ${widget.roleFilter}"))
          : ListView.builder(
              itemCount: contactsToShow.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemBuilder: (context, index) {
                final contact = contactsToShow[index];
                return _buildContactCard(contact);
              },
            ),
    );
  }

  Widget _buildContactCard(ContactModel contact) {
    final bool isAdmin = contact.role == 'Administrador';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.blue.shade50 : Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.security,
                    color: isAdmin ? Colors.blue : Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        contact.role,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.phone,
                  label: "Llamar",
                  color: Colors.green,
                  onTap: () => _makePhoneCall(contact.phoneNumber),
                ),
                _ActionButton(
                  icon: Icons.message,
                  label: "WhatsApp",
                  color: kTeal,
                  onTap: () => _openWhatsApp(contact.phoneNumber),
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: "Chat",
                  color: Colors.purple,
                  onTap: () {
                    // Corrección: Evitar error si go_router no está configurado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chat no disponible")),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
