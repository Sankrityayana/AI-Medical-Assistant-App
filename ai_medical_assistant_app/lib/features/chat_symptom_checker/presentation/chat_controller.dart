import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/utils/emergency_detector.dart';
import '../../../shared/models/chat_message.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(dioProvider));
});

final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref);
});

class ChatController {
  final Ref _ref;

  ChatController(this._ref);

  Future<Map<String, dynamic>> sendMessage(String text) async {
    final current = _ref.read(chatMessagesProvider);
    _ref.read(chatMessagesProvider.notifier).state = [...current, ChatMessage(text: text, isUser: true)];

    if (EmergencyDetector.isEmergency(text)) {
      return {'emergency': true};
    }

    final result = await _ref.read(chatRepositoryProvider).askAi(text);
    final aiText = [
      'Possible causes: ${(result['possible_causes'] ?? []).toString()}',
      'Urgency: ${result['urgency_level'] ?? 'unknown'}',
      'Next steps: ${(result['next_steps'] ?? []).toString()}',
      result['disclaimer'] ?? 'This app is not a medical diagnosis tool.',
    ].join('\n');

    _ref.read(chatMessagesProvider.notifier).state = [
      ..._ref.read(chatMessagesProvider),
      ChatMessage(text: aiText, isUser: false),
    ];

    return result;
  }
}
