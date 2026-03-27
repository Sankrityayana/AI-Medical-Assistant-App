import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/speech_service.dart';
import '../../chat_symptom_checker/presentation/chat_controller.dart';
import '../../emergency/presentation/emergency_alert_dialog.dart';

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  String _recognizedText = '';
  bool _listening = false;

  Future<void> _toggleListen() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stopListening();
      setState(() => _listening = false);
      return;
    }

    final ready = await speech.initSpeech();
    if (!ready) return;
    setState(() => _listening = true);
    await speech.startListening((text) {
      if (mounted) setState(() => _recognizedText = text);
    });
  }

  Future<void> _sendToAi() async {
    if (_recognizedText.trim().isEmpty) return;
    final result = await ref.read(chatControllerProvider).sendMessage(_recognizedText.trim());
    if (!mounted) return;

    if ((result['emergency'] as bool?) == true) {
      await showDialog<void>(context: context, builder: (_) => const EmergencyAlertDialog());
      return;
    }

    final response = [
      'Possible causes: ${(result['possible_causes'] ?? []).toString()}',
      'Urgency: ${result['urgency_level'] ?? 'unknown'}',
      'Next: ${(result['next_steps'] ?? []).toString()}',
      result['disclaimer'] ?? 'This app is not a medical diagnosis tool.',
    ].join('\n');

    await ref.read(speechServiceProvider).speak(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _recognizedText.isEmpty ? 'Tap mic and start speaking...' : _recognizedText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _toggleListen,
              icon: Icon(_listening ? Icons.mic_off : Icons.mic),
              label: Text(_listening ? 'Stop Listening' : 'Start Listening'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _sendToAi,
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Send To AI & Speak Response'),
            ),
          ],
        ),
      ),
    );
  }
}
