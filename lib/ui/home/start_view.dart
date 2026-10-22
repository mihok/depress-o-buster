import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_rests.dart';
import '../../domain/timer/timer_engine.dart';
import '../../services/providers.dart';
import '../tasks/rung_picker_sheet.dart';
import '../widgets/illustration.dart';
import '../widgets/mood_chips.dart';

final daysSinceActiveProvider = FutureProvider.autoDispose<int?>((ref) {
  ref.watch(progressProvider);
  return ref.watch(xpServiceProvider).daysSinceLastActive();
});

/// Open the app, tap once, the timer is running. Nothing is required first.
class StartView extends ConsumerStatefulWidget {
  const StartView({super.key});

  @override
  ConsumerState<StartView> createState() => _StartViewState();
}

class _StartViewState extends ConsumerState<StartView> {
  String? _mood;

  static const Duration _sitUpApproach = Duration(minutes: 2);
  static const Duration _sitUpRestFallback = Duration(minutes: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    final presets = ref.watch(presetsProvider).value ?? const <Preset>[];
    final daysSince = ref.watch(daysSinceActiveProvider).value;

    Task? sitUpTask;
    for (final t in tasks) {
      if (t.title == 'Just sit up') sitUpTask = t;
    }
    final sitUpLadder = sitUpTask == null
        ? const <LadderStep>[]
        : ref.watch(ladderProvider(sitUpTask.id)).value ?? const <LadderStep>[];
    LadderStep? sitUpRung;
    for (final s in sitUpLadder) {
      if (s.text.trim().toLowerCase() == 'sit up for 2 minutes') {
        sitUpRung = s;
        break;
      }
    }
    // The same step shows the same rest everywhere: the one-tap start uses
    // the ladder's rest for "Sit up for 2 minutes" (the floor task is seeded
    // with a gentle rest unit), and only falls back to the preset's rest
    // when the task or step is gone.
    Preset? sitUpPreset;
    for (final p in presets) {
      if (p.name == 'Just sit up') sitUpPreset = p;
    }
    final sitUpRest = sitUpTask != null && sitUpRung != null
        ? LadderRests.restFor(unit: LadderRests.unitFor(sitUpTask, settings.rest), position: sitUpRung.position)
        : sitUpPreset?.rest ?? _sitUpRestFallback;

    return Scaffold(
      appBar: AppBar(title: const Text('Depress-o-buster')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppIllustration(
            daysSince != null && daysSince >= 3 ? Illustration.stoneDawn : Illustration.stoneStill,
            height: 124,
          ),
          const SizedBox(height: 16),
          if (daysSince != null && daysSince >= 3) ...[
            Text('Good to see you.', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Anything at all counts today.', style: theme.textTheme.bodySmall),
            const SizedBox(height: 20),
          ],
          if (settings.askMood) ...[
            MoodChips(
              label: 'Right now I feel (optional)',
              selected: _mood,
              onChanged: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 20),
          ],
          _BigStartButton(
            title: 'Sit up for 2 minutes',
            subtitle: settings.restFirst
                ? 'after ${formatWords(sitUpRest)} of rest to get ready'
                : 'then rest for ${formatWords(sitUpRest)}',
            onPressed: () => _start(
              // The step's own round (its ladder rest, no long rest) when it
              // exists, but always exactly two minutes: the button says so,
              // and the floor is a promise whatever the step's length has
              // been stretched to on the task screen.
              config: sitUpTask != null && sitUpRung != null
                  ? LadderRests.roundFor(
                      base: settings.timerConfig,
                      task: sitUpTask,
                      step: sitUpRung,
                      fallbackUnit: settings.rest,
                    ).copyWith(approach: _sitUpApproach)
                  : settings.timerConfig.copyWith(
                      approach: _sitUpApproach,
                      rest: sitUpRest,
                      clearLongRest: true,
                      cyclesBeforeLongRest: 0,
                    ),
              target: ApproachTarget(
                taskId: sitUpTask?.id,
                taskTitle: 'Just sit up',
                rungId: sitUpRung?.id,
                rungPosition: sitUpRung?.position,
                rungText: sitUpRung?.text ?? 'Sit up for 2 minutes',
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Or use your ratio', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          _RatioCard(settings: settings, presets: presets),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => _start(config: settings.timerConfig, target: null),
            child: Text(
              settings.restFirst
                  ? 'Rest ${formatWords(settings.rest)}, then a ${formatWords(settings.approach)} approach'
                  : 'Start a ${formatWords(settings.approach)} approach',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickRung,
            icon: const Icon(Icons.stairs_outlined),
            label: const Text('Pick a step from a task'),
          ),
          const SizedBox(height: 28),
          Text(
            settings.restFirst
                ? 'An approach is being near the thing, not doing the thing. The rest comes first: '
                      'time to get ready, then the chime says it is time for the step, or start it sooner '
                      'whenever you are ready.'
                : 'An approach is being near the thing, not doing the thing. Rest is part of the method.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _pickRung() async {
    final choice = await showRungPicker(context);
    if (choice == null || !mounted) return;
    final settings = ref.read(settingsProvider);
    await _start(
      config: LadderRests.roundFor(
        base: settings.timerConfig,
        task: choice.task,
        step: choice.step,
        fallbackUnit: settings.rest,
      ),
      target: ApproachTarget(
        taskId: choice.task.id,
        taskTitle: choice.task.title,
        rungId: choice.step.id,
        rungPosition: choice.step.position,
        rungText: choice.step.text,
      ),
    );
  }

  Future<void> _start({required TimerConfig config, ApproachTarget? target}) {
    final mood = _mood;
    setState(() => _mood = null);
    return ref.read(timerControllerProvider.notifier).start(
      config: config,
      target: target,
      moodBefore: mood,
    );
  }
}

class _BigStartButton extends StatelessWidget {
  const _BigStartButton({required this.title, required this.subtitle, required this.onPressed});

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(72, 96),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class _RatioCard extends ConsumerWidget {
  const _RatioCard({required this.settings, required this.presets});

  final dynamic settings;
  final List<Preset> presets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = settings;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (s.restFirst
                      ? 'Rest ${formatWords(s.rest)} · Approach ${formatWords(s.approach)}'
                      : 'Approach ${formatWords(s.approach)} · Rest ${formatWords(s.rest)}') +
                  (s.longRest != null && s.cyclesBeforeLongRest > 0
                      ? ' · Long rest ${formatWords(s.longRest!)} every ${s.cyclesBeforeLongRest}'
                      : ''),
              style: theme.textTheme.titleMedium,
            ),
            if (presets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in presets)
                    ChoiceChip(
                      label: Text('${p.name} ${p.ratioLabel}'),
                      selected: p.id == s.lastPresetId,
                      onSelected: (_) => ref.read(settingsProvider.notifier).applyPreset(p),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
