import ActivityKit
import Foundation

/// Shared between the app (Runner) and the TimerActivity widget extension.
/// Both targets compile this file.
@available(iOS 16.1, *)
struct TimerActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    /// "approach", "rest" or "longRest".
    var phase: String
    /// What the approach is about, e.g. "Sit up for 2 minutes".
    var title: String
    /// When the current phase ends.
    var endsAt: Date
    /// When the phase that follows this one on its own ends. Lets the lock
    /// screen switch to it by itself if the app is suspended when the current
    /// phase ends (the activity goes stale at `endsAt`).
    var nextEndsAt: Date?
    /// Which phase follows: "approach", "rest" or "longRest". Set with
    /// `nextEndsAt`.
    var nextPhase: String?
    /// Set while the timer is paused: the countdown freezes at this instant.
    var pausedAt: Date?
  }

  /// The run this activity belongs to; updates target the same activity.
  var runId: String
}
