import ActivityKit
import SwiftUI
import WidgetKit

/// The app's calm palette, mirrored from lib/core/theme.dart.
enum Palette {
  static let approach = Color(red: 0x8F / 255.0, green: 0xB3 / 255.0, blue: 0x9A / 255.0)
  static let rest = Color(red: 0x8E / 255.0, green: 0x9B / 255.0, blue: 0xC7 / 255.0)
  static let background = Color(red: 0x0F / 255.0, green: 0x11 / 255.0, blue: 0x14 / 255.0)
  static let text = Color(red: 0xE6 / 255.0, green: 0xE8 / 255.0, blue: 0xEA / 255.0)
  static let muted = Color(red: 0x9A / 255.0, green: 0xA3 / 255.0, blue: 0xAB / 255.0)
}

/// What to show for the activity's current state. When an approach's
/// activity has gone stale (the approach ended while the app was suspended)
/// and a rest follows, the view switches to the rest countdown by itself.
struct PhaseView {
  let context: ActivityViewContext<TimerActivityAttributes>

  var showingRest: Bool {
    context.state.phase != "approach" || (context.isStale && context.state.restEndsAt != nil)
  }

  var phaseLabel: String {
    if !showingRest { return "Approach" }
    return context.state.phase == "longRest" ? "Long rest" : "Rest"
  }

  var endsAt: Date {
    if context.state.phase == "approach" && showingRest {
      return context.state.restEndsAt ?? context.state.endsAt
    }
    return context.state.endsAt
  }

  var symbol: String { showingRest ? "moon.zzz" : "arrow.up.right" }

  var accent: Color { showingRest ? Palette.rest : Palette.approach }

  var title: String { context.state.title }

  /// A system-rendered countdown; it keeps ticking without updates.
  var countdown: Text {
    let end = endsAt
    let start = min(Date.now, end)
    return Text(timerInterval: start...end, countsDown: true)
  }
}

struct LockScreenView: View {
  let context: ActivityViewContext<TimerActivityAttributes>

  var body: some View {
    let view = PhaseView(context: context)
    HStack(alignment: .center, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Label(view.phaseLabel, systemImage: view.symbol)
          .font(.caption)
          .foregroundStyle(view.accent)
        Text(view.title)
          .font(.body)
          .foregroundStyle(Palette.text)
          .lineLimit(2)
      }
      Spacer(minLength: 8)
      view.countdown
        .font(.system(size: 34, weight: .light, design: .rounded).monospacedDigit())
        .foregroundStyle(Palette.text)
        .multilineTextAlignment(.trailing)
    }
    .padding(16)
  }
}

struct TimerActivityLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: TimerActivityAttributes.self) { context in
      LockScreenView(context: context)
        .activityBackgroundTint(Palette.background)
        .activitySystemActionForegroundColor(Palette.text)
    } dynamicIsland: { context in
      let view = PhaseView(context: context)
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label(view.phaseLabel, systemImage: view.symbol)
            .font(.caption)
            .foregroundStyle(view.accent)
        }
        DynamicIslandExpandedRegion(.trailing) {
          view.countdown
            .font(.title3.monospacedDigit())
            .foregroundStyle(Palette.text)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(view.title)
            .font(.caption)
            .foregroundStyle(Palette.muted)
            .lineLimit(1)
        }
      } compactLeading: {
        Image(systemName: view.symbol)
          .foregroundStyle(view.accent)
      } compactTrailing: {
        view.countdown
          .font(.caption.monospacedDigit())
          .foregroundStyle(Palette.text)
          .frame(maxWidth: 56)
      } minimal: {
        Image(systemName: view.symbol)
          .foregroundStyle(view.accent)
      }
      .keylineTint(view.accent)
    }
  }
}
