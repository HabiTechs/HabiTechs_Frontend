// Archivo: lib/data/models/operational_expense_model.dart

class OperationalExpenseModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dateIncurred;
  final String? proofImageUrl;

  OperationalExpenseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dateIncurred,
    this.proofImageUrl,
  });

  factory OperationalExpenseModel.fromJson(Map<String, dynamic> json) {
    return OperationalExpenseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Gasto Operativo',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dateIncurred:
          DateTime.tryParse(json['dateIncurred'] ?? '') ?? DateTime.now(),
      proofImageUrl: json['proofImageUrl'],
    );
  }
}
