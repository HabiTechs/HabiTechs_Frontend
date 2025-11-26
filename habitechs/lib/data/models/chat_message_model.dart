class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final String imageUrl;
  final DateTime sentAt;
  final bool isMine; // Backend nos dice si es mío

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.imageUrl,
    required this.sentAt,
    required this.isMine,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Usuario',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
      isMine: json['isMine'] ?? false,
    );
  }
}
