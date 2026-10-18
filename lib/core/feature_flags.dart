/// Compile-time switches for the future seams. Everything here is off in v1.
/// Each flag has a design note next to the interface it guards.
class FeatureFlags {
  FeatureFlags._();

  /// `services/companion/companion_service.dart`
  static const bool companion = false;

  /// `services/audio_context/audio_context_service.dart`
  static const bool audioContext = false;

  /// Body doubling / shared sessions. No interface yet; see docs/DECISIONS.md.
  static const bool sharedSessions = false;

  /// Sync and backup. See docs/DECISIONS.md for what the schema would need.
  static const bool sync = false;
}
