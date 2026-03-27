import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/models/medication.dart';
import '../data/medication_repository.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(ref.read(dioProvider));
});

final medicationListProvider = FutureProvider<List<Medication>>((ref) async {
  return ref.read(medicationRepositoryProvider).fetchMedications();
});

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({super.key});

  @override
  ConsumerState<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '08:00:00');
  final NotificationService _notifications = NotificationService();

  @override
  void initState() {
    super.initState();
    _notifications.init();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    final timeParts = _timeCtrl.text.trim().split(':');
    if (timeParts.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Use time format HH:mm or HH:mm:ss')),
        );
      }
      return;
    }

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid time (HH:mm or HH:mm:ss).')),
        );
      }
      return;
    }

    final med = Medication(
      name: _nameCtrl.text.trim(),
      dosage: _doseCtrl.text.trim(),
      reminderTime: _timeCtrl.text.trim(),
    );

    if (med.name.isEmpty || med.dosage.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication name and dosage are required.')),
        );
      }
      return;
    }

    await ref.read(medicationRepositoryProvider).addMedication(med);
    await _notifications.scheduleDailyReminder(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Medication Reminder',
      body: 'Time to take ${med.name} (${med.dosage})',
      hour: hour,
      minute: minute,
    );
    _nameCtrl.clear();
    _doseCtrl.clear();
    ref.invalidate(medicationListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(medicationListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Medication Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Medication name')),
            const SizedBox(height: 8),
            TextField(controller: _doseCtrl, decoration: const InputDecoration(labelText: 'Dosage')),
            const SizedBox(height: 8),
            TextField(controller: _timeCtrl, decoration: const InputDecoration(labelText: 'Time (HH:mm:ss)')),
            const SizedBox(height: 8),
            FilledButton(onPressed: _addMedication, child: const Text('Add Medication')),
            const SizedBox(height: 12),
            Expanded(
              child: medsAsync.when(
                data: (meds) => ListView.builder(
                  itemCount: meds.length,
                  itemBuilder: (_, i) {
                    final med = meds[i];
                    return Card(
                      child: ListTile(
                        title: Text('${med.name} - ${med.dosage}'),
                        subtitle: Text('Reminder: ${med.reminderTime}'),
                        trailing: Checkbox(
                          value: med.isTaken,
                          onChanged: med.id == null
                              ? null
                              : (val) async {
                                  await ref.read(medicationRepositoryProvider).markTaken(med.id!, val ?? false);
                                  ref.invalidate(medicationListProvider);
                                },
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Failed to load medications')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
