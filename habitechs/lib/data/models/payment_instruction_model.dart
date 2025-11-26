// Archivo: lib/data/models/payment_instruction_model.dart

class PaymentInstructionModel {
  // El ID no es crucial para el frontend, pero lo mantenemos para consistencia
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String nitroId;
  final String? qrImageUrl; // URL del QR Fijo

  PaymentInstructionModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.nitroId,
    this.qrImageUrl,
  });

  factory PaymentInstructionModel.fromJson(Map<String, dynamic> json) {
    return PaymentInstructionModel(
      id: json['id'] ?? 0,
      bankName: json['bankName'] ?? 'No Definido',
      accountNumber: json['accountNumber'] ?? 'N/A',
      accountHolder: json['accountHolder'] ?? 'Condominio',
      nitroId: json['nitroId'] ?? '000000',
      qrImageUrl: json['qrImageUrl'],
    );
  }
}
