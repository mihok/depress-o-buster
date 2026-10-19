import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/timer/timer_engine.dart';
import '../../services/providers.dart';
import '../widgets/illustration.dart';
import '../widgets/logged_feedback.dart';
import '../widgets/mood_chips.dart';

/// The running timer. Same respect for rest as for the approach.
class TimerView extends ConsumerWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(nowTickProvider);
    final state = ref.watch(timerControllerProvider);
    final theme = Theme.of(context);
    final now = clock.now();
    final color = state.isApproach ? AppColors.approach : AppColors.rest;
    final target = state.target;
    final finished = state.status == TimerStatus.finished;

    return Scaffold(
      appBar: AppBar(
        title: Text(finished ? '${state.phase.label} complete' : state.phase.label),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    if (target != null && !target.isEmpty)
                      Text(
                        target.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    if (!finished && state.isPreparing) ...[
                      const SizedBox(height: 6),
                      Text(
                        state.config.autoStartNext
                            ? 'Time to get ready. The chime says when the step starts.'
                            : 'Time to get ready. Start the step whenever you are.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (!finished) ...[
                      AppIllustration(
                        state.isApproach ? Illustration.pathAhead : Illustration.restMoon,
                        height: 112,
                        opacity: state.isPaused ? 0.6 : 1,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        formatClock(state.remaining(now)),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 80,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.isPaused
                            ? 'Paused'
                            : 'Ends at ${formatTime(state.phaseEndsAt ?? now)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: state.progress(now),
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.15),
                          minHeight: 6,
                        ),
                      ),
                    ] else
                      _FinishedPanel(state: state),
                    const SizedBox(height: 12),
                    // Feedback for the phase that just ended in this round: the
                    // rest's XP during the step, the step's XP during its rest.
                    LoggedFeedback(runId: state.runId),
                    const _AlarmHints(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _Controls(state: state),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishedPanel extends ConsumerStatefulWidget {
  const _FinishedPanel({required this.state});

  final TimerState state;

  @override
  ConsumerState<_FinishedPanel> createState() => _FinishedPanelState();
}

class _FinishedPanelState extends ConsumerState<_FinishedPanel> {
  String? _moodAfter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final askMood = ref.watch(settingsProvider.select((s) => s.askMood));
    final lastApproach = ref.watch(lastApproachLoggedProvider);
    final preparing = widget.state.isPreparing;
    return Column(
      children: [
        AppIllustration(
          preparing
              ? Illustration.pathAhead
              : widget.state.phase.isRest
                  ? Illustration.stoneDawn
                  : Illustration.rippleDone,
          height: 112,
        ),
        const SizedBox(height: 20),
        Text(
          widget.state.phase.isRest ? 'Rest complete.' : 'Approach complete.',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          preparing ? 'The step is next, whenever you are ready.' : 'Ready when you are.',
          style: theme.textTheme.bodySmall,
        ),
        if (askMood && lastApproach != null) ...[
          const SizedBox(height: 20),
          MoodChips(
            label: 'And now I feel (optional)',
            selected: _moodAfter,
            onChanged: (m) {
              setState(() => _moodAfter = m);
              ref
                  .read(sessionRepositoryProvider)
                  .updateMood(lastApproach.session.id, after: m ?? '');
            },
          ),
        ],
      ],
    );
  }
}

class _AlarmHints extends ConsumerWidget {
  const _AlarmHints();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmServiceProvider);
    if (!alarms.isSupported) return const SizedBox.shrink();
    final caps = ref.watch(alarmCapabilitiesProvider).value ?? alarms.capabilities;
    final theme = Theme.of(context);
    final children = <Widget>[];
    if (!caps.notificationsGranted) {
      children.add(
        _Hint(
          text: 'Notifications are off, so the chime only plays while the app is open.',
          action: 'Allow notifications',
          onPressed: () async {
            await alarms.ensurePermissions();
            ref.invalidate(alarmCapabilitiesProvider);
          },
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && !caps.exactAlarmsAllowed) {
      children.add(
        _Hint(
          text: 'Without exact alarms the chime may be a few minutes late.',
          action: 'Allow exact alarms',
          onPressed: () async {
            await alarms.openExactAlarmSettings();
            ref.invalidate(alarmCapabilitiesProvider);
          },
        ),
      );
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!,
        child: Column(children: children),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text, required this.action, required this.onPressed});

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, textAlign: TextAlign.center),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.state});

  final TimerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(timerControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final snoozeBy = state.config.snoozeBy;

    Future<void> confirmStop() async {
      final stop = await showModalBottomSheet<bool>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Stop this round?', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Starting still counts. It is logged, nothing is lost.', style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 20),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Stop')),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep going')),
              ],
            ),
          ),
        ),
      );
      if (stop == true) controller.abandon();
    }

    switch (state.status) {
      case TimerStatus.running when state.isApproach:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.snooze(),
                    child: Text('+${formatWords(snoozeBy)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.finishEarly,
                    child: const Text('Done early'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: controller.pause, child: const Text('Pause'))),
                const SizedBox(width: 12),
                Expanded(child: TextButton(onPressed: confirmStop, child: const Text('Stop'))),
              ],
            ),
          ],
        );
      case TimerStatus.running when state.isPreparing:
        // The rest before the step: more time is always allowed, and the
        // step can start the moment the person feels ready.
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.snooze(),
                    child: Text('+${formatWords(snoozeBy)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.finishEarly,
                    child: const Text('Start the step'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: controller.pause, child: const Text('Pause'))),
                const SizedBox(width: 12),
                Expanded(child: TextButton(onPressed: confirmStop, child: const Text('Stop'))),
              ],
            ),
          ],
        );
      case TimerStatus.running:
        return Column(
          children: [
            FilledButton(
              onPressed: controller.finishEarly,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.secondary,
                foregroundColor: scheme.onSecondary,
              ),
              child: const Text('End rest early'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: controller.pause, child: const Text('Pause'))),
                const SizedBox(width: 12),
                Expanded(child: TextButton(onPressed: confirmStop, child: const Text('Stop'))),
              ],
            ),
          ],
        );
      case TimerStatus.paused:
        return Column(
          children: [
            FilledButton(onPressed: controller.resume, child: const Text('Resume')),
            const SizedBox(height: 12),
            Row(
              children: [
                if (state.isApproach)
                  Expanded(
                    child: TextButton(
                      onPressed: controller.finishEarly,
                      child: const Text('Done early'),
                    ),
                  ),
                if (state.isApproach) const SizedBox(width: 12),
                Expanded(child: TextButton(onPressed: confirmStop, child: const Text('Stop'))),
              ],
            ),
          ],
        );
      case TimerStatus.finished when state.isPreparing:
        // Automatic start is off: the step is started by hand after its rest.
        return Column(
          children: [
            FilledButton(onPressed: controller.startApproach, child: const Text('Start the step')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: controller.reset, child: const Text('Done for now')),
          ],
        );
      case TimerStatus.finished when state.isApproach && !state.config.restFirst:
        // Automatic start is off: the rest is started by hand.
        return Column(
          children: [
            FilledButton(
              onPressed: controller.startRest,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.secondary,
                foregroundColor: scheme.onSecondary,
              ),
              child: Text('Start ${TimerEngine.restPhaseFor(state.config, state.cycleIndex).label.toLowerCase()}'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => controller.start(config: state.config, target: state.target),
                    child: const Text('Another round'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: TextButton(onPressed: controller.reset, child: const Text('Done for now'))),
              ],
            ),
          ],
        );
      case TimerStatus.finished:
        return Column(
          children: [
            FilledButton(
              onPressed: () => controller.start(config: state.config, target: state.target),
              child: const Text('Another round'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: controller.reset, child: const Text('Done for now')),
          ],
        );
      case TimerStatus.idle:
        return const SizedBox.shrink();
    }
  }
}
