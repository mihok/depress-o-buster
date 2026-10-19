import 'package:flutter/material.dart';

import '../../core/format.dart';

/// A tile that opens a small minutes + seconds dialog. No lower bound beyond
/// one second: 30-second approaches are valid.
class DurationPickerTile extends StatelessWidget {
  const DurationPickerTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final Duration value;
  final ValueChanged<Duration> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle ?? formatWords(value)),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final picked = await showDurationDialog(context, title: title, initial: value);
        if (picked != null) onChanged(picked);
      },
    );
  }
}

Future<Duration?> showDurationDialog(
  BuildContext context, {
  required String title,
  required Duration initial,
}) {
  return showDialog<Duration>(
    context: context,
    builder: (_) => _DurationDialog(title: title, initial: initial),
  );
}

/// The controllers live with the dialog's state: the focused field rebuilds
/// once more while the route fades out, so disposing them as soon as the
/// dialog's future completes is too early.
class _DurationDialog extends StatefulWidget {
  const _DurationDialog({required this.title, required this.initial});

  final String title;
  final Duration initial;

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  late final TextEditingController _minutes =
      TextEditingController(text: '${widget.initial.inMinutes}');
  late final TextEditingController _seconds =
      TextEditingController(text: '${widget.initial.inSeconds % 60}');

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minutes,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'min'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _seconds,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'sec'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final m = int.tryParse(_minutes.text.trim()) ?? 0;
            final s = int.tryParse(_seconds.text.trim()) ?? 0;
            final total = Duration(minutes: m.clamp(0, 24 * 60), seconds: s.clamp(0, 59));
            Navigator.pop(context, total.inSeconds < 1 ? const Duration(seconds: 1) : total);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
