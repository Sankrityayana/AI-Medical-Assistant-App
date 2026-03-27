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

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
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
  late final NotificationService _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = ref.read(notificationServiceProvider);
    _notifications.init();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  ({int hour, int minute})? _parseReminderTime(String value) {
    final timeParts = value.trim().split(':');
    if (timeParts.length < 2) {
      return null;
    }

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return (hour: hour, minute: minute);
  }

  void _disposeEditingControllers(
    TextEditingController nameCtrl,
    TextEditingController dosageCtrl,
    TextEditingController timeCtrl,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameCtrl.dispose();
      dosageCtrl.dispose();
      timeCtrl.dispose();
    });
  }

  Future<void> _addMedication() async {
    final parsedTime = _parseReminderTime(_timeCtrl.text);
    if (parsedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Use time format HH:mm or HH:mm:ss')),
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

    final created = await ref.read(medicationRepositoryProvider).addMedication(med);
    if (created.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication saved but reminder could not be scheduled.')),
        );
      }
      ref.invalidate(medicationListProvider);
      return;
    }

    await _notifications.scheduleDailyReminder(
      id: created.id!,
      title: 'Medication Reminder',
      body: 'Time to take ${created.name} (${created.dosage})',
      hour: parsedTime.hour,
      minute: parsedTime.minute,
    );
    _nameCtrl.clear();
    _doseCtrl.clear();
    ref.invalidate(medicationListProvider);
  }

  Future<void> _deleteMedication(Medication med) async {
    if (med.id == null) return;
    await ref.read(medicationRepositoryProvider).deleteMedication(med.id!);
    await _notifications.cancelReminder(med.id!);
    ref.invalidate(medicationListProvider);
  }

  Future<void> _editMedication(Medication med) async {
    if (med.id == null) return;

    final nameCtrl = TextEditingController(text: med.name);
    final dosageCtrl = TextEditingController(text: med.dosage);
    final timeCtrl = TextEditingController(text: med.reminderTime);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medication name')),
                const SizedBox(height: 8),
                TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage')),
                const SizedBox(height: 8),
                TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (HH:mm:ss)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        );
      },
    );

    if (shouldSave != true) {
      FocusScope.of(context).unfocus();
      _disposeEditingControllers(nameCtrl, dosageCtrl, timeCtrl);
      return;
    }

    final parsedTime = _parseReminderTime(timeCtrl.text);
    if (parsedTime == null || nameCtrl.text.trim().isEmpty || dosageCtrl.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide valid name, dosage, and time.')),
        );
      }
      FocusScope.of(context).unfocus();
      _disposeEditingControllers(nameCtrl, dosageCtrl, timeCtrl);
      return;
    }

    final updated = await ref.read(medicationRepositoryProvider).updateMedication(
          id: med.id!,
          name: nameCtrl.text.trim(),
          dosage: dosageCtrl.text.trim(),
          reminderTime: timeCtrl.text.trim(),
        );

    await _notifications.cancelReminder(med.id!);
    if (updated.id != null) {
      await _notifications.scheduleDailyReminder(
        id: updated.id!,
        title: 'Medication Reminder',
        body: 'Time to take ${updated.name} (${updated.dosage})',
        hour: parsedTime.hour,
        minute: parsedTime.minute,
      );
    }

    FocusScope.of(context).unfocus();
    _disposeEditingControllers(nameCtrl, dosageCtrl, timeCtrl);

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
                        onTap: () => _editMedication(med),
                        title: Text('${med.name} - ${med.dosage}'),
                        subtitle: Text('Reminder: ${med.reminderTime}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: med.isTaken,
                              onChanged: med.id == null
                                  ? null
                                  : (val) async {
                                      await ref.read(medicationRepositoryProvider).markTaken(med.id!, val ?? false);
                                      ref.invalidate(medicationListProvider);
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: med.id == null ? null : () => _deleteMedication(med),
                            ),
                          ],
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
