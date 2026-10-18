# Depress-o-buster: build plan

An inverted-Pomodoro app for getting unstuck. The "work" interval is an approach: proximity to a
task, not the task. The rest interval is sacred. Everything is local, no account, no guilt.

This file is the plan I wrote before building. Decisions made along the way are in `docs/DECISIONS.md`.

## Toolchain

| Thing | Version |
|---|---|
| Flutter (stable) | 3.47.7 |
| Dart | 3.13.5 |
| Android compileSdk / targetSdk / minSdk | 36 / 36 / 24 (Flutter defaults) |
| Gradle / AGP / Kotlin | 9.3.1 / 9.1.0 / 2.4.0 (Flutter template defaults) |
| iOS deployment target | Flutter template default (13.0) |

## Packages (resolved versions)

| Package | Version | Why |
|---|---|---|
| flutter_riverpod | 3.4.3 | State management. Plain `Notifier` / `AsyncNotifier` classes, no code generation. |
| drift | 2.35.2 | Local SQLite, typed queries, migrations. |
| drift_flutter | 0.3.1 | Opens the database in the app documents directory. Uses `sqlite3` 3.x native assets, so `sqlite3_flutter_libs` is not needed any more. |
| drift_dev + build_runner | 2.35.1 + 2.16.2 | Code generation for drift. `build_runner` is pinned below 2.17 because drift_dev 2.35 does not support `build` 5 yet. |
| flutter_local_notifications | 22.3.2 | Scheduled alarms on Android and iOS, ongoing countdown notification on Android. |
| timezone | 0.11.2 | `TZDateTime` for `zonedSchedule`. Alarms are absolute instants, so UTC is used and no device-timezone lookup is needed. |
| audioplayers | 6.8.1 | Plays the in-app chimes when the app is in the foreground. |
| shared_preferences | 2.5.6 | Settings. |
| flutter_secure_storage | 11.2.0 | The Claude API key. |
| http | 1.6.0 | Raw HTTPS call to the Claude Messages API (Dart has no official Anthropic SDK). |
| uuid, intl, clock | 4.6.0, 0.20.3, 1.1.3 | Ids, date formatting, injectable time for tests. |
| wakelock_plus | 1.8.1 | Optional "keep screen on during a timer". |
| mocktail | 1.0.5 | Test doubles. |

Not used, on purpose: `go_router` (plain `Navigator` is enough for five screens), `vibration`
(notification channels and `HapticFeedback` cover it), `flutter_foreground_task` /
`android_alarm_manager_plus` (see timer design below), `riverpod_generator` (keeps the build simple).

## Package layout

```
lib/
  main.dart                  bootstraps services, ProviderScope, runs the app
  app.dart                   MaterialApp, theme, home
  core/                      theme, formatting helpers, feature flags
  domain/                    pure Dart, no Flutter imports
    entities/                Task, LadderStep, Preset, Session, XpEvent, Mood
    timer/                   TimerEngine state machine (reduce(state, event) -> (state, effects))
    xp/                      XpRules (pure functions), Levels
    ladder/                  ladder editing helpers, built-in starter ladders
  data/
    db/                      drift tables + AppDatabase (+ generated database.g.dart)
    repositories/            TaskRepository, SessionRepository, PresetRepository, ProgressRepository
    seed/                    starter presets and tasks inserted on first launch
  services/
    alarms/                  AlarmService (abstract) + LocalNotificationsAlarmService
    audio/                   SoundService (in-app chimes, haptics)
    breakdown/               TaskBreakdownService (abstract), MockTaskBreakdownService, ClaudeTaskBreakdownService, BreakdownConfig
    companion/               CompanionService (interface only, stub impl)        <- future seam
    audio_context/           AudioContextService (interface only, stub impl)    <- future seam
    settings/                SettingsService (shared_preferences + secure storage)
    timer/                   TimerController (Riverpod notifier that drives the engine, the ticker and effects)
  ui/
    home/                    one-tap start, presets, "just sit up"
    timer/                   running timer, snooze, abandon, rest
    tasks/                   task list, ladder editor, "Break this down smaller"
    progress/                XP, level, sessions per day, longest approach, rung progression
    history/                 session log
    settings/                durations, sounds, API key, exact-alarm permission
    widgets/                 shared widgets
test/
  domain/                    timer engine, XP rules, levels, ladder helpers
  services/                  breakdown services (mock + Claude with a fake HTTP client), alarm scheduling logic
  data/                      drift repositories against an in-memory database
  widget/                    start flow: open app -> one tap -> timer running
docs/
  DECISIONS.md, FUTURE_DIRECTIONS.md, PLATFORM_ALARMS.md
```

## Timer engine (pure state machine)

The engine never touches `Timer`, widgets or plugins. It is a reducer:

```
(TimerState, TimerEvent) -> (TimerState, List<TimerEffect>)
```

State:

