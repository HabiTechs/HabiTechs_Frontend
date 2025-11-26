import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitechs/data/models/chat_message_model.dart';
import 'package:habitechs/data/services/chat_service.dart';

final chatServiceProvider = Provider((ref) => ChatService());

// Provider para cargar mensajes (Family permite pasar el ID del otro usuario)
final chatMessagesProvider = FutureProvider.family
    .autoDispose<List<ChatMessageModel>, String>((ref, otherUserId) async {
  final service = ref.read(chatServiceProvider);
  return await service.getConversation(otherUserId);
});

// Controller para manejar el envío
class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatService _service;
  final Ref _ref;

  ChatController(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String receiverId,
    String? message,
    File? image,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.sendMessage(
        receiverId: receiverId,
        message: message,
        imageFile: image,
      );
      state = const AsyncValue.data(null);

      // Refrescamos la lista de mensajes después de enviar
      _ref.invalidate(chatMessagesProvider(receiverId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref.read(chatServiceProvider), ref);
});
