import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../services/providers.dart';
import '../root_shell.dart';
import 'breakdown_sheet.dart';

/// The ladder editor. Any rung can be started, edited, moved or removed.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
    Task? task;
    for (final t in tasks) {
      if (t.id == taskId) task = t;
    }
    final ladder = ref.watch(ladderProvider(taskId)).value ?? const <LadderStep>[];
    final repo = ref.read(taskRepositoryProvider);

    if (task == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('This task is gone.')));
    }
    final t = task;

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
            child: ladder.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No rungs yet. Add one, or break the task down.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    buildDefaultDragHandles: false,
                    itemCount: ladder.length,
                    onReorderItem: (oldIndex, newIndex) => repo.reorderSteps(t.id, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final step = ladder[index];
                      return Card(
                        key: ValueKey(step.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            child: Text('${step.position + 1}', style: theme.textTheme.labelMedium),
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
                      final text = await _textDialog(context, title: 'New rung');
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
                      final edited = await _editStepDialog(context, step);
                      if (edited != null) await repo.updateStep(edited);
                    },
                    child: const Text('Edit'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await repo.deleteStep(task.id, step.id);
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

Future<String?> _textDialog(BuildContext context, {required String title, String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<LadderStep?> _editStepDialog(BuildContext context, LadderStep step) {
  final text = TextEditingController(text: step.text);
  final minutes = TextEditingController(
    text: step.suggestedDuration == null ? '' : '${step.suggestedDuration!.inMinutes}',
  );
  return showDialog<LadderStep>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit rung'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: text,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Step'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Suggested minutes (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final m = int.tryParse(minutes.text.trim());
            Navigator.pop(
              ctx,
              step.copyWith(
                text: text.text.trim().isEmpty ? step.text : text.text.trim(),
                suggestedDuration: m == null || m <= 0 ? null : Duration(minutes: m),
                clearSuggestedDuration: m == null || m <= 0,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).whenComplete(() {
    text.dispose();
    minutes.dispose();
  });
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
