import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_medical_assistant_app/core/services/notification_service.dart';
import 'package:ai_medical_assistant_app/features/medication_reminder/data/medication_repository.dart';
import 'package:ai_medical_assistant_app/features/medication_reminder/presentation/medication_screen.dart';
import 'package:ai_medical_assistant_app/shared/models/medication.dart';

class FakeMedicationRepository extends MedicationRepository {
  FakeMedicationRepository({List<Medication>? seed})
      : _items = List<Medication>.from(seed ?? <Medication>[]),
        super(Dio());

  final List<Medication> _items;
  int _nextId = 100;

  @override
  Future<List<Medication>> fetchMedications() async {
    return List<Medication>.from(_items);
  }

  @override
  Future<Medication> addMedication(Medication medication) async {
    final created = Medication(
      id: _nextId++,
      name: medication.name,
      dosage: medication.dosage,
      reminderTime: medication.reminderTime,
      isTaken: medication.isTaken,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<void> deleteMedication(int id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> markTaken(int id, bool taken) async {
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx < 0) return;
    final current = _items[idx];
    _items[idx] = Medication(
      id: current.id,
      name: current.name,
      dosage: current.dosage,
      reminderTime: current.reminderTime,
      isTaken: taken,
    );
  }

  @override
  Future<Medication> updateMedication({
    required int id,
    required String name,
    required String dosage,
    required String reminderTime,
  }) async {
    final idx = _items.indexWhere((item) => item.id == id);
    final updated = Medication(id: id, name: name, dosage: dosage, reminderTime: reminderTime);
    if (idx >= 0) {
      _items[idx] = updated;
    }
    return updated;
  }
}

class FakeNotificationService extends NotificationService {
  int initCalls = 0;
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> init() async {
    initCalls += 1;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduleCalls += 1;
  }

  @override
  Future<void> cancelReminder(int id) async {
    cancelCalls += 1;
  }
}

Widget _buildApp({
  required FakeMedicationRepository repository,
  required FakeNotificationService notifications,
}) {
  return ProviderScope(
    overrides: [
      medicationRepositoryProvider.overrideWithValue(repository),
      notificationServiceProvider.overrideWithValue(notifications),
    ],
    child: const MaterialApp(home: MedicationScreen()),
  );
}

void main() {
  testWidgets('adds medication and schedules reminder', (tester) async {
    final repository = FakeMedicationRepository();
    final notifications = FakeNotificationService();

    await tester.pumpWidget(_buildApp(repository: repository, notifications: notifications));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Medication name'), 'Paracetamol');
    await tester.enterText(find.widgetWithText(TextField, 'Dosage'), '500mg');
    await tester.enterText(find.widgetWithText(TextField, 'Time (HH:mm:ss)'), '09:30:00');

    await tester.tap(find.text('Add Medication'));
    await tester.pumpAndSettle();

    expect(find.text('Paracetamol - 500mg'), findsOneWidget);
    expect(notifications.scheduleCalls, 1);
  });

  testWidgets('edits and deletes medication while updating reminders', (tester) async {
    final repository = FakeMedicationRepository(
      seed: [
        Medication(id: 1, name: 'Vitamin C', dosage: '250mg', reminderTime: '08:00:00'),
      ],
    );
    final notifications = FakeNotificationService();

    await tester.pumpWidget(_buildApp(repository: repository, notifications: notifications));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vitamin C - 250mg'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    await tester.enterText(
      find.descendant(of: dialog, matching: find.widgetWithText(TextField, 'Dosage')),
      '500mg',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Vitamin C - 500mg'), findsOneWidget);
    expect(notifications.cancelCalls, 1);
    expect(notifications.scheduleCalls, 1);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Vitamin C - 500mg'), findsNothing);
    expect(notifications.cancelCalls, 2);
  });
}
