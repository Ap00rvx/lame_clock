import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('alarm_permissions');

  /// Check if exact alarm permission is granted (Android 12+)
  static Future<bool> hasExactAlarmPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod(
        'hasExactAlarmPermission',
      );
      return hasPermission;
    } catch (e) {
      print('Error checking exact alarm permission: $e');
      return true; // Assume granted for older Android versions
    }
  }

  /// Request exact alarm permission (Android 12+)
  static Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (e) {
      print('Error requesting exact alarm permission: $e');
    }
  }

  /// Check if the app is ignored from battery optimization
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool isIgnoring = await _channel.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );
      return isIgnoring;
    } catch (e) {
      print('Error checking battery optimization: $e');
      return true; // Assume ignored for older Android versions
    }
  }

  /// Request to ignore battery optimization
  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print('Error requesting battery optimization: $e');
    }
  }

  /// Check all necessary permissions and request if needed
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    bool allPermissionsGranted = true;

    // Check exact alarm permission
    final hasExactAlarm = await hasExactAlarmPermission();
    if (!hasExactAlarm) {
      final shouldRequest = await _showPermissionDialog(
        context,
        'Exact Alarm Permission',
        'This app needs permission to schedule exact alarms to wake you up on time. Please grant this permission in the next screen.',
      );

      if (shouldRequest) {
        await requestExactAlarmPermission();
        // Check again after request
        final hasPermissionAfterRequest = await hasExactAlarmPermission();
        if (!hasPermissionAfterRequest) {
          allPermissionsGranted = false;
        }
      } else {
        allPermissionsGranted = false;
      }
    }

    // Check battery optimization
    final isIgnoringBattery = await isIgnoringBatteryOptimizations();
    if (!isIgnoringBattery) {
      final shouldRequest = await _showPermissionDialog(
        context,
        'Battery Optimization',
        'To ensure alarms work reliably, please disable battery optimization for this app. This prevents the system from stopping the app in the background.',
      );

      if (shouldRequest) {
        await requestIgnoreBatteryOptimizations();
      }
    }

    return allPermissionsGranted;
  }

  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.security, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Grant Permission'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show a dialog explaining why permissions are needed
  static Future<void> showPermissionExplanationDialog(
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Permissions Required'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This alarm app requires the following permissions to work properly:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Exact Alarm Permission: To schedule precise alarms'),
              Text(
                '• Battery Optimization: To prevent the system from killing the app',
              ),
              Text('• Notifications: To show alarm notifications'),
              SizedBox(height: 12),
              Text(
                'Without these permissions, alarms may not work reliably or at all.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
