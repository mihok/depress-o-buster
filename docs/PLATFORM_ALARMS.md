# Alarms per platform

How the "phase over" alarm is delivered, what it needs, and what can still go wrong.

## The approach in one paragraph

When an approach starts, the app schedules two local notifications at once: one for the instant the approach
ends and one for the instant the rest that follows it ends. The remaining time is always `phaseEndsAt - now`.
The OS fires each notification with its own sound and vibration whether the app is in the foreground, in the
background, suspended, or not running at all; the rest-end alarm does not need the app to be awake at the moment
the approach ends. Snoozing or pausing moves both alarms. When the app comes back it catches up with a single
tick, logs the phases that ended, and continues. The timer never depends on the app process staying alive.

## Android

* Scheduling: `flutter_local_notifications` `zonedSchedule` in `AndroidScheduleMode.alarmClock`, which is the
  mode Android reserves for user-visible alarms and the least likely to be deferred by Doze.
* Permissions (declared in `AndroidManifest.xml`): `POST_NOTIFICATIONS` (asked on the first timer start),
  `USE_EXACT_ALARM` (auto-granted to timer apps on Android 13+), `SCHEDULE_EXACT_ALARM` (fallback, grantable from
  Settings), `RECEIVE_BOOT_COMPLETED` (re-registers pending alarms after a reboot), `VIBRATE`.
* Receivers: `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` are declared for the plugin.
* Channels: on Android 8+ sound and vibration belong to the channel, not the notification, so there is one
  channel per phase and per combination of the Chimes and Vibration switches (`approach_done`,
  `approach_done_silent`, `approach_done_novibe`, `approach_done_silent_novibe`, and the same for `rest_done`),
  all at max importance with alarm audio attributes so the chime plays over the alarm stream and respects the
  alarm volume. `ongoing_timer` is low importance and silent, for the live countdown.
* Live countdown: an ongoing notification with `usesChronometer` and `chronometerCountDown` counts down to the
  end of the phase in the shade, with `timeoutAfter` set to the end of the phase so the system removes it on its
  own if the app is frozen or killed. No foreground service is needed for this.
* Release builds: `res/raw/keep.xml` stops the resource shrinker from removing the chimes, which are only
  referenced by name from Dart. The release APK was inspected to confirm both files are present.
* `INTERNET` is declared for the optional Claude breakdown call only; nothing else uses the network.
* Desugaring: `isCoreLibraryDesugaringEnabled = true` plus `desugar_jdk_libs` in `android/app/build.gradle.kts`
  (required by the plugin for scheduled notifications).

Known limitations:

* If exact alarms are not allowed (possible on Android 14+ when `USE_EXACT_ALARM` is not honoured), the alarm is
  scheduled inexactly and can arrive several minutes late. The timer screen shows a hint with a button to the
  system page.
* Aggressive battery savers on some devices (Xiaomi, Huawei, Samsung "sleeping apps", OnePlus) can block or delay
  alarms. Exempting the app from battery optimisation fixes it; Settings explains this.
* Google Play policy restricts `USE_EXACT_ALARM` to alarm, timer and calendar apps. This app is a timer, which is
  the intended use, but a store listing should say so.
* The chime respects the alarm volume, not the media volume. Do Not Disturb can still silence it unless the user
  allows alarms through.

## iOS

* Scheduling: `zonedSchedule` with a `DarwinNotificationDetails` that names the bundled sound
  (`approach_done.wav`, `rest_done.wav` in the Runner target) and `InterruptionLevel.timeSensitive`.
* Permission: alert and sound, asked on the first timer start. Badge is not requested.
* Sounds: the files are added to the Xcode Resources phase by hand in `project.pbxproj`. Keep them under 30 seconds
  and in a format iOS accepts (WAV, AIFF, CAF).

Known limitations:

* iOS gives apps no background execution for timers. Everything after the app leaves the foreground is the
  scheduled notification. The in-app chime, haptics and the countdown screen only run while the app is open.
* Notification sounds obey the ring/silent switch and Focus. Time Sensitive notifications can break through Focus
  only if the Runner target has the Time Sensitive Notifications capability enabled in Xcode (Signing &
  Capabilities). It is not enabled by default because it changes signing. Critical Alerts, which play even on
  silent, need an entitlement that Apple grants per app on request and are not used.
* There is no ongoing notification or lock-screen countdown. A Live Activity would do this and needs a native
  WidgetKit extension; the seam for it is `AlarmService.showOngoing`, which iOS currently ignores.
* If the user force-quits the app the scheduled notification still fires; the app logs the phase when next opened.

## macOS

Best effort through the same plugin. Sounds are not bundled in the macOS target yet, so the default sound plays.

## Linux, Windows and web

No scheduled notifications (the plugin cannot schedule on Linux, and web and Windows use `NoopAlarmService`).
The in-app chime and haptic play while the window or tab is open; the app knows alarms are unavailable there,
so it never suppresses the in-app chime in favour of an OS alarm.

## Checking it works

1. Start a 30-second approach with a 1-minute rest, lock the phone before it ends and keep it locked. Expect the
   approach chime at 0:30 and the rest chime a minute later, without touching the phone.
2. Start an approach, swipe the app away, wait past the end. Expect the notification; open the app and expect the
   rest already in progress with the right remaining time.
3. Android: Settings > Alarms shows "Allowed" for both notifications and exact alarms. If exact alarms show
   "Off", tap Allow.
