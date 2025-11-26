class ContactModel {
  final String id;
  final String fullName;
  final String role; // "Admin" o "Guardia"
  final String phoneNumber;
  final String email;

  ContactModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.phoneNumber,
    required this.email,
  });

  // Factory para crear desde JSON (cuando conectes con el Backend)
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Usuario',
      role: json['role'] ?? 'Desconocido',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