```
TimerStatus   idle | running | paused | finished
Phase         approach | rest | longRest
TimerState {
  status, phase, config (approach, rest, longRest?, cyclesBeforeLongRest, snoozeBy, autoStartRest)
  phaseStartedAt   wall-clock instant the current phase started
  phaseEndsAt      wall-clock instant it ends (start + planned + extensions)
  planned          planned duration of the phase (before snoozes)
  extended         total snooze extension applied this phase
  pausedRemaining  remaining time captured when paused
  cycleIndex       approaches completed in this run
  snoozeCount
  task / rung      what this approach is about (optional)
}
```

Events: `start(now, phase)`, `tick(now)`, `pause(now)`, `resume(now)`, `snooze(now)`,
`skip(now)` (ends the current phase early and records it as completed, used for rest), `abandon(now)`,
`finishPhase(now)` (explicit "I'm done early" for an approach, counts as completed).

Effects: `scheduleAlarm(phase, at)`, `cancelAlarms`, `phaseCompleted(phase, planned, actual, snoozed)`,
`sessionAbandoned(phase, planned, actual)`, `playSound(kind)`, `showOngoing(phase, endsAt)`, `hideOngoing`.

Remaining time is always derived from the wall clock (`phaseEndsAt - now`), so backgrounding, process
death and clock pauses do not drift the timer. A `tick` whose `now >= phaseEndsAt` completes the phase.
The Flutter-side controller feeds a 1 s ticker, executes effects via services, and persists the running
state so a killed app can resume the same phase from its stored `phaseEndsAt`.

Alarm strategy per platform: see `docs/PLATFORM_ALARMS.md`. Short version: both phases schedule an
exact local notification at `phaseEndsAt` through `flutter_local_notifications` (`alarmClock` mode on
Android, time-sensitive interruption level on iOS). Android also shows an ongoing chronometer
notification counting down. No foreground service and no Live Activity in v1.

## XP formula (pure functions in `domain/xp/xp_rules.dart`)

Base XP for a completed interval, where `m` = actual minutes (fractional allowed):

```
approach:  base = 20 + 10 * log2(1 + m)      1 min -> 30, 2 min -> 36, 5 min -> 46, 25 min -> 67, 50 min -> 77
rest:      base = 12                         every honoured rest earns the same, small, flat amount
snoozed:   same as approach, using the actual (extended) minutes; no penalty
abandoned: base = 10 (for starting) + 0.5 * approachBase(elapsed minutes)
```

The curve is logarithmic so a 1-minute approach is worth about 40 % of a 25-minute one.

Consistency multiplier `c` in [1.00, 1.50], starts at 1.00:

```
a day with at least one completed interval:  c = min(1.50, c + 0.05)
each missed day since the last active day:   c = max(1.00, c - 0.03)
```

It decays gently and never resets. It is never shown as "broken"; the UI shows it as a calm
percentage and never shows the number of missed days.

Bonuses (flat, added after the multiplier):

| Bonus | XP |
|---|---|
| first session ever | +50 |
| first session after a gap of 3 or more days | +40 (bigger than a normal day) |
| first completed interval today | +10 |
| first time attempting a higher rung on a task (new personal max) | +25 |
| rung higher than the previous session on the same task | +15 |

```
total = round(base * c) + bonuses
```

Levels: level L (L >= 2) is reached at cumulative XP `40 * (L - 1) * (L + 2)`:
160, 400, 720, 1120, 1600, ... (level 10 at 4320, level 20 at 16720). Level names are calm, in
`domain/xp/levels.dart`.

## AI breakdown

`TaskBreakdownService.breakDown(request) -> Future<Ladder>` with `request = {task, currentRung?, feelingNote?, goSmaller}`.

* `MockTaskBreakdownService`: hand-written ladders for laundry, shower, go outside, reply to someone,
  eat something, plus a generic fallback. Works offline and in tests.
* `ClaudeTaskBreakdownService`: raw HTTPS `POST /v1/messages` with `output_config.format` structured
  JSON output. Model, max tokens, effort and the system prompt live in `BreakdownConfig`. Default model
  `claude-opus-5-5`. Optional base URL override so a thin backend proxy can be dropped in later.
* Never blocks the timer. The breakdown sheet is independent from the timer controller.

## Order of work

1. PLAN.md (this file), scaffold, dependencies.
2. Domain: entities, timer engine, XP rules, levels, ladder helpers. Unit tests.
3. Services: alarms, sound, settings, breakdown (mock + Claude), future seams.
4. Data: drift schema, repositories, seed data.
5. UI: one-tap start -> timer -> rest, then tasks/ladders, progress, history, settings.
6. Platform config: Android permissions, channels, raw sounds; iOS Info.plist, bundled sounds.
7. Widget test for the start flow. `flutter analyze`, `flutter test`, Android debug build.
8. README, docs/DECISIONS.md, docs/PLATFORM_ALARMS.md, docs/FUTURE_DIRECTIONS.md.
