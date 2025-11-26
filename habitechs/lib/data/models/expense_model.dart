// Archivo: lib/data/models/expense_model.dart

class ExpenseModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  // Si necesitas más campos, agrégalos aquí (ej: paymentStatus)

  ExpenseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Expensa',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      isPaid: json['isPaid'] ?? false,
    );
  }
}
