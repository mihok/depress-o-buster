import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/home_screen.dart';
import 'progress/progress_screen.dart';
import 'settings/settings_screen.dart';
import 'tasks/tasks_screen.dart';

class RootTabController extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final rootTabProvider = NotifierProvider<RootTabController, int>(RootTabController.new);

/// Four calm tabs. The Start tab becomes the running timer.
class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(rootTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [HomeScreen(), TasksScreen(), ProgressScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(rootTabProvider.notifier).set(i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.play_arrow_outlined), selectedIcon: Icon(Icons.play_arrow), label: 'Start'),
          NavigationDestination(icon: Icon(Icons.stairs_outlined), selectedIcon: Icon(Icons.stairs), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}
