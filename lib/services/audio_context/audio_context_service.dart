import '../session_context.dart';

/// FUTURE SEAM: music / ambient audio that follows the timer.
///
/// Idea: when an approach begins, start a playlist, an ambient track or a
/// Spotify context; when rest begins, switch to something quieter or stop.
/// Off by default (`FeatureFlags.audioContext`).
///
/// Candidate backends: Spotify App Remote (needs the Spotify app installed
/// and an OAuth client id), Apple Music via MusicKit, or a bundled set of
/// royalty-free ambient loops played with `audioplayers`. The interface is
/// deliberately event-shaped so the timer never waits on it.
abstract class AudioContextService {
  bool get isAvailable;

  Future<void> onApproachStarted(SessionContext context);

  Future<void> onRestStarted(SessionContext context);

  Future<void> onRunEnded();
}

class NoopAudioContextService implements AudioContextService {
  const NoopAudioContextService();

  @override
  bool get isAvailable => false;

  @override
  Future<void> onApproachStarted(SessionContext context) async {}

  @override
  Future<void> onRestStarted(SessionContext context) async {}

  @override
  Future<void> onRunEnded() async {}
}
