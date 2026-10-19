import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
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
  /// while the rest slider is held.
  double _restFactor = 1;

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
    final shownUnit = _restFactor == 1 ? unit : LadderRests.scaleUnit(unit, _restFactor);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Text(
              'Each step has its own rest before it. The rest grows with the step\'s place in '
              'the ladder (×1, ×1, ×2, ×3, ×5, ×8, ×13 of the rest unit), whatever the step\'s '
              'length, and moves with the step.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          // The two stretch sliders fold away so the ladder stays in view;
          // the tiles preview live while either is held.
          Card(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: ExpansionTile(
              title: const Text('Adjust step length and rest unit'),
              subtitle: Text('Rest unit ${formatWords(shownUnit)} · rests ${LadderRests.describe(shownUnit)}'),
              shape: const Border(),
              collapsedShape: const Border(),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
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
                  onChanged: (f) => setState(() => _restFactor = f),
                  onChangeEnd: (f) => _applyRestUnit(t, unit, f),
                ),
              ],
            ),
          ),
          Expanded(
            child: ladder.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No steps yet. Add one, or break the task down.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    buildDefaultDragHandles: false,
                    itemCount: shown.length,
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
                                ' · ${step.suggestedDuration == null ? 'usual ${formatWords(settings.approach)}' : formatWords(step.suggestedDuration!)}',
                              ),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const SizedBox(
                                  width: 48,
                                  height: 48,
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
          SafeArea(
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
        ],
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
    final before = await repo.ladder(task.id);
    final changed = await repo.scaleStepDurations(task.id, factor);
    if (!mounted) return;
    if (changed == 0) {
      setState(() => _previewFactor = 1);
      return;
    }
    // Hand-set times are precious: the previous ones can be put back.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(changed == 1 ? 'One step time changed' : '$changed step times changed'),
        behavior: SnackBarBehavior.floating,
        persist: false,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              await repo.restoreStepDurations(task.id, before);
            } catch (e) {
              debugPrint('restoreStepDurations failed: $e');
            }
          },
        ),
      ),
    );
  }

  /// The rest slider was let go: save the new unit for this task, with a
  /// way back. The slider returns to ×1 once the task stream echoes.
  Future<void> _applyRestUnit(Task task, Duration unit, double factor) async {
    if (factor == 1) return;
    final repo = ref.read(taskRepositoryProvider);
    final next = LadderRests.scaleUnit(unit, factor);
    await repo.setRestUnit(task.id, next);
    if (!mounted) return;
    setState(() => _restFactor = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rest unit is now ${formatWords(next)}'),
        behavior: SnackBarBehavior.floating,
        persist: false,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              await repo.setRestUnit(task.id, task.restUnit);
            } catch (e) {
              debugPrint('setRestUnit failed: $e');
            }
          },
        ),
      ),
    );
  }

  /// Remove a step with a quiet way back. Undo restores the very same step
  /// (same id and position), so its history still counts.
  Future<void> _removeStep(Task task, LadderStep step) async {
    final repo = ref.read(taskRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _removedIds.add(step.id));
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
    final duration = step.suggestedDuration ?? settings.approach;
    final rest = LadderRests.restFor(unit: LadderRests.unitFor(task, settings.rest), position: step.position);
    final repo = ref.read(taskRepositoryProvider);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => Padding(
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
                  config: settings.timerConfig.copyWith(approach: duration, rest: rest),
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
                    ? 'Rest ${formatWords(rest)}, then ${formatWords(duration)} here'
                    : '${formatWords(duration)} here, then rest ${formatWords(rest)}',
              ),
            ),
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
                      final edited = await _editStepDialog(context, step, usual: settings.approach, rest: rest);
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
}) {
  return showDialog<LadderStep>(
    context: context,
    builder: (_) => _EditStepDialog(step: step, usual: usual, rest: rest),
  );
}

class _EditStepDialog extends StatefulWidget {
  const _EditStepDialog({required this.step, required this.usual, required this.rest});

  final LadderStep step;
  final Duration usual;

  /// The rest before this step, from its place in the ladder.
  final Duration rest;

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
          Text(
            'Rest before this step: ${formatWords(widget.rest)}, from its place in the ladder '
            '(step ${widget.step.position + 1}). Move the step to change it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
