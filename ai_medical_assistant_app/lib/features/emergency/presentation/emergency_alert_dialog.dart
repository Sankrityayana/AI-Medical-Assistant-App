import 'package:flutter/material.dart';

class EmergencyAlertDialog extends StatelessWidget {
  const EmergencyAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency Alert'),
      content: const Text(
        'Potential emergency detected. Please call your local emergency number immediately.',
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
