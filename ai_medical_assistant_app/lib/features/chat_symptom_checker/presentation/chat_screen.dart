import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_ui_components.dart';
import '../../../shared/widgets/blue_gradient_background.dart';
import '../../emergency/presentation/emergency_alert_dialog.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _sending = true);
    final result = await ref.read(chatControllerProvider).sendMessage(text);
    if (!mounted) return;
    setState(() => _sending = false);

    if ((result['emergency'] as bool?) == true) {
      await showDialog<void>(context: context, builder: (_) => const EmergencyAlertDialog());
    }
  }

  void _usePrompt(String value) {
    _controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget quickPromptChip({required IconData icon, required String label, required String text}) {
      return AppActionChip(
        icon: icon,
        label: label,
        onTap: () => _usePrompt(text),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: BlueGradientBackground(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: AppSectionHeader(
                title: 'Symptom Checker',
                subtitle: 'Share symptoms clearly for safer AI guidance and next steps.',
                icon: Icons.monitor_heart_outlined,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 2, 12, 6),
              child: AppInfoBanner(
                text: 'For severe pain, breathing trouble, or bleeding, seek emergency help first.',
                icon: Icons.shield_outlined,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  quickPromptChip(
                    icon: Icons.sick_rounded,
                    label: 'Headache + fever',
                    text: 'I have headache and fever since yesterday.',
                  ),
                  const SizedBox(width: 8),
                  quickPromptChip(
                    icon: Icons.air_rounded,
                    label: 'Cough + sore throat',
                    text: 'I have cough with sore throat and mild fatigue.',
                  ),
                  const SizedBox(width: 8),
                  quickPromptChip(
                    icon: Icons.bedtime_rounded,
                    label: 'Fatigue + poor sleep',
                    text: 'I feel very tired and have poor sleep recently.',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                      decoration: BoxDecoration(
                        gradient: message.isUser
                            ? LinearGradient(
                                colors: [scheme.primaryContainer, scheme.secondaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [scheme.surface, scheme.surfaceContainerHighest.withValues(alpha: 0.72)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe your symptoms...',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
