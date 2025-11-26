// Este archivo define la estructura de un Anuncio en el frontend
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String authorEmail;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.authorEmail,
  });

  // Factory para convertir el JSON de la API en un objeto Announcement
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorEmail: json['authorEmail'] as String,
    );
  }
}
