import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'services/providers.dart';
import 'services/settings/settings_service.dart';
import 'ui/root_shell.dart';

class DepressOBusterApp extends ConsumerStatefulWidget {
  const DepressOBusterApp({super.key});

  @override
  ConsumerState<DepressOBusterApp> createState() => _DepressOBusterAppState();
}

class _DepressOBusterAppState extends ConsumerState<DepressOBusterApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(timerControllerProvider.notifier).catchUp(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerControllerProvider.notifier).restore();
      ref.read(alarmServiceProvider).tapped.listen((_) {
        ref.read(rootTabProvider.notifier).set(0);
      });
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'Depress-o-buster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.light => ThemeMode.light,
      },
      home: const RootShell(),
    );
  }
}
