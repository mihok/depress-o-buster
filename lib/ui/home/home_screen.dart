import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/timer/timer_engine.dart';
import '../../services/providers.dart';
import '../timer/timer_view.dart';
import 'start_view.dart';

/// The Start tab: a one-tap start when idle, the running timer otherwise.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(timerControllerProvider.select((s) => s.status));
    return status == TimerStatus.idle ? const StartView() : const TimerView();
  }
}
