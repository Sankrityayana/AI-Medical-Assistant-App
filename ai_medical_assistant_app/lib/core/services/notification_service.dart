import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings());
    await _plugin.initialize(settings);
  }

  Future<void> showSimpleReminder({required int id, required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('med_channel', 'Medication Reminders', importance: Importance.max),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }
}

