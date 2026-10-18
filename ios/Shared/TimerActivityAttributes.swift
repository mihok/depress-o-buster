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
    /// When the rest that follows this approach ends. Lets the lock screen
    /// switch to the rest on its own if the app is suspended when the
    /// approach ends (the activity goes stale at `endsAt`).
    var restEndsAt: Date?
  }

  /// The run this activity belongs to; updates target the same activity.
  var runId: String
}
