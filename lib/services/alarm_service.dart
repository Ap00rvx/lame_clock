import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alarm.dart';
import 'notification_service.dart';
import 'audio_service.dart';

// Top-level callback function for alarm
@pragma('vm:entry-point')
void alarmCallback(int alarmId) async {
  print('Alarm triggered with ID: $alarmId');

  // Start playing alarm sound
  await AudioService.playAlarmSound();

  // Show notification
  await NotificationService.showAlarmNotification(
    id: alarmId,
    title: 'Math Alarm',
    body: 'Solve the math problem to turn off the alarm!',
  );

  // Mark alarm as triggered in preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('triggered_alarm_id', alarmId);
  await prefs.setBool('alarm_triggered', true);
}

class AlarmService {
  static const String _alarmsKey = 'alarms';
  static const String _nextAlarmIdKey = 'next_alarm_id';

  static Future<List<Alarm>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

    return alarmsJson.map((json) => Alarm.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms
        .map((alarm) => jsonEncode(alarm.toJson()))
        .toList();

    await prefs.setStringList(_alarmsKey, alarmsJson);
  }

  static Future<int> getNextAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = prefs.getInt(_nextAlarmIdKey) ?? 1;
    await prefs.setInt(_nextAlarmIdKey, nextId + 1);
    return nextId;
  }

  static Future<Alarm> addAlarm({
    required int hour,
    required int minute,
    String label = 'Alarm',
    List<bool>? weekdays,
    bool isOneTime = true,
  }) async {
    final id = await getNextAlarmId();
    final alarm = Alarm(
      id: id,
      hour: hour,
      minute: minute,
      label: label,
      weekdays: weekdays ?? [false, false, false, false, false, false, false],
      isOneTime: isOneTime,
      isActive: true,
    );

    final alarms = await getAlarms();
    alarms.add(alarm);
    await saveAlarms(alarms);

    // Schedule the alarm
    await scheduleAlarm(alarm);

    return alarm;
  }

  static Future<void> updateAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);

    if (index != -1) {
      // Cancel existing alarm
      await AndroidAlarmManager.cancel(alarm.id);

      alarms[index] = alarm;
      await saveAlarms(alarms);

      // Reschedule if active
      if (alarm.isActive) {
        await scheduleAlarm(alarm);
      }
    }
  }

  static Future<void> deleteAlarm(int alarmId) async {
    // Cancel the alarm
    await AndroidAlarmManager.cancel(alarmId);

    // Remove from storage
    final alarms = await getAlarms();
    alarms.removeWhere((alarm) => alarm.id == alarmId);
    await saveAlarms(alarms);
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isActive) return;

    try {
      final alarmTime = alarm.getNextAlarmTime();

      await AndroidAlarmManager.oneShotAt(
        alarmTime,
        alarm.id,
        alarmCallback,
        exact: true,
        wakeup: true,
      );

      print('Alarm scheduled for: $alarmTime (ID: ${alarm.id})');
    } catch (e) {
      print('Error scheduling alarm: $e');

      // If scheduling fails, it might be due to permissions
      rethrow; // Re-throw so the UI can handle it
    }
  }

  static Future<void> toggleAlarm(int alarmId) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((alarm) => alarm.id == alarmId);

    if (index != -1) {
      final alarm = alarms[index];
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);
      await updateAlarm(updatedAlarm);
    }
  }

  static Future<void> cancelAllAlarms() async {
    final alarms = await getAlarms();
    for (final alarm in alarms) {
      await AndroidAlarmManager.cancel(alarm.id);
    }
  }

  static Future<void> rescheduleActiveAlarms() async {
    final alarms = await getAlarms();
    for (final alarm in alarms.where((a) => a.isActive)) {
      await scheduleAlarm(alarm);
    }
  }

  static Future<bool> isAlarmTriggered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('alarm_triggered') ?? false;
  }

  static Future<int?> getTriggeredAlarmId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('triggered_alarm_id');
  }

  static Future<void> clearTriggeredAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('alarm_triggered');
    await prefs.remove('triggered_alarm_id');
  }
}
