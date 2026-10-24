import '../entities/ladder_step.dart';

/// Pure helpers for editing a ladder. Positions are always renumbered 0..n-1.
class LadderLogic {
  LadderLogic._();

  static List<LadderStep> renumber(List<LadderStep> steps) {
    final sorted = [...steps]..sort((a, b) => a.position.compareTo(b.position));
    return [
      for (var i = 0; i < sorted.length; i++)
        sorted[i].position == i ? sorted[i] : sorted[i].copyWith(position: i),
    ];
  }

  /// Move the item at [oldIndex] so it ends up at [newIndex] (its final
  /// index, as `ReorderableListView.onReorderItem` reports it).
  static List<LadderStep> reorder(List<LadderStep> steps, int oldIndex, int newIndex) {
    final list = [...renumber(steps)];
    if (oldIndex < 0 || oldIndex >= list.length) return list;
    final target = newIndex.clamp(0, list.length - 1);
    final item = list.removeAt(oldIndex);
    list.insert(target, item);
    return renumber(_withPositions(list));
  }

  static List<LadderStep> insertAt(List<LadderStep> steps, int index, LadderStep step) {
    final list = [...renumber(steps)];
    final i = index.clamp(0, list.length);
    list.insert(i, step);
    return renumber(_withPositions(list));
  }

  static List<LadderStep> remove(List<LadderStep> steps, String stepId) {
    final list = renumber(steps).where((s) => s.id != stepId).toList();
    return renumber(_withPositions(list));
  }

  static List<LadderStep> replaceText(List<LadderStep> steps, String stepId, String text) {
    return [for (final s in steps) s.id == stepId ? s.copyWith(text: text) : s];
  }

  /// The step after the one a round was about: the step with [id], or, when
  /// that id is gone because the ladder was edited meanwhile, the one now at
  /// [position]. Null on the last step, and when neither is found.
  static LadderStep? stepAfter(List<LadderStep> steps, {String? id, int? position}) {
    final sorted = renumber(steps);
    final index = id == null ? -1 : sorted.indexWhere((s) => s.id == id);
    if (index < 0) {
      // The step is gone (removed, or the ladder replaced): what now sits
      // at its old place is the step after the one that was done.
      return position != null && position >= 0 && position < sorted.length ? sorted[position] : null;
    }
    return index + 1 < sorted.length ? sorted[index + 1] : null;
  }

  /// Turn breakdown drafts into saved rungs. [idFactory] supplies ids.
  static List<LadderStep> fromMicroSteps(
    String taskId,
    List<MicroStep> steps,
    String Function() idFactory,
  ) {
    return [
      for (var i = 0; i < steps.length; i++)
        LadderStep(
          id: idFactory(),
          taskId: taskId,
          position: i,
          text: steps[i].text,
          suggestedDuration: steps[i].suggestedDuration,
        ),
    ];
  }

  static List<LadderStep> _withPositions(List<LadderStep> list) => [
    for (var i = 0; i < list.length; i++) list[i].copyWith(position: i),
  ];
}
