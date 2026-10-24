import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_rests.dart';
import '../../domain/ladder/step_scaling.dart';
import '../../services/providers.dart';
import '../root_shell.dart';
import '../widgets/duration_picker_tile.dart';
import '../widgets/stretch_slider.dart';
import 'breakdown_sheet.dart';

/// The ladder editor. Any step can be started, edited, moved, swiped away or
/// removed, and the time on every step can be stretched or shrunk together.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  /// The multiplier the step length slider is held at. The tiles show their
  /// times scaled by it live; it returns to ×1 once the new times are saved
  /// and have come back through the ladder stream, so there is no frame in
  /// which the old times reappear.
  double _previewFactor = 1;
  bool _draggingSlider = false;

  /// The same for the rest unit: the tiles show their rests scaled by it
  /// while the rest slider is held, until the task stream echoes the saved
  /// unit.
  double _restFactor = 1;
  bool _draggingRest = false;

  /// The Undo bar for a burst of slider releases, of either slider or both.
  /// Undo puts back what was there before the first release of the burst,
  /// not the last; the burst ends when its bar closes.
  _BurstBar? _burst;

  /// Open bursts by task id. A bar outlives its screen (it is the app's
  /// messenger's), so a screen opened again for the same task joins the
  /// burst that is still up rather than stacking a second bar whose Undo
  /// would put the first burst's change back.
  static final Map<String, _BurstBar> _openBursts = {};

  _BurstBar? _openBurst(Task task) {
    final bar = _burst ?? _openBursts[task.id];
    return bar != null && bar.open ? bar : null;
  }

  /// Steps swiped away and hidden at once, so a dismissed tile leaves the
  /// tree in the same frame whatever the database does. An undo unhides.
  final Set<String> _removedIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    Task? task;
    for (final t in tasks) {
      if (t.id == widget.taskId) task = t;
    }
    final ladder = ref.watch(ladderProvider(widget.taskId)).value ?? const <LadderStep>[];
    final repo = ref.read(taskRepositoryProvider);
    final settings = ref.watch(settingsProvider);
    ref.listen(ladderProvider(widget.taskId), (_, _) {
      if (_previewFactor != 1 && !_draggingSlider) {
        setState(() => _previewFactor = 1);
      }
    });
    ref.listen(tasksProvider, (_, _) {
      if (_restFactor != 1 && !_draggingRest) {
        setState(() => _restFactor = 1);
      }
    });

    if (task == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This task is gone.')));
    }
    final t = task;
    final previewed = _previewFactor == 1 ? ladder : StepScaling.scaleAll(ladder, _previewFactor);
    final shown = [
      for (final s in previewed)
        if (!_removedIds.contains(s.id)) s,
    ];
    final hasTimes = ladder.any((s) => s.suggestedDuration != null);
    final unit = LadderRests.unitFor(t, settings.rest);
    // The preview is the same function of the factor as the save, so what
    // is shown while holding is what a release gives.
    final shownUnit = _restFactor == 1 ? unit : LadderRests.clampUnit(LadderRests.scaleUnit(unit, _restFactor));
    // Where the unit comes from; left out while a drag previews another.
    final unitSource = shownUnit != unit
        ? ''
        : t.restUnit != null
        ? ', this task\'s own'
        : settings.rest == unit
        ? ', from Settings'
        : ', the ${unit == LadderRests.maxUnit ? 'most' : 'least'} a unit can be (Settings: ${formatWords(settings.rest)})';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'rename':
                  final name = await _textDialog(context, title: 'Rename task', initial: t.title);
                  if (name != null && name.trim().isNotEmpty) {
                    await repo.updateTask(t.copyWith(title: name.trim()));
                  }
                case 'delete':
                  final ok = await _confirm(context, 'Delete "${t.title}" and its ladder? History is kept.');
                  if (ok && context.mounted) {
                    await repo.deleteTask(t.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete task')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // One scrollable for the reminder, the fold and the steps, so an
            // unfolded card scrolls instead of squeezing the ladder off a
            // small screen.
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Text(
                      'Each step\'s rest comes from its place in the ladder, not its length: '
                      'move a step and its rest moves with it.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                // The stretch sliders and the full explanation fold away so
                // the ladder stays in view; the tiles preview live while a
                // slider is held.
                SliverToBoxAdapter(
                  child: Card(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: ExpansionTile(
              title: Text(hasTimes ? 'Adjust step length and rest unit' : 'Adjust rest unit'),
              subtitle: Text('Rest unit ${formatWords(shownUnit)}$unitSource'),
              shape: const Border(),
              collapsedShape: const Border(),
              // Keep the sliders alive while folded, so a drag is never cut
              // off by a collapse.
              maintainState: true,
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Each step has its own rest ${settings.restFirst ? 'before' : 'after'} it, '
                    'from its place in the ladder: ${LadderRests.describe(shownUnit)}.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (hasTimes)
                  _StretchRow(
                    title: 'Step length',
                    value: StepScaling.label(_previewFactor),
                    factor: _previewFactor,
                    onChangeStart: () => _draggingSlider = true,
                    onChanged: (f) => setState(() => _previewFactor = f),
                    onChangeEnd: (f) => _applyStepLength(t, f),
                  ),
                _StretchRow(
                  title: 'Rest unit',
                  value: formatWords(shownUnit),
                  factor: _restFactor,
                  onChangeStart: () => _draggingRest = true,
                  onChanged: (f) => setState(() => _restFactor = f),
                  onChangeEnd: (f) => _applyRestUnit(t, unit, f),
                ),
                if (t.restUnit != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => _followSettingsRest(t),
                      child: const Text('Use the rest from Settings again'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Hold a slider at either end and it keeps going, up to ten times each release; '
                    'the rest unit stays within ${formatWords(LadderRests.minUnit)} to '
                    '${formatWords(LadderRests.maxUnit)}. Each release can be undone.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
                  ),
                ),
                if (ladder.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No steps yet. Add one, or break the task down.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    sliver: SliverReorderableList(
                    itemCount: shown.length,
                    // The step being moved lifts a little, as it did with
                    // ReorderableListView's default.
                    proxyDecorator: (child, index, animation) => AnimatedBuilder(
                      animation: animation,
                      builder: (_, child) => Material(
                        color: Colors.transparent,
                        elevation: 4 * Curves.easeInOut.transform(animation.value),
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      ),
                      child: child,
                    ),
                    onReorderItem: (oldIndex, newIndex) => repo.reorderSteps(t.id, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final step = shown[index];
                      return Dismissible(
                        key: ValueKey(step.id),
                        direction: DismissDirection.endToStart,
                        background: _RemoveBackground(theme: theme),
                        onDismissed: (_) => _removeStep(t, step),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                child: Text('${index + 1}', style: theme.textTheme.labelMedium),
                              ),
                              title: Text(step.text),
                              subtitle: Text(
                                'Rest ${formatWords(LadderRests.restFor(unit: shownUnit, position: index))}'
                                ' · Step ${step.suggestedDuration == null ? '${formatWords(settings.approach)} (the usual length)' : formatWords(step.suggestedDuration!)}',
                              ),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Icon(Icons.drag_handle),
                                ),
                              ),
                              onTap: () => _rungActions(context, ref, t, ladder, step),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // The Scaffold's own bottom slot rather than the end of the body: the
      // Scaffold then places a floating snack bar above these buttons instead
      // of over them, and the SafeArea keeps them clear of the navigation bar
      // drawn over the app.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => showBreakdownSheet(context, task: t, ladder: ladder),
                  icon: const Icon(Icons.unfold_more),
                  label: const Text('Break this down smaller'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () async {
                  final text = await _textDialog(context, title: 'New step');
                  if (text != null && text.trim().isNotEmpty) {
                    await repo.addStep(t.id, text.trim());
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The slider was let go: save the scaled times for every step at once.
  /// The preview stays on until the ladder stream echoes the saved times
  /// (see [_previewFactor]); when nothing changed there is no echo, so the
  /// slider is reset here.
  Future<void> _applyStepLength(Task task, double factor) async {
    _draggingSlider = false;
    if (factor == 1) return;
    final repo = ref.read(taskRepositoryProvider);
    // What Undo puts back, read before anything is saved. Hand-set times
    // are precious: the previous ones can be put back.
    final before = await repo.ladder(task.id);
    final changed = await repo.scaleStepDurations(task.id, factor);
    if (!mounted) return;
    if (changed == 0) {
      setState(() => _previewFactor = 1);
      return;
    }
    _joinBurst(
      task,
      (bar) => bar.stepsBefore ??= before,
      changed == 1 ? 'One step time changed' : '$changed step times changed',
    );
  }

  /// The rest slider was let go: save the new unit for this task, with a
  /// way back. The slider returns to ×1 once the task stream echoes. A
  /// release that only pushes past an end of the range says so.
  Future<void> _applyRestUnit(Task task, Duration unit, double factor) async {
    _draggingRest = false;
    final next = LadderRests.clampUnit(LadderRests.scaleUnit(unit, factor));
    if (factor == 1 || next == unit) {
      if (!mounted) return;
      setState(() => _restFactor = 1);
      final atEnd = (factor > 1 && unit == LadderRests.maxUnit) || (factor < 1 && unit == LadderRests.minUnit);
      if (atEnd) _sayAtEnd(task, unit);
      return;
    }
    await _changeRestUnit(task, next, 'Rest unit is now ${formatWords(next)}');
  }

  /// Back to the rest from Settings: the task's own unit is dropped.
  Future<void> _followSettingsRest(Task task) =>
      _changeRestUnit(task, null, 'Rest unit follows Settings again');

  /// Save a rest unit (null: follow Settings) with an Undo that goes back to
  /// before the first change of a burst, which may itself be "follow
  /// Settings".
  Future<void> _changeRestUnit(Task task, Duration? next, String text) async {
    final repo = ref.read(taskRepositoryProvider);
    final before = task.restUnit;
    await repo.setRestUnit(task.id, next);
    if (!mounted) return;
    _joinBurst(task, (bar) {
      if (!bar.restTouched) {
        bar.restTouched = true;
        bar.restBefore = before;
      }
    }, text);
  }

  /// A change joins the open burst, or starts one. [remember] records what
  /// this change's slider had before, the first time it joins; the bar then
  /// shows [text], or names both when both sliders have been used.
  void _joinBurst(Task task, void Function(_BurstBar bar) remember, String text) {
    final open = _openBurst(task);
    if (open != null) {
      _burst = open;
      remember(open);
      open.touch(open.stepsBefore != null && open.restTouched ? 'Step times and rest unit changed' : text);
      return;
    }
    // The bar outlives this screen (it is the app's messenger's), so Undo
    // takes the repository with it rather than reaching for ref later.
    final repo = ref.read(taskRepositoryProvider);
    late final _BurstBar bar;
    bar = _BurstBar(
      ScaffoldMessenger.of(context),
      text: text,
      onUndo: () => _undoBurst(repo, task, bar),
      onClosed: () {
        if (identical(_burst, bar)) _burst = null;
        if (identical(_openBursts[task.id], bar)) _openBursts.remove(task.id);
      },
    );
    remember(bar);
    _burst = bar;
    _openBursts[task.id] = bar;
  }

  /// Put back whatever the burst changed: the step times, the rest unit, or
  /// both. The task may be gone by now; then there is nothing to put back.
  Future<void> _undoBurst(TaskRepository repo, Task task, _BurstBar bar) async {
    try {
      final steps = bar.stepsBefore;
      if (steps != null) await repo.restoreStepDurations(task.id, steps);
      if (bar.restTouched) await repo.setRestUnit(task.id, bar.restBefore);
    } catch (e) {
      debugPrint('undo failed: $e');
    }
  }

  /// The rest slider was pushed past an end of the unit's range: nothing
  /// changed, and the person is told why. An open burst bar keeps its own
  /// words (they say what its Undo does) and gets the note after them,
  /// naming the rest unit unless the words already do; otherwise a quiet
  /// bar of its own says it.
  void _sayAtEnd(Task task, Duration unit) {
    final end = unit == LadderRests.maxUnit ? 'the longest it goes' : 'the shortest it goes';
    final open = _openBurst(task);
    if (open != null) {
      final aboutRest = open.words.startsWith('Rest unit is now');
      open.touch(open.words, note: aboutRest ? end : 'the rest unit stays at ${formatWords(unit)}, $end');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The rest unit stays at ${formatWords(unit)}, $end'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Remove a step with a quiet way back. Undo restores the very same step
  /// (same id and position), so its history still counts. A slider's Undo
  /// bar makes way for this one: the removed step matters more.
  Future<void> _removeStep(Task task, LadderStep step) async {
    final repo = ref.read(taskRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removedIds.add(step.id));
    _openBurst(task)?.dismiss();
    await repo.deleteStep(task.id, step.id);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Step removed'),
        behavior: SnackBarBehavior.floating,
        // A snack bar with an action would otherwise stay until dismissed.
        persist: false,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // The task may be gone by now; then there is nothing to put back.
            try {
              await repo.restoreStep(task.id, step);
            } catch (e) {
              debugPrint('restoreStep failed: $e');
            }
            if (mounted) setState(() => _removedIds.remove(step.id));
          },
        ),
      ),
    );
  }

  Future<void> _rungActions(
    BuildContext context,
    WidgetRef ref,
    Task task,
    List<LadderStep> ladder,
    LadderStep step,
  ) async {
    final settings = ref.read(settingsProvider);
    // The same round the Start tab's picker starts: this step's length, the
    // rest its place earns, and nothing else.
    final round = LadderRests.roundFor(
      base: settings.timerConfig,
      task: task,
      step: step,
      fallbackUnit: settings.rest,
    );
    final duration = round.approach;
    final rest = round.rest;
    final repo = ref.read(taskRepositoryProvider);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      // As tall as its content: capped at nine sixteenths of a short screen,
      // the sheet would clip the Edit and Remove row once the navigation
      // bar's inset is added below them.
      isScrollControlled: true,
      // useSafeArea clears the top only; the bottom is the sheet's to clear.
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(step.text, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(timerControllerProvider.notifier).start(
                    config: round,
                    target: ApproachTarget(
                      taskId: task.id,
                      taskTitle: task.title,
                      rungId: step.id,
                      rungPosition: step.position,
                      rungText: step.text,
                    ),
                  );
                  ref.read(rootTabProvider.notifier).set(0);
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: Text(
                  settings.restFirst
                      ? 'Rest ${formatWords(rest)}, then a ${formatWords(duration)} approach here'
                      : 'Start a ${formatWords(duration)} approach here, then rest ${formatWords(rest)}',
                ),
              ),
              if (settings.restFirst) ...[
                const SizedBox(height: 6),
                Text(
                  'The rest is time to get ready. The step can start sooner, whenever you feel like it.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showBreakdownSheet(context, task: task, ladder: ladder, rung: step);
                },
                child: const Text('Break this step down smaller'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final edited = await _editStepDialog(
                          context,
                          step,
                          usual: settings.approach,
                          rest: rest,
                          restFirst: settings.restFirst,
                        );
                        if (edited != null) await repo.updateStep(edited);
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeStep(task, step);
                      },
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled [StretchSlider]: hold it at either end and it keeps going.
/// Relative: after each release the slider returns to ×1 and [value] shows
/// what was saved.
class _StretchRow extends StatelessWidget {
  const _StretchRow({
    required this.title,
    required this.value,
    required this.factor,
    required this.onChanged,
    required this.onChangeEnd,
    this.onChangeStart,
  });

  final String title;
  final String value;
  final double factor;
  final VoidCallback? onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            Text(value, style: theme.textTheme.labelLarge),
          ],
        ),
        StretchSlider(
          factor: factor,
          semanticsLabel: title,
          onChanged: (f) {
            if (factor == 1 && f != 1) onChangeStart?.call();
            onChanged(f);
          },
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}

/// What shows behind a tile as it is swiped away. Quiet on purpose.
class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline, color: muted),
                const SizedBox(width: 8),
                Text('Remove', style: theme.textTheme.labelLarge?.copyWith(color: muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> _textDialog(BuildContext context, {required String title, String initial = ''}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextDialog(title: title, initial: initial),
  );
}

/// One line of text. The controller belongs to the dialog's own State, so it
/// outlives the exit transition (a field disposed in `whenComplete` is still
/// drawn once more while the route leaves).
class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Save')),
      ],
    );
  }
}

/// Edit a step's text and suggested time. [usual] is the approach length
/// used when a step has no time of its own.
Future<LadderStep?> _editStepDialog(
  BuildContext context,
  LadderStep step, {
  required Duration usual,
  required Duration rest,
  required bool restFirst,
}) {
  return showDialog<LadderStep>(
    context: context,
    builder: (_) => _EditStepDialog(step: step, usual: usual, rest: rest, restFirst: restFirst),
  );
}

class _EditStepDialog extends StatefulWidget {
  const _EditStepDialog({
    required this.step,
    required this.usual,
    required this.rest,
    required this.restFirst,
  });

  final LadderStep step;
  final Duration usual;

  /// The rest that goes with this step, from its place in the ladder.
  final Duration rest;

  /// Whether that rest comes before the step (the default) or after it.
  final bool restFirst;

  /// What the dialog says about the rest: where it comes from, and what
  /// would change it. Past the last multiplier every step shares the
  /// longest rest, so moving the step down the ladder changes nothing.
  String get restNote {
    final when = restFirst ? 'before' : 'after';
    final last = LadderRests.multipliers.length;
    if (step.position >= last - 1) {
      return 'Rest $when this step: ${formatWords(rest)}, the longest rest, shared by step $last and '
          'every step after it. Move it to step ${last - 1} or earlier for a shorter one.';
    }
    return 'Rest $when this step: ${formatWords(rest)}, from its place in the ladder '
        '(step ${step.position + 1}). Move the step to change it.';
  }

  @override
  State<_EditStepDialog> createState() => _EditStepDialogState();
}

class _EditStepDialogState extends State<_EditStepDialog> {
  late final TextEditingController _text = TextEditingController(text: widget.step.text);
  late Duration? _duration = widget.step.suggestedDuration;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _duration;
    return AlertDialog(
      title: const Text('Edit step'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Step'),
          ),
          const SizedBox(height: 12),
          ListTileTheme.merge(
            contentPadding: EdgeInsets.zero,
            child: DurationPickerTile(
              title: 'Suggested time',
              value: duration ?? widget.usual,
              subtitle: duration == null ? 'Not set, the usual ${formatWords(widget.usual)} is used' : null,
              onChanged: (d) => setState(() => _duration = d),
            ),
          ),
          if (duration != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _duration = null),
                child: const Text('Use the usual length instead'),
              ),
            ),
          const SizedBox(height: 8),
          Text(widget.restNote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final text = _text.text.trim();
            Navigator.pop(
              context,
              widget.step.copyWith(
                text: text.isEmpty ? widget.step.text : text,
                suggestedDuration: _duration,
                clearSuggestedDuration: _duration == null,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<bool> _confirm(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ),
  );
  return result ?? false;
}

/// One snack bar for a burst of slider releases. It appears on the first
/// release and its words follow the later ones; Undo puts back what was
/// there before the first. It closes six seconds after the last release (or
/// after it first appears, if it had to wait behind another bar), and it
/// never pushes another bar off the screen: a "Step removed" bar keeps its
/// own six seconds and its own way back.
class _BurstBar {
  _BurstBar(
    ScaffoldMessengerState messenger, {
    required String text,
    required VoidCallback onUndo,
    required VoidCallback onClosed,
  }) : _messenger = messenger,
       words = text,
       _text = ValueNotifier(text) {
    _controller = messenger.showSnackBar(
      SnackBar(
        content: ValueListenableBuilder<String>(
          valueListenable: _text,
          builder: (_, text, _) => Text(text),
        ),
        behavior: SnackBarBehavior.floating,
        // Closed by [_countdown] rather than the messenger's own timeout,
        // so a later release can start the six seconds again.
        persist: true,
        onVisible: _onVisible,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // The tap closes the bar. A bar that is timing out still honours
            // the tap; one dismissed before it appeared, or already undone,
            // does nothing.
            if (closed || _dismissed || _undone) return;
            _undone = true;
            _closing = true;
            onUndo();
          },
        ),
      ),
    );
    _controller.closed.then((_) {
      closed = true;
      _timer?.cancel();
      onClosed();
    });
  }

  static const Duration _lifetime = Duration(seconds: 6);

  /// What was there before the burst, for whichever sliders it has used.
  List<LadderStep>? stepsBefore;
  bool restTouched = false;
  Duration? restBefore;

  final ScaffoldMessengerState _messenger;
  final ValueNotifier<String> _text;
  late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _controller;
  Timer? _timer;
  bool _visible = false;
  bool _dismissed = false;
  bool _closing = false;
  bool _undone = false;

  /// The words for the burst's own changes, kept apart from any note.
  String words;

  /// True once the bar is gone, whatever closed it.
  bool closed = false;

  /// Whether another release can still join this burst: not once the bar
  /// is gone, on its way out, or dismissed before it appeared.
  bool get open => !closed && !_closing && !_dismissed;

  /// Another release in the same burst: new words, six more seconds. A
  /// [note] is added after them, so the words still say what Undo does.
  void touch(String text, {String? note}) {
    words = text;
    _text.value = note == null ? text : '$text ($note)';
    if (_visible) _countdown();
  }

  /// Make way for a bar that matters more: close now, or as soon as this one
  /// would have appeared.
  void dismiss() {
    _dismissed = true;
    if (_visible) _close();
  }

  void _onVisible() {
    // Once only: the messenger shows the bar on every root Scaffold it
    // serves (this screen's and the one beneath it), and each calls this.
    if (_visible) return;
    _visible = true;
    if (_dismissed) {
      // Dismissed while it waited its turn: it leaves at once, with no exit
      // animation to tap an Undo on. The removal happens exactly once, or
      // the bar behind it would go with it.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!closed && _messenger.mounted) {
          closed = true;
          _messenger.removeCurrentSnackBar();
        }
      });
      return;
    }
    _countdown();
  }

  void _countdown() {
    _timer?.cancel();
    _timer = Timer(_lifetime, _close);
  }

  /// Only a bar that is still up, on a messenger that is still there.
  void _close() {
    if (closed || !_messenger.mounted) return;
    _closing = true;
    _controller.close();
  }
}
