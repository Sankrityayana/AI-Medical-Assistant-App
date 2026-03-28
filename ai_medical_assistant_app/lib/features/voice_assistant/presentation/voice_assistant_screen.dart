import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/speech_service.dart';
import '../../../shared/widgets/app_ui_components.dart';
import '../../../shared/widgets/blue_gradient_background.dart';
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

  void _applyPrompt(String value) {
    setState(() => _recognizedText = value);
  }

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: BlueGradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: AppSectionHeader(
                    title: 'Voice Assistant',
                    subtitle: _listening ? 'Listening now. Speak clearly.' : 'Tap start and describe symptoms naturally.',
                    icon: _listening ? Icons.graphic_eq_rounded : Icons.hearing_rounded,
                  ),
                ),
              ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppActionChip(
                        icon: Icons.thermostat_rounded,
                        label: 'Fever and chills',
                        onTap: () => _applyPrompt('I have fever with chills and body pain.'),
                      ),
                      const SizedBox(width: 8),
                      AppActionChip(
                        icon: Icons.mood_bad_rounded,
                        label: 'Nausea and weakness',
                        onTap: () => _applyPrompt('I feel nausea and weakness since morning.'),
                      ),
                      const SizedBox(width: 8),
                      AppActionChip(
                        icon: Icons.air_rounded,
                        label: 'Breathing discomfort',
                        onTap: () => _applyPrompt('I feel shortness of breath when walking.'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        _recognizedText.isEmpty ? 'Your recognized speech will appear here...' : _recognizedText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.35),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _toggleListen,
                icon: Icon(_listening ? Icons.mic_off_rounded : Icons.mic_rounded),
                label: Text(_listening ? 'Stop Listening' : 'Start Listening'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _sendToAi,
                icon: const Icon(Icons.record_voice_over_rounded),
                label: const Text('Send To AI & Speak Response'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
