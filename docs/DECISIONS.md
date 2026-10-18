# Decisions

Choices made while building v1, with the reasoning, so they are easy to revisit. Newest at the bottom.

## 1. Riverpod 3 without code generation

Plain `Notifier`, `NotifierProvider`, `StreamProvider` and `FutureProvider`. Code generation would add a second
builder to an already drift-driven build and buys little for a dozen providers. Everything is wired in
`lib/services/providers.dart`, and the infrastructure providers (database, settings store, alarm service) are
overridden in `main()` and in tests.

## 2. drift for local data, ISO text dates, UUID ids

* `drift` + `drift_flutter`. `drift_flutter` now depends on `sqlite3` 3.x, which ships the native library as a
  Dart native asset, so `sqlite3_flutter_libs` (end of life) is not used.
* `store_date_time_values_as_text: true` (see `build.yaml`): dates are ISO-8601 text in UTC. They sort, diff
  and export cleanly and a sync layer can read them without a Dart-specific epoch convention.
* Every id is a client-generated UUID string and every mutable table has `updatedAt`. For sync later the schema
  needs `deletedAt` tombstones and a `dirty` flag per row; nothing else would have to change. Sessions do not
  have a foreign key to tasks on purpose, so history outlives deleted tasks.
* `build_runner` is pinned to `^2.16.0` because `drift_dev` 2.35 does not yet support `build` 5.

## 3. Timer: wall-clock state machine, no foreground service

`TimerEngine` is a pure reducer. Remaining time is always `phaseEndsAt - now`, so backgrounding, process death
and late ticks cannot drift it. The running state is persisted as JSON after every event and restored on launch
with a catch-up tick. Alarms are scheduled OS notifications at `phaseEndsAt`, not an in-process timer, so the
app does not need a foreground service or `android_alarm_manager_plus`. On Android an ongoing low-priority
notification shows a live chronometer countdown, which covers the "persistent notification" requirement without
a service. iOS Live Activities need a native widget extension and are left for later (see PLATFORM_ALARMS.md).

## 4. Alarms scheduled in UTC

`zonedSchedule` takes a `TZDateTime`. The alarm is an absolute instant, so it is scheduled as
`TZDateTime.from(instant, tz.UTC)`. No time-zone database initialisation and no `flutter_timezone` dependency.

## 5. Exact alarms on Android

The manifest declares `USE_EXACT_ALARM` (granted without a prompt to timer apps on Android 13+) and
`SCHEDULE_EXACT_ALARM` (the user-grantable fallback). The app checks `canScheduleExactNotifications()`; when
exact alarms are not allowed it schedules an inexact alarm instead and shows one calm hint with a button to the
settings page. It never blocks the timer on a permission.

## 6. Sounds and vibration

The OS notification carries the sound and vibration when the phase ends on its own, because that is what works
with the screen locked. The in-app chime only plays when the person ends a phase by hand, or when notifications
are off. Two short synthesized WAV chimes (`assets/sounds`, also under `android/app/src/main/res/raw` and
`ios/Runner`) are deliberately soft and distinct: a rising two-note chime for approach done, a single low swell
for rest done. Vibration uses the notification channel plus `HapticFeedback`; the `vibration` package is not
needed.

## 7. XP curve

All in `lib/domain/xp/xp_rules.dart` with unit tests pinning the shape:

* Approach base `20 + 10 * log2(1 + minutes)`: a 1-minute approach is worth about 45 % of a 25-minute one.
* Rest is flat 12 XP. Rest is part of the method, not a reward to be earned, so it is honoured the same every time.
* Stopping early earns `10 + 5 * log2(1 + minutes)`: starting counts.
* Consistency multiplier 1.00 to 1.50: +0.05 on the first completed interval of a day, -0.03 per quiet day,
  never below 1.00, never shown as broken, and the number of quiet days is never displayed.
* Bonuses: first ever +50, back after 3+ days +40 (bigger than a normal day), first today +10, new highest rung
  on a task +25 (even if the attempt was stopped early), higher than last time on that task +15.
* Levels at `40 * (L - 1) * (L + 2)` XP with calm names. Level 2 arrives after about four small rounds.

## 8. One row per interval

A session row is one interval (approach or rest); the two share a `runId`. Outcomes are completed, snoozed
(completed after at least one extension) or abandoned. Abandoned is labelled "Stopped early" in the UI and still
earns XP. Nothing in the UI counts or names missed days.

## 9. Mood is optional and off by default

One-word chips before and after a session, enabled in Settings. They never block starting.

## 10. Claude call: direct HTTPS with structured output

Dart has no official Anthropic SDK, so `ClaudeTaskBreakdownService` is a thin `http` client for
`POST /v1/messages` using `output_config.format` with a JSON schema, which guarantees parseable output. The
model (`claude-opus-5-5` by default, `claude-haiku-5-5` is a cheaper option), effort, max tokens, system prompt and
base URL live in `BreakdownConfig`. The API key is stored in the platform keychain and only ever sent to the
configured base URL; pointing `baseUrl` at a small proxy is the way to keep the key off the device. The request
opts into server-side refusal fallback so a safety decline is retried on another model instead of failing.
The offline `MockTaskBreakdownService` is used whenever there is no key, and offered as a fallback on any error.
Breakdowns never touch the timer controller.

## 11. Identifiers

