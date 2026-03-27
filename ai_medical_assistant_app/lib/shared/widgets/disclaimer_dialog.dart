import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const DisclaimerDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Medical Disclaimer'),
      content: const Text(AppStrings.medicalDisclaimer),
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
