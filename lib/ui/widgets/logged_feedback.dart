import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/xp/xp_rules.dart';
import '../../services/providers.dart';

/// One calm line about the last logged interval: "+36 XP · First one today".
class LoggedFeedback extends ConsumerWidget {
  const LoggedFeedback({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logged = ref.watch(lastLoggedProvider);
    if (logged == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final bonuses = logged.award.bonuses
        .where((b) => b != XpBonus.firstEver && b != XpBonus.welcomeBack)
        .map((b) => b.label);
    final parts = <String>[
      '+${logged.award.total} XP',
      if (logged.isFirstEver) 'Your first one',
      if (logged.isWelcomeBack) 'Good to see you',
      ...bonuses,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Text(
            parts.join(' · '),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (logged.leveledUp)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Level ${logged.levelAfter}: ${_nameFor(logged.levelAfter)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _nameFor(int level) => _LevelName.of(level);
}

class _LevelName {
  static String of(int level) {
    // Kept local to avoid importing the whole domain into a widget.
    const names = [
      'Resting', 'Stirring', 'Noticing', 'Sitting up', 'Feet on the floor',
      'Standing', 'Doorway', 'Across the room', 'Curtains open', 'Daylight',
      'Kettle on', 'Outside air', 'Around the block', 'Steady', 'Quiet momentum',
      'Rooted', 'Weathering', 'Tending', 'Settled', 'Here',
    ];
    if (level >= 1 && level <= names.length) return names[level - 1];
    return 'Here, still';
  }
}
