import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/phase.dart';

/// Thin Dart side of the iOS Live Activity (lock screen and Dynamic Island
/// countdown). The native side lives in `ios/Runner/LiveActivityBridge.swift`
/// and the widget in `ios/TimerActivity/`. Every call is best-effort: on
/// platforms or devices without Live Activities it simply reports false.
class LiveActivityChannel {
  LiveActivityChannel({MethodChannel? channel}) : _channel = channel ?? const MethodChannel(name);

  static const String name = 'app.depressobuster/live_activity';

  final MethodChannel _channel;

  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('LiveActivity isAvailable failed: $e');
      return false;
    }
  }

  /// Start or update the activity for [runId].
  Future<bool> show({
    required String runId,
    required Phase phase,
    required String title,
    required DateTime endsAt,
    DateTime? restEndsAt,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('show', <String, Object?>{
            'runId': runId,
            'phase': phase.name,
            'title': title,
            'endsAtMs': endsAt.toUtc().millisecondsSinceEpoch,
            'restEndsAtMs': restEndsAt?.toUtc().millisecondsSinceEpoch,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('LiveActivity show failed: $e');
      return false;
    }
  }

  Future<void> hide() async {
    try {
      await _channel.invokeMethod<bool>('hide');
    } on MissingPluginException {
      // Not on iOS.
    } on PlatformException catch (e) {
      debugPrint('LiveActivity hide failed: $e');
    }
  }
}
