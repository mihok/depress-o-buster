import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/timer/timer_engine.dart';

/// In-app chimes and haptics. Quiet by design; the OS alarm carries the
/// sound when the app is in the background.
class SoundService {
  SoundService([this._player]);

  AudioPlayer? _player;

  AudioPlayer get _p => _player ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static String assetFor(SoundKind kind) => switch (kind) {
    SoundKind.start => 'sounds/soft_tick.wav',
    SoundKind.approachDone => 'sounds/approach_done.wav',
    SoundKind.restDone => 'sounds/rest_done.wav',
  };

  Future<void> play(SoundKind kind, {double volume = 0.7}) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(assetFor(kind)), volume: volume);
    } catch (e) {
      debugPrint('SoundService.play failed: $e');
    }
  }

  Future<void> haptic(SoundKind kind) async {
    try {
      switch (kind) {
        case SoundKind.start:
          await HapticFeedback.lightImpact();
        case SoundKind.approachDone:
          await HapticFeedback.mediumImpact();
        case SoundKind.restDone:
          await HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Haptics are optional everywhere.
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}
