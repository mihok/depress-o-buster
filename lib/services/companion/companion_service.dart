import 'package:meta/meta.dart';

import '../session_context.dart';

/// FUTURE SEAM: the AI companion ("random pal").
///
/// Idea: an optional voice that chats or rambles about unrelated things during
/// an approach interval, so the minutes pass with company rather than with
/// the task staring back. It never talks about the task unless asked and it
/// never motivates. Off by default (`FeatureFlags.companion`).
///
/// Two ways to produce audio, both fit this interface:
///
/// 1. On-device TTS. Generate text with the model (streaming), speak it with
///    the platform voice (`flutter_tts`). Cheap, works offline for the voice
///    part, robotic but private. Transcript comes straight from the text.
/// 2. Streaming audio from an API. Send the session context and stream back
///    audio chunks (for example a realtime voice endpoint). Natural voice,
///    needs network for the whole interval, must pause cleanly when the
///    alarm fires. Transcript is whatever the API reports.
///
/// Either way the implementation must: respect `stop()` within a second,
/// duck or pause under the alarm sound, survive the app being backgrounded
/// (or stop gracefully), and never write to the session log.
abstract class CompanionService {
  bool get isAvailable;

  /// Text of what the companion says, as it says it.
  Stream<CompanionUtterance> get transcript;

  Future<void> start(SessionContext context);

  Future<void> stop();
}

@immutable
class CompanionUtterance {
  const CompanionUtterance({required this.at, required this.text, this.spoken = true});

  final DateTime at;
  final String text;

  /// False when the text was shown but not voiced.
  final bool spoken;
}

/// Does nothing. Keeps the wiring compiling until a real one exists.
class NoopCompanionService implements CompanionService {
  const NoopCompanionService();

  @override
  bool get isAvailable => false;

  @override
  Stream<CompanionUtterance> get transcript => const Stream.empty();

  @override
  Future<void> start(SessionContext context) async {}

  @override
  Future<void> stop() async {}
}
