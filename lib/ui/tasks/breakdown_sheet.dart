import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_logic.dart';
import '../../services/breakdown/task_breakdown_service.dart';
import '../../services/providers.dart';
import '../widgets/illustration.dart';

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
  bool _applying = false;
  String? _error;
  BreakdownResult? _result;
  final Set<int> _selected = {};

  /// Steps offered for adding: the rung being shrunk is never re-added, and
  /// neither is any step the ladder already has.
  List<MicroStep> get _offered {
    final result = _result;
    if (result == null) return const [];
    var steps = result.steps;
    if (widget.rung != null && steps.length > 1) {
      // Go-smaller results end with the rung itself (by instruction).
      steps = steps.sublist(0, steps.length - 1);
    }
    final existing = {for (final s in widget.ladder) _norm(s.text)};
    if (widget.rung != null) existing.add(_norm(widget.rung!.text));
    return [for (final s in steps) if (!existing.contains(_norm(s.text))) s];
  }

  static String _norm(String text) => text.trim().toLowerCase().replaceAll(RegExp(r'[.\s]+$'), '');

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
        _selected.addAll(List.generate(_offered.length, (i) => i));
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
    if (_applying) return;
    final repo = ref.read(taskRepositoryProvider);
    final rung = widget.rung;
    final offered = _offered;
    final chosen = [
      for (var i = 0; i < offered.length; i++)
        if (_selected.contains(i)) offered[i],
    ];
    if (chosen.isEmpty) return;
    setState(() => _applying = true);
    try {
      if (replace) {
        // A fresh ladder for the whole task; the full result is used so the
        // top rung is kept too.
        final all = _result?.steps ?? chosen;
        await repo.replaceLadder(
          widget.task.id,
          LadderLogic.fromMicroSteps(widget.task.id, all, const Uuid().v4),
        );
      } else {
        // Smaller steps go just before the rung they shrink; otherwise append.
        var at = rung?.position ?? widget.ladder.length;
        for (final step in chosen) {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _applying = false;
        _error = 'Could not save the steps. $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rung = widget.rung;
    final serviceName = ref.watch(breakdownServiceProvider).value?.name;
    final result = _result;
    final offered = _offered;
    final busy = _loading || _applying;
    // A task-level result is a whole ladder; when the task already has rungs
    // the honest primary action is to replace, not to append a second ladder.
    final replaceIsPrimary = rung == null && widget.ladder.isNotEmpty;
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Break this down smaller', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        rung == null ? widget.task.title : 'Smaller than: "${rung.text}"',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const AppIllustration(Illustration.stoneSplit, height: 72),
              ],
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
              onPressed: busy ? null : () => _run(),
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
                onPressed: busy ? null : () => _run(forceOffline: true),
                child: const Text('Use the built-in ladder instead'),
              ),
            ],
            if (result != null) ...[
              const SizedBox(height: 16),
              if (result.note != null) ...[
                Text(result.note!, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
              ],
              if (offered.isEmpty)
                Text(
                  'Every step offered is already on the ladder.',
                  style: theme.textTheme.bodyMedium,
                ),
              for (var i = 0; i < offered.length; i++)
                CheckboxListTile(
                  value: _selected.contains(i),
                  onChanged: busy
                      ? null
                      : (on) => setState(() {
                          if (on ?? false) {
                            _selected.add(i);
                          } else {
                            _selected.remove(i);
                          }
                        }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(offered[i].text),
                  subtitle: offered[i].suggestedDuration == null
                      ? null
                      : Text(formatWords(offered[i].suggestedDuration!)),
                ),
              const SizedBox(height: 12),
              if (replaceIsPrimary) ...[
                FilledButton(
                  onPressed: busy ? null : () => _apply(replace: true),
                  child: Text('Replace the ladder with these ${result.steps.length} steps'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy || _selected.isEmpty ? null : () => _apply(replace: false),
                  child: Text('Append ${_selected.length} new steps instead'),
                ),
              ] else ...[
                FilledButton(
                  onPressed: busy || _selected.isEmpty ? null : () => _apply(replace: false),
                  child: Text(
                    rung == null
                        ? 'Add ${_selected.length} steps to the ladder'
                        : 'Insert ${_selected.length} steps before this rung',
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
