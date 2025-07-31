class Alarm {
  final int id;
  final int hour;
  final int minute;
  final bool isActive;
  final String label;
  final List<bool> weekdays; // Mon-Sun
  final bool isOneTime;

  const Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    this.isActive = false,
    this.label = 'Alarm',
    this.weekdays = const [false, false, false, false, false, false, false],
    this.isOneTime = true,
  });

  Alarm copyWith({
    int? id,
    int? hour,
    int? minute,
    bool? isActive,
    String? label,
    List<bool>? weekdays,
    bool? isOneTime,
  }) {
    return Alarm(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      weekdays: weekdays ?? this.weekdays,
      isOneTime: isOneTime ?? this.isOneTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'isActive': isActive,
      'label': label,
      'weekdays': weekdays,
      'isOneTime': isOneTime,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      isActive: json['isActive'] ?? false,
      label: json['label'] ?? 'Alarm',
      weekdays: List<bool>.from(
        json['weekdays'] ?? [false, false, false, false, false, false, false],
      ),
      isOneTime: json['isOneTime'] ?? true,
    );
  }

  String get timeString {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String get displayTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  DateTime getNextAlarmTime() {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (isOneTime) {
      // If the alarm time is in the past, set it for tomorrow
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
    } else {
      // For recurring alarms, find the next occurrence
      while (alarmTime.isBefore(now) || !weekdays[alarmTime.weekday - 1]) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
    }

    return alarmTime;
  }
}
