import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../services/providers.dart';
import '../progress/progress_screen.dart';

/// Every interval, grouped by day. Quiet days are simply absent.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessions = ref.watch(allSessionsProvider).value ?? const <Session>[];
    final groups = <DateTime, List<Session>>{};
    for (final s in sessions) {
      final day = DateTime(s.endedAt.year, s.endedAt.month, s.endedAt.day);
      groups.putIfAbsent(day, () => []).add(s);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: sessions.isEmpty
          ? Center(
              child: Text('Nothing logged yet.', style: theme.textTheme.bodyMedium),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 4),
                    child: Text(formatDay(entry.key), style: theme.textTheme.titleSmall),
                  ),
                  for (final s in entry.value) SessionTile(session: s),
                ],
              ],
            ),
    );
  }
}
