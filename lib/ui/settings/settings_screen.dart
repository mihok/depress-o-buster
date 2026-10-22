import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/entities/entities.dart';
import '../../domain/ladder/ladder_rests.dart';
import '../../services/providers.dart';
import '../../services/settings/settings_service.dart';
import '../widgets/duration_picker_tile.dart';
import '../widgets/illustration.dart';

/// What the Settings rest is for: a plain round's rest, and the unit the
/// steps of a task climb from, kept within the range a unit can have.
String _restHint(Duration rest) {
  final unit = LadderRests.clampUnit(rest);
  final range = 'a unit stays within ${formatWords(LadderRests.minUnit)} to ${formatWords(LadderRests.maxUnit)}';
  return unit == rest
      ? 'For a plain round, the rest each time. For the steps of a task, the rest unit ($range): '
            'each step rests 1, 1, 2, 3, 5, 8 or 13 times this, unless the task has a unit of its own.'
      : 'For a plain round, the rest each time. For the steps of a task, the rest unit is '
            '${formatWords(unit)} ($range): each step rests 1, 1, 2, 3, 5, 8 or 13 times that, unless the '
            'task has a unit of its own.';
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final presets = ref.watch(presetsProvider).value ?? const <Preset>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _Section('Ratio'),
          DurationPickerTile(
            title: 'Approach',
            value: settings.approach,
            onChanged: (d) => notifier.update((s) => s.copyWith(approach: d, clearLastPresetId: true)),
          ),
          DurationPickerTile(
            title: 'Rest',
            value: settings.rest,
            hint: _restHint(settings.rest),
            onChanged: (d) => notifier.update((s) => s.copyWith(rest: d, clearLastPresetId: true)),
          ),
          SwitchListTile(
            title: const Text('Long rest after a few rounds'),
            value: settings.longRest != null && settings.cyclesBeforeLongRest > 0,
            onChanged: (on) => notifier.update(
              (s) => on
                  ? s.copyWith(longRest: s.longRest ?? const Duration(minutes: 20), cyclesBeforeLongRest: s.cyclesBeforeLongRest > 0 ? s.cyclesBeforeLongRest : 4)
                  : s.copyWith(cyclesBeforeLongRest: 0),
            ),
          ),
          if (settings.longRest != null && settings.cyclesBeforeLongRest > 0) ...[
            DurationPickerTile(
              title: 'Long rest',
              value: settings.longRest!,
              onChanged: (d) => notifier.update((s) => s.copyWith(longRest: d)),
            ),
            ListTile(
              title: const Text('Rounds before a long rest'),
              subtitle: Text('${settings.cyclesBeforeLongRest}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: settings.cyclesBeforeLongRest <= 1
                        ? null
                        : () => notifier.update((s) => s.copyWith(cyclesBeforeLongRest: s.cyclesBeforeLongRest - 1)),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () => notifier.update((s) => s.copyWith(cyclesBeforeLongRest: s.cyclesBeforeLongRest + 1)),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
          DurationPickerTile(
            title: 'Snooze adds',
            value: settings.snoozeBy,
            onChanged: (d) => notifier.update((s) => s.copyWith(snoozeBy: d)),
          ),
          SwitchListTile(
            title: const Text('Rest before the step'),
            subtitle: const Text(
              'Each round opens with the rest, so there is time to get ready. '
              'The chime says when it is time for the step.',
            ),
            value: settings.restFirst,
            onChanged: (v) => notifier.update((s) => s.copyWith(restFirst: v)),
          ),
          SwitchListTile(
            title: Text(settings.restFirst ? 'Start the step automatically' : 'Start rest automatically'),
            subtitle: Text(
              settings.restFirst
                  ? 'When the rest ends, the step begins on its own.'
                  : 'When the approach ends, rest begins on its own.',
            ),
            value: settings.autoStartNext,
            onChanged: (v) => notifier.update((s) => s.copyWith(autoStartNext: v)),
          ),
          _Section('Presets'),
          for (final p in presets)
            ListTile(
              title: Text(p.name),
              subtitle: Text(
                'Approach ${formatWords(p.approach)} · Rest ${formatWords(p.rest)}'
                '${p.longRest != null && p.cyclesBeforeLongRest > 0 ? ' · Long rest ${formatWords(p.longRest!)} every ${p.cyclesBeforeLongRest}' : ''}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  final repo = ref.read(presetRepositoryProvider);
                  switch (v) {
                    case 'use':
                      await notifier.applyPreset(p);
                    case 'edit':
                      final edited = await _presetDialog(context, initial: p);
                      if (edited != null) await repo.upsert(edited);
                    case 'delete':
                      await repo.delete(p.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'use', child: Text('Use this ratio')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () => notifier.applyPreset(p),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final created = await _presetDialog(
                  context,
                  initial: Preset(
                    id: '',
                    name: '',
                    approach: settings.approach,
                    rest: settings.rest,
                    longRest: settings.longRest,
                    cyclesBeforeLongRest: settings.cyclesBeforeLongRest,
                  ),
                );
                if (created != null) {
                  await ref.read(presetRepositoryProvider).create(
                    name: created.name,
                    approach: created.approach,
                    rest: created.rest,
                    longRest: created.longRest,
                    cyclesBeforeLongRest: created.cyclesBeforeLongRest,
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Save current ratio as a preset'),
            ),
          ),
          _Section('Sound and feel'),
          SwitchListTile(
            title: const Text('Chimes'),
            value: settings.soundEnabled,
            onChanged: (v) => notifier.update((s) => s.copyWith(soundEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: (v) => notifier.update((s) => s.copyWith(vibrationEnabled: v)),
          ),
          SwitchListTile(
            title: const Text('Keep the screen on during a timer'),
            value: settings.keepScreenOn,
            onChanged: (v) => notifier.update((s) => s.copyWith(keepScreenOn: v)),
          ),
          SwitchListTile(
            title: const Text('Ask for a one-word mood'),
            subtitle: const Text('Before and after a session. Always optional.'),
            value: settings.askMood,
            onChanged: (v) => notifier.update((s) => s.copyWith(askMood: v)),
          ),
          ListTile(
            title: const Text('Appearance'),
            trailing: SegmentedButton<AppThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                ButtonSegment(value: AppThemeMode.system, label: Text('Auto')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (sel) => notifier.update((s) => s.copyWith(themeMode: sel.first)),
            ),
          ),
          // Claude-assisted breakdown is optional and rarely revisited, so it
          // rolls out from one tile instead of taking a section of its own.
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text('Advanced'),
            subtitle: Text(
              'Claude-assisted breakdown: model and API key',
              // ExpansionTile paints its whole header in one text colour, which
              // would brighten this line. Keep it as muted as every other subtitle.
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            // No divider lines and no tint: the tile reads like the rest of the
            // screen, and its padding comes from the same ListTileTheme.
            shape: const Border(),
            collapsedShape: const Border(),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ApiKeyTile(),
              ListTile(
                title: const Text('Model'),
                subtitle: Text(settings.breakdownModel),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  final controller = TextEditingController(text: settings.breakdownModel);
                  final value = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Model id'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'claude-opus-5-5'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
                      ],
                    ),
                  );
                  controller.dispose();
                  if (value != null && value.trim().isNotEmpty) {
                    await notifier.update((s) => s.copyWith(breakdownModel: value.trim()));
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Use Claude when a key is set'),
                subtitle: const Text('Off: always use the built-in ladders.'),
                value: settings.preferClaude,
                onChanged: (v) => notifier.update((s) => s.copyWith(preferClaude: v)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'The key is stored in the device keychain and only sent to the API you configure. '
                  'Breakdowns are optional; the timer never waits for them.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          _Section('Alarms'),
          const _AlarmStatus(),
          _Section('Data'),
          ListTile(
            title: const Text('Delete all history and XP'),
            subtitle: const Text('Tasks and presets stay.'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  content: const Text('Delete every logged session and reset XP? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(sessionRepositoryProvider).deleteAll();
                await ref.read(progressRepositoryProvider).reset();
                ref.read(lastLoggedProvider.notifier).clear();
                ref.read(lastApproachLoggedProvider.notifier).clear();
              }
            },
          ),
          _Section('About'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: const AppIllustration(Illustration.mark, height: 56),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Depress-o-buster', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'A timer with a very low floor. It is not a medical device and does not treat anything. '
                        'If things feel unsafe, please reach out to someone you trust or a local crisis line.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ApiKeyTile extends ConsumerStatefulWidget {
  const _ApiKeyTile();

  @override
  ConsumerState<_ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends ConsumerState<_ApiKeyTile> {
  final _controller = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final present = ref.watch(apiKeyPresentProvider).value ?? false;
    final store = ref.read(settingsServiceProvider);
    if (!_editing) {
      return ListTile(
        title: const Text('Claude API key'),
        subtitle: Text(present ? 'Key saved' : 'No key. Built-in ladders are used.'),
        trailing: TextButton(
          onPressed: () => setState(() => _editing = true),
          child: Text(present ? 'Change' : 'Add'),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'API key', hintText: 'sk-ant-...'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final typed = _controller.text.trim();
                    if (typed.isEmpty) {
                      // Nothing typed: keep whatever is stored. Remove is the
                      // only way to delete a key.
                      setState(() => _editing = false);
                      return;
                    }
                    await store.setApiKey(typed);
                    _controller.clear();
                    ref.invalidate(apiKeyPresentProvider);
                    ref.invalidate(breakdownServiceProvider);
                    if (mounted) setState(() => _editing = false);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 8),
              if (present)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await store.setApiKey(null);
                      ref.invalidate(apiKeyPresentProvider);
                      ref.invalidate(breakdownServiceProvider);
                      if (mounted) setState(() => _editing = false);
                    },
                    child: const Text('Remove'),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => _editing = false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlarmStatus extends ConsumerWidget {
  const _AlarmStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmServiceProvider);
    if (!alarms.isSupported) {
      return const ListTile(
        title: Text('Alarms'),
        subtitle: Text('Not available on this platform. The chime plays while the app is open.'),
      );
    }
    final caps = ref.watch(alarmCapabilitiesProvider).value ?? alarms.capabilities;
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return Column(
      children: [
        ListTile(
          title: const Text('Notifications'),
          subtitle: Text(caps.notificationsGranted ? 'Allowed' : 'Off. Alarms will not sound in the background.'),
          trailing: caps.notificationsGranted
              ? null
              : TextButton(
                  onPressed: () async {
                    await alarms.ensurePermissions();
                    ref.invalidate(alarmCapabilitiesProvider);
                  },
                  child: const Text('Allow'),
                ),
        ),
        if (isAndroid)
          ListTile(
            title: const Text('Exact alarms'),
            subtitle: Text(caps.exactAlarmsAllowed ? 'Allowed' : 'Off. Alarms may be late.'),
            trailing: caps.exactAlarmsAllowed
                ? null
                : TextButton(
                    onPressed: () async {
                      await alarms.openExactAlarmSettings();
                      ref.invalidate(alarmCapabilitiesProvider);
                    },
                    child: const Text('Allow'),
                  ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'Battery savers can delay alarms. If chimes arrive late, exempt this app from battery optimisation in the system settings.',
          ),
        ),
      ],
    );
  }
}

Future<Preset?> _presetDialog(BuildContext context, {required Preset initial}) async {
  final name = TextEditingController(text: initial.name);
  var approach = initial.approach;
  var rest = initial.rest;
  var longRest = initial.longRest;
  var cycles = initial.cyclesBeforeLongRest;
  final result = await showDialog<Preset>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(initial.id.isEmpty ? 'New preset' : 'Edit preset'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: initial.name.isEmpty,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Approach'),
                subtitle: Text(formatWords(approach)),
                onTap: () async {
                  final d = await showDurationDialog(ctx, title: 'Approach', initial: approach);
                  if (d != null) setState(() => approach = d);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rest'),
                subtitle: Text(formatWords(rest)),
                onTap: () async {
                  final d = await showDurationDialog(ctx, title: 'Rest', initial: rest);
                  if (d != null) setState(() => rest = d);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Long rest (optional)'),
                subtitle: Text(longRest == null || cycles <= 0 ? 'None' : '${formatWords(longRest!)} every $cycles rounds'),
                onTap: () async {
                  final d = await showDurationDialog(ctx, title: 'Long rest', initial: longRest ?? const Duration(minutes: 20));
                  if (d != null) {
                    setState(() {
                      longRest = d;
                      if (cycles <= 0) cycles = 4;
                    });
                  }
                },
                trailing: longRest == null
                    ? null
                    : IconButton(
                        onPressed: () => setState(() {
                          longRest = null;
                          cycles = 0;
                        }),
                        icon: const Icon(Icons.clear),
                      ),
              ),
              if (longRest != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Every $cycles rounds'),
                    IconButton(
                      onPressed: cycles <= 1 ? null : () => setState(() => cycles--),
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton(
                      onPressed: () => setState(() => cycles++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = name.text.trim();
              if (n.isEmpty) return;
              Navigator.pop(
                ctx,
                initial.copyWith(
                  name: n,
                  approach: approach,
                  rest: rest,
                  longRest: longRest,
                  clearLongRest: longRest == null,
                  cyclesBeforeLongRest: longRest == null ? 0 : cycles,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  name.dispose();
  return result;
}
