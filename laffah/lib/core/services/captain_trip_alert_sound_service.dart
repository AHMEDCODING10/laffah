import 'package:flutter/services.dart';

/// CaptainTripAlertSoundService — Simple, elegant notification sound & haptic alert
/// for incoming trip requests. Emits a discrete pleasant chime and haptic feedback
/// without repeating sirens or annoying alarms.
class CaptainTripAlertSoundService {
  static final CaptainTripAlertSoundService _instance =
      CaptainTripAlertSoundService._internal();
  factory CaptainTripAlertSoundService() => _instance;
  CaptainTripAlertSoundService._internal();

  DateTime? _lastAlertTime;

  /// Play a simple, pleasant alert chime and subtle haptic feedback for new trip requests
  Future<void> playSimpleTripAlert() async {
    final now = DateTime.now();
    // Throttle to prevent multiple rapid alerts within 2 seconds
    if (_lastAlertTime != null &&
        now.difference(_lastAlertTime!).inMilliseconds < 2000) {
      return;
    }
    _lastAlertTime = now;

    try {
      // 1. Play standard system alert sound / chime
      await SystemSound.play(SystemSoundType.alert);

      // 2. Add single crisp haptic feedback
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Fallback
      await HapticFeedback.vibrate();
    }
  }

  /// Stop / clear any active alert state
  void stopAlert() {
    // No ongoing loop to cancel; clean reset
  }
}
