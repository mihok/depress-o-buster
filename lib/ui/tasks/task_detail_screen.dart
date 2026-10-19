import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ladder/step_scaling.dart';
import '../../services/providers.dart';
import '../root_shell.dart';
import '../widgets/duration_picker_tile.dart';
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
          if (hasTimes)
            _StepLengthCard(
              factor: _previewFactor,
              onChangeStart: () => _draggingSlider = true,
              onChanged: (f) => setState(() => _previewFactor = f),
              onChangeEnd: (f) => _applyStepLength(t, f),
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
                              subtitle: step.suggestedDuration == null
                                  ? null
                                  : Text(formatWords(step.suggestedDuration!)),
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
    final changed = await ref.read(taskRepositoryProvider).scaleStepDurations(task.id, factor);
    if (changed == 0 && mounted) setState(() => _previewFactor = 1);
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
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await repo.restoreStep(task.id, step);
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
                  config: settings.timerConfig.copyWith(approach: duration),
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
              child: Text('Start a ${formatWords(duration)} approach here'),
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
                      final edited = await _editStepDialog(context, step, usual: settings.approach);
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

/// A compact slider that stretches or shrinks the time on every step at
/// once. It is relative: after each release it returns to ×1.
class _StepLengthCard extends StatelessWidget {
  const _StepLengthCard({
    required this.factor,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double factor;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stops = StepScaling.factors;
    final index = stops.indexOf(factor);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Step length', style: theme.textTheme.titleSmall)),
                Text(StepScaling.label(factor), style: theme.textTheme.labelLarge),
              ],
            ),
            Row(
              children: [
                Text('Shorter', style: theme.textTheme.bodySmall),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: Slider(
                      value: (index < 0 ? stops.indexOf(1) : index).toDouble(),
                      min: 0,
                      max: (stops.length - 1).toDouble(),
                      divisions: stops.length - 1,
                      semanticFormatterCallback: (v) => StepScaling.label(stops[v.round()]),
                      onChangeStart: (_) => onChangeStart(),
                      onChanged: (v) => onChanged(stops[v.round()]),
                      onChangeEnd: (v) => onChangeEnd(stops[v.round()]),
                    ),
                  ),
                ),
                Text('Longer', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
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
Future<LadderStep?> _editStepDialog(BuildContext context, LadderStep step, {required Duration usual}) {
  return showDialog<LadderStep>(
    context: context,
    builder: (_) => _EditStepDialog(step: step, usual: usual),
  );
}

class _EditStepDialog extends StatefulWidget {
  const _EditStepDialog({required this.step, required this.usual});

  final LadderStep step;
  final Duration usual;

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
