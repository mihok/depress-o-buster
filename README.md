# Depress-o-buster

An inverted-Pomodoro timer for days when the hard part is starting. Instead of 25 minutes of work and 5 of rest,
a session looks like "5 minutes sitting next to the laundry pile, then 30 minutes back in bed". The work interval
is an **approach**: being near the thing, not doing the thing. Over days the ratio inverts on its own.

* One tap from open to running. No account, no onboarding, no mandatory setup.
* Every task has a ladder of rungs from "think about it for a minute" up to the whole task. Any rung is a valid
  place to start, in any order.
* "Break this down smaller" asks Claude (or the built-in offline ladders) for even smaller steps, in neutral
  language.
* XP for every completed interval. The curve favours small and consistent: a 1-minute approach is worth real
  points, a missed day is silent, and coming back after a gap is welcomed, never scolded.
* Rest is counted down with the same respect as the approach.
* Local-first: everything lives in an on-device SQLite database.

This is a timer with a very low floor. It is not a medical device and makes no health claims.

## Setup

Requirements:

* Flutter 3.47.7 (stable) with Dart 3.13.5. Older 3.4x versions will probably work; the project pins nothing
  below `sdk: ^3.13.5`.
* Android: SDK platform 36, build-tools 36, JDK 17 or newer. The Gradle wrapper downloads Gradle 9.3.1.
* iOS: Xcode with an iOS 13+ deployment target, CocoaPods.

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/data/db/database.g.dart
flutter run                                                # pick a device
```

The generated drift file is committed, so `build_runner` is only needed after changing the schema in
`lib/data/db/database.dart`.

Useful commands:

```sh
flutter analyze
flutter test                       # 123 tests: timer engine, XP rules, levels, ladders, services, repositories, start flow
flutter build apk --debug          # verified: permissions, receivers, raw chimes and sqlite3 libs land in the APK
flutter build web                  # verified: compiles (alarms are in-app only on the web)
flutter build ios --no-codesign    # needs macOS
```

## Using it

1. Open the app. Tap **Sit up for 2 minutes**. That is the whole flow.
2. Or pick a preset ratio (Edge of bed 3/20, Laundry proximity 5/30, Classic 25/5, ...) and start, or choose a
   task rung from the Tasks tab.
3. While an approach runs you can add time (snooze), finish early, pause, or stop. Stopping is logged as
   "Stopped early" and still earns XP for starting.
4. Rest starts on its own when the approach ends (configurable). When rest ends you can go another round or stop
   for now.
5. Progress shows your level, consistency, longest approach, approaches per day and the highest rung reached on
   each task. History lists every interval.

## Adding a Claude API key

Settings > AI breakdown > Claude API key > Add. The key is stored with `flutter_secure_storage` (the iOS Keychain, Android's keystore-backed storage) and is only
sent to the configured endpoint. Without a key the app uses its built-in
ladders, which also serve as the fallback if a request fails.

Defaults, all editable in Settings or in `lib/services/breakdown/breakdown_config.dart`:

| Setting | Default |
|---|---|
| Model | `claude-opus-5-5` (`claude-haiku-5-5` is a cheaper option that is fine for this job) |
| Effort | `medium` |
| Base URL | `https://api.anthropic.com` (point it at a small proxy to keep the key off the device) |
| Output | structured JSON via `output_config.format`, parsed into ladder steps |

The prompt tells the model to go absurdly small (a thought, a sentence said out loud, a posture, standing in a
doorway) and to use neutral language: no cheering, no advice about mood or health, no comment on why you are
stuck. Breakdowns are always optional and never block the timer.

## Alarms and platform limitations

Starting an approach schedules two exact local notifications at once, one for the end of the approach and one for
the end of the rest that follows, each with its own gentle chime. So the phone can stay locked through both. The
timer is derived from the wall clock, so backgrounding or killing the app does not drift it, and a running timer
is restored on the next launch.

* **Android**: exact alarms (`USE_EXACT_ALARM` / `SCHEDULE_EXACT_ALARM`), a live countdown in the notification
  shade, re-registration after reboot. Battery savers on some phones can still delay alarms; exempt the app if
  chimes arrive late. If exact alarms are not allowed the app falls back to inexact ones and tells you.
* **iOS**: there is no background execution, so the notification is the alarm. It obeys the silent switch and
  Focus; enabling the Time Sensitive Notifications capability in Xcode lets it through Focus. No lock-screen
  countdown yet (a Live Activity would need a native extension).
* **Desktop and web** compile and run; macOS alarms are best effort, and Linux, Windows and web play the chime
  in-app only.

Details and a test checklist: `docs/PLATFORM_ALARMS.md`.

## Project layout

```
lib/domain      pure Dart: entities, TimerEngine (state machine), XP rules, levels, ladder helpers
lib/data        drift schema, repositories, seed data
lib/services    alarms, sound, settings, Claude/mock breakdown, XP logging, timer controller, future seams
lib/ui          Start (becomes the timer), Tasks, Progress, History, Settings
test            unit tests for the domain and services, drift repository tests, widget tests for the start flow
docs            DECISIONS.md, PLATFORM_ALARMS.md, FUTURE_DIRECTIONS.md
PLAN.md         the plan this was built from
```

Future seams (interfaces only, all off): an AI companion voice during approaches (`CompanionService`), music
that follows the timer (`AudioContextService`), body doubling, and sync. See `docs/DECISIONS.md`.

## Tuning the XP curve

Everything is in `lib/domain/xp/xp_rules.dart` and `lib/domain/xp/levels.dart`, with tests in `test/domain`
that pin the current values. Change a constant, run `flutter test`, adjust the expectations you meant to change.

## License

MIT, see `LICENSE`.
