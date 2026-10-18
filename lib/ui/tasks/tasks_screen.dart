import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/ladder/starter_ladders.dart';
import '../../services/providers.dart';
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
                'Each task has a ladder from near-zero effort to the whole thing. Tap a task to see its rungs.',
                style: theme.textTheme.bodySmall,
              ),
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
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => const _NewTaskDialog(),
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
        subtitle: count == null ? null : Text('$count rungs'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
        ),
      ),
    );
  }
}

class _NewTaskDialog extends StatefulWidget {
  const _NewTaskDialog();

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
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'e.g. Laundry, shower, reply to Sam'),
        onSubmitted: (v) => Navigator.pop(context, v),
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
