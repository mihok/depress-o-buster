import 'package:depress_o_buster/ui/widgets/cairn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stone count grows one per level and settles at nine', () {
    expect(const Cairn(level: 0).stones, 1);
    expect(const Cairn(level: 1).stones, 1);
    expect(const Cairn(level: 5).stones, 5);
    expect(const Cairn(level: 9).stones, 9);
    expect(const Cairn(level: 40).stones, 9);
  });

  test('painter repaints only when something it draws changes', () {
    const a = CairnPainter(stones: 3, stone: Colors.green, muted: Colors.grey, water: Colors.blue);
    const same = CairnPainter(stones: 3, stone: Colors.green, muted: Colors.grey, water: Colors.blue);
    const more = CairnPainter(stones: 4, stone: Colors.green, muted: Colors.grey, water: Colors.blue);
    expect(a.shouldRepaint(same), isFalse);
    expect(a.shouldRepaint(more), isTrue);
  });

  testWidgets('paints every level without error and describes itself', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(children: [for (var l = 1; l <= 12; l++) Cairn(level: l, size: const Size(28, 40))]),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Level 1 cairn, 1 stone'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 12 cairn, 9 stones'), findsOneWidget);
  });
}
