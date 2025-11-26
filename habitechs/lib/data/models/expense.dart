// Modelo para entender el JSON de GET /api/finance/...
class Expense {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String residentEmail; // Añadido para la App Admin

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.residentEmail,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      // El JSON de C# (decimal) lo leemos como double
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isPaid: json['isPaid'] as bool,
      residentEmail: json['residentEmail'] as String,
    );
  }
}
