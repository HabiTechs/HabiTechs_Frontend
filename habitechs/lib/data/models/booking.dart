// Este archivo define la estructura de una Reserva en el frontend
class Booking {
  final String id;
  final String amenityName;
  final DateTime bookingDate;
  final String status;
  final String residentEmail;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.amenityName,
    required this.bookingDate,
    required this.status,
    required this.residentEmail,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      amenityName: json['amenityName'] as String,
      // La API nos da un DateOnly, lo parseamos como DateTime
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      status: json['status'] as String,
      residentEmail: json['residentEmail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
