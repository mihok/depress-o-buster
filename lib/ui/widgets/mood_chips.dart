import 'package:flutter/material.dart';

const List<String> kMoods = ['flat', 'tired', 'numb', 'restless', 'anxious', 'okay', 'hopeful'];

/// One-word mood, always optional, never required to continue.
class MoodChips extends StatelessWidget {
  const MoodChips({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final mood in kMoods)
              ChoiceChip(
                label: Text(mood),
                selected: selected == mood,
                onSelected: (on) => onChanged(on ? mood : null),
              ),
          ],
        ),
      ],
    );
  }
}
