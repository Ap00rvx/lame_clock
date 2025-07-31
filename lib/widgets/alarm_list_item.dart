import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../utils/time_utils.dart';

class AlarmListItem extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AlarmListItem({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: alarm.isActive ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Time and Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.displayTime,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: alarm.isActive
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alarm.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: alarm.isActive
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (!alarm.isOneTime) ...[
                    const SizedBox(height: 4),
                    Text(
                      TimeUtils.getWeekdaysString(alarm.weekdays),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: alarm.isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
                  if (alarm.isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rings in ${TimeUtils.getTimeUntilAlarm(alarm.getNextAlarmTime())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Controls
            Column(
              children: [
                Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showDeleteConfirmation(context),
                  color: Colors.red[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Alarm'),
          content: Text('Are you sure you want to delete "${alarm.label}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
