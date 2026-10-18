import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/xp/levels.dart';
import '../../services/providers.dart';
import '../history/history_screen.dart';

class ProgressStats {
  const ProgressStats({
    required this.perDay,
    required this.longestApproach,
    required this.rungs,
    required this.totalCompleted,
  });

  final List<DayCount> perDay;
  final Duration longestApproach;
  final Map<String, RungProgress> rungs;
  final int totalCompleted;
}

final progressStatsProvider = FutureProvider.autoDispose<ProgressStats>((ref) async {
  ref.watch(recentSessionsProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  return ProgressStats(
    perDay: await repo.approachesPerDay(days: 14),
    longestApproach: await repo.longestApproach(),
    rungs: await repo.rungProgressByTask(),
    totalCompleted: await repo.totalCompleted(),
  );
});

/// Sessions per day, longest approach, rung progression. No leaderboards.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider).value ?? const ProgressSnapshot();
    final level = Levels.progressFor(progress.totalXp);
    final stats = ref.watch(progressStatsProvider).value;
    final recent = ref.watch(recentSessionsProvider).value ?? const <Session>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level ${level.level}', style: theme.textTheme.bodySmall),
                  Text(level.name, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: level.fraction,
                      minHeight: 8,
                      color: AppColors.approach,
                      backgroundColor: AppColors.approach.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.nextName == null
                        ? '${progress.totalXp} XP'
                        : '${progress.totalXp} XP · ${level.xpToNext} to ${level.nextName}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text('Consistency ×${progress.consistency.toStringAsFixed(2)}'),
              subtitle: const Text(
                'Grows a little with each day you do anything. Fades gently on quiet days. Never resets.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Longest approach',
                  value: stats == null ? '' : formatWords(stats.longestApproach),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  label: 'Intervals completed',
                  value: stats == null ? '' : '${stats.totalCompleted}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Approaches per day, last two weeks', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (stats != null) _PerDayBars(days: stats.perDay),
          const SizedBox(height: 20),
          if (stats != null && stats.rungs.isNotEmpty) ...[
            Text('Ladders', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final r in stats.rungs.values)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(r.taskTitle),
                  subtitle: Text('Highest rung so far: ${r.bestRung + 1}. ${r.bestRungText}'),
                  trailing: Text('${r.attempts}×', style: theme.textTheme.bodySmall),
                ),
              ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: theme.textTheme.titleSmall),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
                ),
                child: const Text('All history'),
              ),
            ],
          ),
          if (recent.isEmpty)
            Text('Nothing logged yet. The first one counts double.', style: theme.textTheme.bodySmall),
          for (final s in recent.take(8)) SessionTile(session: s),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _PerDayBars extends StatelessWidget {
  const _PerDayBars({required this.days});

  final List<DayCount> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var max = 1;
    for (final d in days) {
      if (d.count > max) max = d.count;
    }
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (d.count > 0)
                      Text('${d.count}', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 2),
                    Container(
                      height: d.count == 0 ? 3 : 10 + 60 * d.count / max,
                      decoration: BoxDecoration(
                        color: d.count == 0
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                            : AppColors.approach,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One logged interval, described neutrally.
class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = session;
    final what = s.isApproach
        ? (s.rungText ?? s.taskTitle ?? 'Approach')
        : s.phase.label;
    final mood = [
      if (s.moodBefore != null && s.moodBefore!.isNotEmpty) s.moodBefore,
      if (s.moodAfter != null && s.moodAfter!.isNotEmpty) s.moodAfter,
    ].join(' → ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        s.isApproach ? Icons.arrow_outward : Icons.bedtime_outlined,
        color: s.isApproach ? AppColors.approach : AppColors.rest,
      ),
      title: Text(what),
      subtitle: Text(
        '${formatTime(s.endedAt)} · ${formatWords(s.actual)} of ${formatWords(s.planned)} · ${s.outcome.label}'
        '${mood.isEmpty ? '' : ' · $mood'}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text('+${s.xpEarned}', style: theme.textTheme.bodyMedium),
    );
  }
}
