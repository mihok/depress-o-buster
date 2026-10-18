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
  final minutes = TextEditingController(text: '${initial.inMinutes}');
  final seconds = TextEditingController(text: '${initial.inSeconds % 60}');
  return showDialog<Duration>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: minutes,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'min'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: seconds,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'sec'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final m = int.tryParse(minutes.text.trim()) ?? 0;
            final s = int.tryParse(seconds.text.trim()) ?? 0;
            final total = Duration(minutes: m.clamp(0, 24 * 60), seconds: s.clamp(0, 59));
            Navigator.pop(ctx, total.inSeconds < 1 ? const Duration(seconds: 1) : total);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).whenComplete(() {
    minutes.dispose();
    seconds.dispose();
  });
}
