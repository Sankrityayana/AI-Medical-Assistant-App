import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const DisclaimerDialog({super.key, required this.onAccepted});

  Widget _point(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_outline_rounded, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.health_and_safety_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('Medical Disclaimer')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.medicalDisclaimer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            _point(context, 'Use this app for guidance support, not diagnosis.'),
            const SizedBox(height: 8),
            _point(context, 'For severe symptoms, contact emergency services immediately.'),
            const SizedBox(height: 8),
            _point(context, 'Always consult a licensed healthcare professional.'),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            onAccepted();
            Navigator.of(context).pop();
          },
          child: const Text('I Understand'),
        ),
      ],
    );
  }
}
