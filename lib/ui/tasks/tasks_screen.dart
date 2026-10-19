import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_rests.dart';
import '../../domain/ladder/starter_ladders.dart';
import '../../services/providers.dart';
import '../widgets/illustration.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasksAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Could not load tasks: $e')),
        data: (tasks) => ListView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Text(
                'Each task has a ladder of steps from near-zero effort to the whole thing. Tap a task to see its steps.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (tasks.isEmpty)
              const EmptyState(
                illustration: Illustration.stonesEmpty,
                title: 'No tasks yet.',
                body: 'Add one thing. Its ladder will start at almost nothing.',
              ),
            for (final task in tasks) _TaskTile(task: task),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newTask(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
    );
  }

  Future<void> _newTask(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => _NewTaskDialog(restUnit: settings.rest),
    );
    if (title == null || title.trim().isEmpty || !context.mounted) return;
    final ladder = StarterLadders.match(title) ?? StarterLadders.generic(title);
    final task = await ref.read(taskRepositoryProvider).createTask(title, ladder: ladder);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(ladderProvider(task.id)).value?.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(task.title),
        subtitle: count == null ? null : Text('$count steps'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
        ),
      ),
    );
  }
}

class _NewTaskDialog extends StatefulWidget {
  const _NewTaskDialog({required this.restUnit});

  /// The rest unit the new task's steps will climb from (the Settings rest).
  final Duration restUnit;

  @override
  State<_NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<_NewTaskDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Laundry, shower, reply to Sam'),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          const SizedBox(height: 12),
          Text(
            'It gets a ladder of short steps. Each step has a rest before it, growing with its '
            'place in the ladder: ${LadderRests.describe(widget.restUnit)} You can change the rest '
            'unit and every step afterwards.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
