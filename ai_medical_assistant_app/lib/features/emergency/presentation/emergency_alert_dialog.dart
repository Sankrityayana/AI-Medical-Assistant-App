import 'package:flutter/material.dart';

class EmergencyAlertDialog extends StatelessWidget {
  const EmergencyAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.error),
          const SizedBox(width: 8),
          const Text('Emergency Alert'),
        ],
      ),
      content: Text(
        'Potential emergency detected. Please call your local emergency number immediately.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Understood'),
        ),
      ],
    );
  }
}
