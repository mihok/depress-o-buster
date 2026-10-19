import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/xp/levels.dart';
import '../../domain/xp/xp_rules.dart';
import '../../services/providers.dart';
import 'ripple_celebration.dart';

/// One calm line about the last logged interval: "+36 XP · First one today".
///
/// A first-ever interval, a new personal rung, or a level up also gets one
/// slow ripple behind the line. That is the whole celebration.
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
    final worthARipple = logged.isFirstEver ||
        logged.leveledUp ||
        logged.award.bonuses.contains(XpBonus.newPersonalRung);
    return RippleCelebration(
      trigger: worthARipple ? logged.session.id : null,
      child: Padding(
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
                  'Level ${logged.levelAfter}: ${Levels.nameFor(logged.levelAfter)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
