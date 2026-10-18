import 'package:depress_o_buster/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LadderStep step(String id, int position, [String? text]) =>
      LadderStep(id: id, taskId: 't', position: position, text: text ?? id);

  final ladder = [step('a', 0), step('b', 1), step('c', 2), step('d', 3)];

  List<String> ids(List<LadderStep> steps) => steps.map((s) => s.id).toList();
  List<int> positions(List<LadderStep> steps) => steps.map((s) => s.position).toList();

  group('LadderLogic', () {
    test('renumber sorts by position and closes gaps', () {
      final messy = [step('c', 7), step('a', 0), step('b', 3)];
      final fixed = LadderLogic.renumber(messy);
      expect(ids(fixed), ['a', 'b', 'c']);
      expect(positions(fixed), [0, 1, 2]);
    });

    test('reorder moves an item down to its final index', () {
      final r = LadderLogic.reorder(ladder, 0, 2);
      expect(ids(r), ['b', 'c', 'a', 'd']);
      expect(positions(r), [0, 1, 2, 3]);
    });

    test('reorder moves an item up', () {
      final r = LadderLogic.reorder(ladder, 3, 0);
      expect(ids(r), ['d', 'a', 'b', 'c']);
    });

    test('reorder to the very end, clamping past the end', () {
      expect(ids(LadderLogic.reorder(ladder, 1, 3)), ['a', 'c', 'd', 'b']);
      expect(ids(LadderLogic.reorder(ladder, 1, 9)), ['a', 'c', 'd', 'b']);
    });

    test('reorder with a bad index is a no-op', () {
      expect(ids(LadderLogic.reorder(ladder, 9, 0)), ids(ladder));
    });

    test('insertAt and remove renumber', () {
      final inserted = LadderLogic.insertAt(ladder, 1, step('x', 99));
      expect(ids(inserted), ['a', 'x', 'b', 'c', 'd']);
      expect(positions(inserted), [0, 1, 2, 3, 4]);
      final removed = LadderLogic.remove(inserted, 'b');
      expect(ids(removed), ['a', 'x', 'c', 'd']);
      expect(positions(removed), [0, 1, 2, 3]);
      expect(ids(LadderLogic.insertAt(ladder, 50, step('z', 0))).last, 'z');
    });

    test('replaceText only touches the one step', () {
      final r = LadderLogic.replaceText(ladder, 'b', 'new');
      expect(r[1].text, 'new');
      expect(r[0].text, 'a');
    });

    test('fromMicroSteps assigns ids and positions', () {
      var n = 0;
      final steps = LadderLogic.fromMicroSteps(
        't9',
        const [MicroStep('one', suggestedDuration: Duration(minutes: 1)), MicroStep('two')],
        () => 'id-${n++}',
      );
      expect(ids(steps), ['id-0', 'id-1']);
      expect(positions(steps), [0, 1]);
      expect(steps.first.taskId, 't9');
      expect(steps.first.suggestedDuration, const Duration(minutes: 1));
      expect(steps.last.suggestedDuration, isNull);
    });
  });

  group('StarterLadders', () {
    test('every starter ladder begins tiny and has several rungs', () {
      for (final entry in StarterLadders.byTitle.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5), reason: entry.key);
        final first = entry.value.first.suggestedDuration;
        expect(first, isNotNull, reason: entry.key);
        expect(first!.inMinutes, lessThanOrEqualTo(2), reason: entry.key);
        for (final s in entry.value) {
          expect(s.text, isNot(contains('!')), reason: 'no cheering');
        }
      }
    });

    test('the laundry ladder is the one from the brief', () {
      final laundry = StarterLadders.byTitle['Laundry']!;
      expect(laundry, hasLength(9));
      expect(laundry.first.text, 'Think about laundry for 1 minute');
      expect(laundry.last.text, 'Full laundry cycle');
    });

    test('match finds ladders by title and by keyword', () {
      expect(StarterLadders.match('Laundry'), same(StarterLadders.byTitle['Laundry']));
      expect(StarterLadders.match('do the laundry'), same(StarterLadders.byTitle['Laundry']));
      expect(StarterLadders.match('text Sam back'), same(StarterLadders.byTitle['Reply to someone']));
      expect(StarterLadders.match('Water the plants'), isNull);
      expect(StarterLadders.match(''), isNull);
    });

    test('generic uses the title and ends with the whole task', () {
      final g = StarterLadders.generic('Water the plants');
      expect(g.first.text, contains('Water the plants'));
      expect(g.last.text, contains('Water the plants'));
      expect(g.length, greaterThanOrEqualTo(6));
    });

    test('smallerThan ends with the rung itself', () {
      final s = StarterLadders.smallerThan('Carry the basket to the machine', rungMinutes: 5);
      expect(s.last.text, 'Carry the basket to the machine');
      expect(s.last.suggestedDuration, const Duration(minutes: 5));
      expect(s.first.suggestedDuration, const Duration(minutes: 1));
    });
  });
}
