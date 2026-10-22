import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
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
      builder: (ctx) => _NewTaskDialog(
        approach: settings.approach,
        settingsRest: settings.rest,
        restFirst: settings.restFirst,
      ),
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

/// Asks for a title and shows, as it is typed, the ladder the task will
/// get: how many steps, how long each is, and the rest that goes with each.
class _NewTaskDialog extends StatefulWidget {
  const _NewTaskDialog({required this.approach, required this.settingsRest, required this.restFirst});

  /// The usual approach, used by any step without a time of its own.
  final Duration approach;

  /// The rest from Settings; the new task's steps climb from it, kept
  /// within the range a unit can have.
  final Duration settingsRest;

  Duration get restUnit => LadderRests.clampUnit(settingsRest);

  /// Whether each step's rest comes before it or after it.
  final bool restFirst;

  @override
  State<_NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<_NewTaskDialog> {
  final _controller = TextEditingController();
  String _title = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    final matched = StarterLadders.match(_title);
    final ladder = matched ?? StarterLadders.generic(_title);
    String? name;
    for (final entry in StarterLadders.byTitle.entries) {
      if (identical(entry.value, matched)) name = entry.key;
    }
    final steps = [for (final s in ladder) s.suggestedDuration ?? widget.approach];
    final rests = LadderRests.restsFor(widget.restUnit, ladder.length);
    final when = widget.restFirst ? 'before' : 'after';
    final kept = widget.restUnit == widget.settingsRest
        ? ''
        : ' (the Settings rest, kept to ${formatWords(widget.restUnit)})';
    return AlertDialog(
      title: const Text('New task'),
      // The preview has to fit above the keyboard on a small phone.
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Laundry, shower, reply to Sam'),
            onChanged: (v) => setState(() => _title = v),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
          const SizedBox(height: 12),
          Text(
            name == null
                ? 'It gets a ladder of ${ladder.length} steps, from thinking about it for a minute up to '
                      'the whole thing.'
                : 'It gets the "$name" ladder: ${ladder.length} steps, from about a minute up to the whole thing.',
            style: small,
          ),
          const SizedBox(height: 6),
          Text('Steps: ${formatSeries(steps)}', style: small),
          const SizedBox(height: 6),
          Text('Rest $when each step$kept: ${formatSeries(rests)}', style: small),
          const SizedBox(height: 6),
          Text('Every step and the rest unit can be changed on the next screen.', style: small),
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
