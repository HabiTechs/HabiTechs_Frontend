// Modelo para entender el JSON de GET /api/tickets/my-tickets
class Ticket {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final String requesterEmail;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.closedAt,
    required this.requesterEmail,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      requesterEmail: json['requesterEmail'] as String,
    );
  }
}