Dart package `depress_o_buster`. Android application id `app.depressobuster.depress_o_buster`. iOS bundle id
`app.depressobuster.depressOBuster` (iOS bundle ids cannot contain underscores; Flutter's template camel-cases it).

## 12. Navigation

Four tabs (Start, Tasks, Progress, Settings) and plain `Navigator` pushes for task detail and history. The Start
tab itself becomes the running timer, so starting is one tap with no route change and the back button can
never leave a timer behind. `go_router` was not needed.

## 13. Permission timing

Notification permission is requested on the first timer start, not at launch, so the first screen has no
dialog. If it is denied the timer still runs and a one-line hint explains that the chime only plays in the app.

## 14. Seed content

Six starter tasks with hand-written ladders (Just sit up, Laundry, Shower, Go outside, Reply to someone, Eat
something) and six presets (Just sit up 2/10, Edge of bed 3/20, Laundry proximity 5/30, Gentle 10/20, Classic
25/5 with a 20-minute long rest every 4, Deep 50/10). All editable. The home screen's big button is
"Sit up for 2 minutes", which uses the matching rung of the Just sit up task if it still exists.

## 15. iOS specifics

Alarms use `InterruptionLevel.timeSensitive`. For that level to break through Focus modes the Runner target needs
the Time Sensitive Notifications capability enabled in Xcode; it is not added to the project file automatically
because it changes signing. Critical alerts (which bypass the mute switch) need an Apple entitlement granted per
app and are not used. There is no ongoing notification on iOS.

## 16. Desktop and web

They compile and run the timer, tasks, XP and history. Web and Windows use `NoopAlarmService` (the in-app chime
plays while the page is open). Linux and macOS use `flutter_local_notifications` on a best-effort basis.

## 17. Widget tests and drift under fake async

flutter_test runs widget tests in a fake-async zone. drift schedules zero-delay timers when a stream is cancelled
and `close()` waits for them, and a query awaited directly after a cancelled stream can stall. The widget tests
therefore open the database with `closeStreamsSynchronously: true`, run verification reads inside
`tester.runAsync`, and do not close the in-memory database.

## 18. Future seams

* `CompanionService` (`lib/services/companion`): interface plus a no-op implementation and a design note covering
  on-device TTS versus streamed audio.
* `AudioContextService` (`lib/services/audio_context`): event-shaped interface so the timer never waits on it.
* `FeatureFlags` (`lib/core/feature_flags.dart`): all off.
* Body doubling / shared sessions: no interface yet. When it comes, the natural attach points are the
  `SessionContext` passed to side services, the `runId` that groups a run's intervals, and the alarm service
  (a shared session only needs the same `phaseEndsAt`). It must stay opt-in and must never surface anyone's
  missed days.
* Sync and backup: see decision 2 for what the schema needs. Settings and the API key are per device and would
  not sync.

## 19. Research doc

`docs/FUTURE_DIRECTIONS.md` was produced by a research pass with one agent per technique, an adversarial
source check per technique (every URL fetched), a draft, a critic, and a condensing pass that re-checked the
links. It informs design only; nothing in it is a product claim.

## 20. The rest alarm is scheduled together with the approach alarm

An adversarial review caught that the rest alarm was only scheduled when the approach ended inside the Dart
isolate, which never happens with the phone locked on iOS and may not on Android. The engine now emits both
alarms when an approach starts (and again on snooze and resume); the alarm ids are distinct, a cancel clears both,
and re-scheduling the same id when the approach actually ends is harmless. Rest is sacred; its end must be heard.

## 21. One notification channel per sound/vibration combination

On Android 8+ a channel owns its sound and vibration and ignores per-notification overrides, so the Chimes and
Vibration switches would have done nothing for OS alarms. Each phase has four channels and the alarm is posted to
the one matching the switches.

## 22. Rungs are identified by id, not position

Sessions store `rungId` (schema version 2, migration adds the column). Rung bonuses and the "highest rung so far"
view locate a past session's rung on the task's current ladder by id, skip rungs that no longer exist, and clamp
older rows that only have a position. Editing, inserting or replacing a ladder can no longer hand out or withhold
bonuses by accident.

## 23. Effects run in order, and phase controls settle for 700 ms

Side effects of consecutive timer events used to run as overlapping async loops; they are now chained in
dispatch order, so a later cancel cannot be overtaken by an earlier schedule and two sessions cannot be logged at
once. The controller also ignores "done early" and "stop" for 700 ms after a phase or status change, so the
second tap of a double tap on "Done early" cannot land on "End rest early" and end the rest at zero seconds.

## 24. Small things the review changed

Seeding runs once, by marker, so deleting every starter task or preset does not bring them back. The notification
permission is requested once, on the first start, and effects are serialised behind it so the first alarm is
scheduled after the answer. Release builds keep the raw chimes (`keep.xml`) and the main manifest declares
`INTERNET` for the Claude call. Linux is treated as "no scheduled alarms" so the in-app chime plays there. The
History screen is uncapped; the Progress "Recent" list keeps a limit. `lastActiveDay` is read back in UTC so zones
at UTC+12 and beyond do not lose their daily bonus. Per-day counts use calendar arithmetic, which is DST-safe. The
breakdown sheet gives new rungs real ids, never re-adds a rung the ladder already has, makes "Replace" the primary
action for a task-level result, and cannot be applied twice. On the web the Claude call sends the
`anthropic-dangerous-direct-browser-access` header.
