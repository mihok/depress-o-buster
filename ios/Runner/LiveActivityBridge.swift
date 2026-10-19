import ActivityKit
import Flutter
import Foundation

/// Method channel `app.depressobuster/live_activity`:
///   isAvailable()                                   -> Bool
///   show(phase, title, endsAtMs, nextEndsAtMs?, nextPhase?, runId) -> Bool
///   hide()                                          -> Bool
///
/// One Live Activity per run: `show` updates the activity for `runId` when it
/// exists and otherwise ends any other activity and starts a new one.
final class LiveActivityBridge: NSObject {
  static let channelName = "app.depressobuster/live_activity"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let bridge = LiveActivityBridge()
    channel.setMethodCallHandler { call, result in
      bridge.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(false)
      return
    }
    switch call.method {
    case "isAvailable":
      result(ActivityAuthorizationInfo().areActivitiesEnabled)
    case "show":
      guard let args = call.arguments as? [String: Any],
        let phase = args["phase"] as? String,
        let title = args["title"] as? String,
        let runId = args["runId"] as? String,
        let endsAtMs = (args["endsAtMs"] as? NSNumber)?.doubleValue
      else {
        result(FlutterError(code: "bad_args", message: "phase, title, runId and endsAtMs are required", details: nil))
        return
      }
      let nextEndsAtMs = (args["nextEndsAtMs"] as? NSNumber)?.doubleValue
      let pausedAtMs = (args["pausedAtMs"] as? NSNumber)?.doubleValue
      let nextPhase = args["nextPhase"] as? String
      let endsAt = Date(timeIntervalSince1970: endsAtMs / 1000)
      let nextEndsAt = nextEndsAtMs.map { Date(timeIntervalSince1970: $0 / 1000) }
      let pausedAt = pausedAtMs.map { Date(timeIntervalSince1970: $0 / 1000) }
      Task { @MainActor in
        let ok = await LiveActivityBridge.show(
          phase: phase, title: title, endsAt: endsAt, nextEndsAt: nextEndsAt,
          nextPhase: nextPhase, pausedAt: pausedAt, runId: runId)
        result(ok)
      }
    case "hide":
      Task { @MainActor in
        await LiveActivityBridge.endAll()
        result(true)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 16.2, *)
  private static func show(
    phase: String, title: String, endsAt: Date, nextEndsAt: Date?,
    nextPhase: String?, pausedAt: Date?, runId: String
  ) async -> Bool {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
    let state = TimerActivityAttributes.ContentState(
      phase: phase, title: title, endsAt: endsAt, nextEndsAt: nextEndsAt,
      nextPhase: nextPhase, pausedAt: pausedAt)
    // Stale at the end of the phase: the widget then shows the countdown of
    // the phase that follows (if one does) without any help from the app. A
    // paused timer has no end to go stale at.
    let content = ActivityContent(state: state, staleDate: pausedAt == nil ? endsAt : nil)
    for activity in Activity<TimerActivityAttributes>.activities {
      if activity.attributes.runId == runId {
        await activity.update(content)
        return true
      }
    }
    await endAll()
    do {
      _ = try Activity<TimerActivityAttributes>.request(
        attributes: TimerActivityAttributes(runId: runId), content: content, pushType: nil)
      return true
    } catch {
      return false
    }
  }

  @available(iOS 16.2, *)
  private static func endAll() async {
    for activity in Activity<TimerActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }
}
