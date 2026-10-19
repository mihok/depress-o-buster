import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/alarms/alarm_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const target = ApproachTarget(taskTitle: 'Shower', rungText: 'Stand in the bathroom doorway');

  test('the rest before a step announces the step', () {
    final c = AlarmCopy.phaseEnd(phase: Phase.rest, target: target, next: Phase.approach, preparing: true);
    expect(c.title, 'Time for the step');
    expect(c.body, target.description);
    final plain = AlarmCopy.phaseEnd(phase: Phase.rest, next: Phase.approach, preparing: true);
    expect(plain.body, 'The rest is over. The step starts now.');
  });

  test('a rest that waits for a tap says so', () {
    final c = AlarmCopy.phaseEnd(phase: Phase.longRest, target: target, preparing: true);
    expect(c.title, 'Long rest done');
    expect(c.body, 'Start the step when you are ready: ${target.description}');
  });

  test('a rest after an approach is simply done', () {
    final c = AlarmCopy.phaseEnd(phase: Phase.rest);
    expect(c.title, 'Rest done');
    expect(c.body, 'Ready when you are.');
  });

  test('an approach says rest now only when a rest follows', () {
    final followed = AlarmCopy.phaseEnd(phase: Phase.approach, target: target, next: Phase.rest);
    expect(followed.body, '${target.description}. That counts. Rest now.');
    final closes = AlarmCopy.phaseEnd(phase: Phase.approach, target: target);
    expect(closes.body, '${target.description}. That counts.');
    expect(AlarmCopy.phaseEnd(phase: Phase.approach).body, 'That counts.');
  });

  test('nothing in the copy judges', () {
    for (final phase in Phase.values) {
      for (final next in [null, Phase.approach, Phase.rest]) {
        final c = AlarmCopy.phaseEnd(phase: phase, target: target, next: next, preparing: true);
        expect('${c.title} ${c.body}', isNot(contains('!')));
        expect('${c.title} ${c.body}'.toLowerCase(), isNot(contains('missed')));
      }
    }
  });
}
