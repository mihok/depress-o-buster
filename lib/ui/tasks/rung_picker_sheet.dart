import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../services/providers.dart';

class RungChoice {
  const RungChoice(this.task, this.step);
  final Task task;
  final LadderStep step;
}

/// Two taps: a task, then any rung. Rungs are never mandatory in order.
Future<RungChoice?> showRungPicker(BuildContext context) {
  return showModalBottomSheet<RungChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _RungPickerSheet(),
  );
}

class _RungPickerSheet extends ConsumerStatefulWidget {
  const _RungPickerSheet();

  @override
  ConsumerState<_RungPickerSheet> createState() => _RungPickerSheetState();
}

class _RungPickerSheetState extends ConsumerState<_RungPickerSheet> {
  Task? _task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = _task;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        if (task == null) {
          final tasks = ref.watch(tasksProvider).value ?? const <Task>[];
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Which task?', style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tasks yet. Add one on the Tasks tab.'),
                ),
              for (final t in tasks)
                ListTile(
                  title: Text(t.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _task = t),
                ),
            ],
          );
        }
        final ladder = ref.watch(ladderProvider(task.id)).value ?? const <LadderStep>[];
        return ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _task = null),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                ),
                Expanded(child: Text(task.title, style: theme.textTheme.titleLarge)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Any step is a fine place to start.', style: theme.textTheme.bodySmall),
            ),
            const SizedBox(height: 8),
            if (ladder.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('This task has no steps yet.'),
              ),
            for (final step in ladder)
              ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text('${step.position + 1}', style: theme.textTheme.labelMedium),
                ),
                title: Text(step.text),
                subtitle: step.suggestedDuration == null
                    ? null
                    : Text(formatWords(step.suggestedDuration!)),
                onTap: () => Navigator.pop(context, RungChoice(task, step)),
              ),
          ],
        );
      },
    );
  }
}
