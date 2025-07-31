import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlaying = false;
  static Timer? _beepTimer;

  static bool get isPlaying => _isPlaying;

  static Future<void> playAlarmSound() async {
    try {
      // Stop any currently playing sound
      await stopAlarmSound();

      _isPlaying = true;

      // Vibrate the device
      await _vibrate();

      // Play a continuous beep pattern using system sounds
      await _playBeepPattern();
    } catch (e) {
      print('Error playing alarm sound: $e');
      // Fallback: just vibrate repeatedly
      await _vibratePattern();
    }
  }

  static Future<void> _playBeepPattern() async {
    // Play system alert sound immediately
    SystemSound.play(SystemSoundType.alert);

    // Create a timer to repeat the sound every 2 seconds
    _beepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    });
  }

  static Future<void> _vibratePattern() async {
    // Fallback vibration pattern
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      HapticFeedback.heavyImpact();
    });
  }

  static Future<void> stopAlarmSound() async {
    try {
      _isPlaying = false;
      _beepTimer?.cancel();
      _beepTimer = null;
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping alarm sound: $e');
    }
  }

  static Future<void> _vibrate() async {
    try {
      await HapticFeedback.heavyImpact();
      // Add a series of vibrations
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Error vibrating: $e');
    }
  }

  static void dispose() {
    _beepTimer?.cancel();
    _audioPlayer.dispose();
  }
}
