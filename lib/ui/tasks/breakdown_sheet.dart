import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../services/breakdown/task_breakdown_service.dart';
import '../../services/providers.dart';

/// "Break this down smaller." Optional, async, never in the timer's way.
Future<void> showBreakdownSheet(
  BuildContext context, {
  required Task task,
  required List<LadderStep> ladder,
  LadderStep? rung,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BreakdownSheet(task: task, ladder: ladder, rung: rung),
  );
}

class _BreakdownSheet extends ConsumerStatefulWidget {
  const _BreakdownSheet({required this.task, required this.ladder, this.rung});

  final Task task;
  final List<LadderStep> ladder;
  final LadderStep? rung;

  @override
  ConsumerState<_BreakdownSheet> createState() => _BreakdownSheetState();
}

class _BreakdownSheetState extends ConsumerState<_BreakdownSheet> {
  final _feeling = TextEditingController();
  bool _loading = false;
  String? _error;
  BreakdownResult? _result;
  final Set<int> _selected = {};

  @override
  void dispose() {
    _feeling.dispose();
    super.dispose();
  }

  Future<void> _run({bool forceOffline = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _selected.clear();
    });
    final service = forceOffline
        ? ref.read(mockBreakdownProvider)
        : await ref.read(breakdownServiceProvider.future);
    final rung = widget.rung;
    try {
      final result = await service.breakDown(
        BreakdownRequest(
          taskTitle: widget.task.title,
          taskNote: widget.task.note,
          currentLadder: widget.ladder.map((s) => s.text).toList(),
          currentRung: rung?.text,
          currentRungMinutes: rung?.suggestedDuration?.inMinutes,
          goSmaller: rung != null,
          feelingNote: _feeling.text.trim().isEmpty ? null : _feeling.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _selected.addAll(List.generate(result.steps.length, (i) => i));
      });
    } on BreakdownException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply({required bool replace}) async {
    final result = _result;
    if (result == null) return;
    final repo = ref.read(taskRepositoryProvider);
    final rung = widget.rung;
    final chosen = [
      for (var i = 0; i < result.steps.length; i++)
        if (_selected.contains(i)) result.steps[i],
    ];
    if (chosen.isEmpty) return;
    if (replace) {
      await repo.replaceLadder(
        widget.task.id,
        [
          for (var i = 0; i < chosen.length; i++)
            LadderStep(
              id: 'tmp-$i',
              taskId: widget.task.id,
              position: i,
              text: chosen[i].text,
              suggestedDuration: chosen[i].suggestedDuration,
            ),
        ],
      );
    } else {
      // Smaller steps go just before the rung they shrink; otherwise append.
      final skipRungDuplicate = rung?.text.trim().toLowerCase();
      var at = rung?.position ?? widget.ladder.length;
      for (final step in chosen) {
        if (skipRungDuplicate != null && step.text.trim().toLowerCase() == skipRungDuplicate) {
          continue;
        }
        await repo.addStep(
          widget.task.id,
          step.text,
          suggestedDuration: step.suggestedDuration,
          at: at,
        );
        at++;
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rung = widget.rung;
    final serviceName = ref.watch(breakdownServiceProvider).value?.name;
    final result = _result;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('Break this down smaller', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              rung == null ? widget.task.title : 'Smaller than: "${rung.text}"',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feeling,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'How are you feeling right now? (optional)',
                hintText: 'one line is plenty',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : () => _run(),
              child: Text(result == null ? 'Break it down' : 'Try again'),
            ),
            const SizedBox(height: 6),
            Text(
              serviceName == null ? '' : 'Using: $serviceName',
              style: theme.textTheme.bodySmall,
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : () => _run(forceOffline: true),
                child: const Text('Use the built-in ladder instead'),
              ),
            ],
            if (result != null) ...[
              const SizedBox(height: 16),
              if (result.note != null) ...[
                Text(result.note!, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
              ],
              for (var i = 0; i < result.steps.length; i++)
                CheckboxListTile(
                  value: _selected.contains(i),
                  onChanged: (on) => setState(() {
                    if (on ?? false) {
                      _selected.add(i);
                    } else {
                      _selected.remove(i);
                    }
                  }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(result.steps[i].text),
                  subtitle: result.steps[i].suggestedDuration == null
                      ? null
                      : Text(formatWords(result.steps[i].suggestedDuration!)),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _selected.isEmpty ? null : () => _apply(replace: false),
                child: Text(
                  rung == null
                      ? 'Add ${_selected.length} steps to the ladder'
                      : 'Insert ${_selected.length} steps before this rung',
                ),
              ),
              if (rung == null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _selected.isEmpty ? null : () => _apply(replace: true),
                  child: const Text('Replace the whole ladder'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
