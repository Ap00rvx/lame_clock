import 'package:flutter/material.dart';

class TimeUtils {
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  static String format24Hour(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static DateTime getNextAlarmTime(
    int hour,
    int minute, {
    bool isOneTime = true,
    List<bool>? weekdays,
  }) {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (isOneTime) {
      // If the alarm time is in the past, set it for tomorrow
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
    } else if (weekdays != null) {
      // For recurring alarms, find the next occurrence
      while (alarmTime.isBefore(now) || !weekdays[alarmTime.weekday - 1]) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
    }

    return alarmTime;
  }

  static String getTimeUntilAlarm(DateTime alarmTime) {
    final now = DateTime.now();
    final difference = alarmTime.difference(now);

    if (difference.isNegative) {
      return 'Alarm has passed';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'}, $hours hour${hours == 1 ? '' : 's'}';
    } else if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'}, $minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }
  }

  static List<String> getWeekdayNames() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  static String getWeekdaysString(List<bool> weekdays) {
    final weekdayNames = getWeekdayNames();
    final activeDays = <String>[];

    for (int i = 0; i < weekdays.length; i++) {
      if (weekdays[i]) {
        activeDays.add(weekdayNames[i]);
      }
    }

    if (activeDays.length == 7) {
      return 'Every day';
    } else if (activeDays.length == 5 &&
        weekdays.sublist(0, 5).every((day) => day)) {
      return 'Weekdays';
    } else if (activeDays.length == 2 && weekdays[5] && weekdays[6]) {
      return 'Weekends';
    } else if (activeDays.isEmpty) {
      return 'Never';
    } else {
      return activeDays.join(', ');
    }
  }
}
