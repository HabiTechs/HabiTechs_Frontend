// lib/domain/models/user.dart o donde tengas tus modelos
class User {
  final String id;
  final String fullName;
  final String email;
  final String? photoUrl;
  final List<String> roles;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      roles: (json['roles'] as List?)?.cast<String>() ?? [],
    );
  }
}
