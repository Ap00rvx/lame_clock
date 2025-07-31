import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../utils/time_utils.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _label = 'Alarm';
  bool _isOneTime = true;
  List<bool> _weekdays = [false, false, false, false, false, false, false];
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _labelController.text = _label;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveAlarm() async {
    try {
      await AlarmService.addAlarm(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        label: _labelController.text.trim().isEmpty
            ? 'Alarm'
            : _labelController.text.trim(),
        weekdays: _weekdays,
        isOneTime: _isOneTime,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving alarm: $e\n\nTip: Check if alarm permissions are granted in Settings.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(TimeUtils.formatTime(_selectedTime)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectTime,
              ),
            ),
            const SizedBox(height: 16),

            // Label
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Label',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'Enter alarm label',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Repeat Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Repeat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('One-time alarm'),
                      subtitle: const Text('Alarm will ring only once'),
                      value: _isOneTime,
                      onChanged: (value) {
                        setState(() {
                          _isOneTime = value;
                          if (value) {
                            _weekdays = [
                              false,
                              false,
                              false,
                              false,
                              false,
                              false,
                              false,
                            ];
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!_isOneTime) ...[
                      const SizedBox(height: 16),
                      const Text('Repeat on:'),
                      const SizedBox(height: 8),
                      _buildWeekdaySelector(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Next Alarm Info
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getNextAlarmText(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    final weekdayNames = TimeUtils.getWeekdayNames();

    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(weekdayNames[index]),
          selected: _weekdays[index],
          onSelected: (selected) {
            setState(() {
              _weekdays[index] = selected;
            });
          },
        );
      }),
    );
  }

  String _getNextAlarmText() {
    final nextAlarmTime = TimeUtils.getNextAlarmTime(
      _selectedTime.hour,
      _selectedTime.minute,
      isOneTime: _isOneTime,
      weekdays: _isOneTime ? null : _weekdays,
    );

    final timeUntil = TimeUtils.getTimeUntilAlarm(nextAlarmTime);
    return 'Alarm will ring in $timeUntil';
  }
}
