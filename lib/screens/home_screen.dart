import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../services/permission_service.dart';
import '../models/alarm.dart';
import '../widgets/alarm_list_item.dart';
import '../widgets/math_challenge_dialog.dart';
import 'add_alarm_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Alarm> _alarms = [];
  bool _isLoading = true;
  Timer? _alarmCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAlarms();
    _checkForTriggeredAlarm();

    // Start periodic check for triggered alarms every 3 seconds
    _alarmCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _checkForTriggeredAlarm(),
    );

    // Check permissions after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alarmCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForTriggeredAlarm();
    }
  }

  Future<void> _loadAlarms() async {
    try {
      final alarms = await AlarmService.getAlarms();
      if (mounted) {
        setState(() {
          _alarms = alarms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading alarms: $e')));
      }
    }
  }

  Future<void> _checkForTriggeredAlarm() async {
    final isTriggered = await AlarmService.isAlarmTriggered();
    if (isTriggered && mounted) {
      final alarmId = await AlarmService.getTriggeredAlarmId();
      _showMathChallenge(alarmId);
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions = await PermissionService.checkAndRequestPermissions(
        context,
      );
      if (!hasPermissions && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Some permissions were not granted. Alarms may not work reliably.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error checking permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to check permissions. Please grant alarm permissions manually in Settings.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showMathChallenge(int? alarmId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MathChallengeDialog(
        onSuccess: () async {
          await AlarmService.clearTriggeredAlarm();
          if (alarmId != null) {
            // If it's a one-time alarm, disable it
            final alarm = _alarms.firstWhere(
              (a) => a.id == alarmId,
              orElse: () => _alarms.first,
            );
            if (alarm.isOneTime) {
              await AlarmService.toggleAlarm(alarmId);
              _loadAlarms();
            }
          }
        },
      ),
    );
  }

  Future<void> _addAlarm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
    );

    if (result == true) {
      _loadAlarms();
    }
  }

  Future<void> _toggleAlarm(int alarmId) async {
    try {
      await AlarmService.toggleAlarm(alarmId);
      _loadAlarms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error toggling alarm: $e')));
      }
    }
  }

  Future<void> _deleteAlarm(int alarmId) async {
    try {
      await AlarmService.deleteAlarm(alarmId);
      _loadAlarms();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alarm deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting alarm: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Math Alarm Clock',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () => _showMathChallenge(null),
            tooltip: 'Test Math Challenge',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'permissions',
                child: Row(
                  children: [
                    Icon(Icons.security),
                    SizedBox(width: 8),
                    Text('Check Permissions'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'permissions':
                  _checkPermissions();
                  break;
                case 'help':
                  PermissionService.showPermissionExplanationDialog(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alarms.isEmpty
          ? _buildEmptyState()
          : _buildAlarmList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        tooltip: 'Add Alarm',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No alarms set',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first alarm',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList() {
    return RefreshIndicator(
      onRefresh: _loadAlarms,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return AlarmListItem(
            alarm: alarm,
            onToggle: () => _toggleAlarm(alarm.id),
            onDelete: () => _deleteAlarm(alarm.id),
          );
        },
      ),
    );
  }
}
