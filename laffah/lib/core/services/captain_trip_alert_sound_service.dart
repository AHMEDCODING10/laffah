import 'dart:async';
import 'package:flutter/services.dart';

/// CaptainTripAlertSoundService — Persistent, audible alert sound & rhythmic vibration
/// for incoming trip requests, ensuring captains never miss rides while riding or in traffic.
class CaptainTripAlertSoundService {
  static final CaptainTripAlertSoundService _instance =
      CaptainTripAlertSoundService._internal();
  factory CaptainTripAlertSoundService() => _instance;
  CaptainTripAlertSoundService._internal();

  Timer? _alertLoopTimer;
  Timer? _autoStopTimer;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Start persistent looped alarm & heavy vibration until captain responds or 30s timeout
  Future<void> startTripAlarm() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Immediately trigger initial chime & haptic burst
    _playChimeAndVibrate();

    // Loop loud chime + vibration every 1200ms
    _alertLoopTimer?.cancel();
    _alertLoopTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _playChimeAndVibrate();
    });

    // Safety timeout: auto-stop after 30 seconds (matching ride acceptance window)
    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(const Duration(seconds: 30), () {
      stopAlert();
    });
  }

  /// Backward-compatible alias for starting the trip alert
  Future<void> playSimpleTripAlert() async {
    await startTripAlarm();
  }

  void _playChimeAndVibrate() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    } catch (_) {
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// Stop the active alert and vibration loop immediately
  void stopAlert() {
    _isPlaying = false;
    _alertLoopTimer?.cancel();
    _alertLoopTimer = null;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
  }
}
