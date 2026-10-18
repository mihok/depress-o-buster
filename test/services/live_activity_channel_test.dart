import 'package:depress_o_buster/domain/domain.dart';
import 'package:depress_o_buster/services/alarms/live_activity_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(LiveActivityChannel.name);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('show sends the phase, title, run id and epoch milliseconds', () async {
    MethodCall? seen;
    messenger.setMockMethodCallHandler(channel, (call) async {
      seen = call;
      return true;
    });
    final endsAt = DateTime.utc(2026, 10, 18, 9, 5);
    final ok = await LiveActivityChannel(channel: channel).show(
      runId: 'run-1',
      phase: Phase.approach,
      title: 'Sit up for 2 minutes',
      endsAt: endsAt,
      restEndsAt: endsAt.add(const Duration(minutes: 10)),
      restPhase: Phase.longRest,
    );
    expect(ok, isTrue);
    expect(seen!.method, 'show');
    final args = seen!.arguments as Map;
    expect(args['runId'], 'run-1');
    expect(args['phase'], 'approach');
    expect(args['title'], 'Sit up for 2 minutes');
    expect(args['endsAtMs'], endsAt.millisecondsSinceEpoch);
    expect(args['restEndsAtMs'], endsAt.millisecondsSinceEpoch + 600000);
    expect(args['restPhase'], 'longRest');
    expect(args['pausedAtMs'], isNull);
  });

  test('a missing native side is reported as unavailable, never thrown', () async {
    final c = LiveActivityChannel(channel: channel);
    expect(await c.isAvailable(), isFalse);
    expect(await c.show(runId: 'r', phase: Phase.rest, title: 'Rest', endsAt: DateTime.now()), isFalse);
    await c.hide();
  });

  test('platform errors are swallowed', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'nope');
    });
    final c = LiveActivityChannel(channel: channel);
    expect(await c.isAvailable(), isFalse);
    expect(await c.show(runId: 'r', phase: Phase.rest, title: 'Rest', endsAt: DateTime.now()), isFalse);
  });
}
