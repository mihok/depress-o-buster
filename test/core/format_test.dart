import 'package:depress_o_buster/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatWords spells a duration out', () {
    expect(formatWords(const Duration(minutes: 5)), '5 min');
    expect(formatWords(const Duration(seconds: 30)), '30 sec');
    expect(formatWords(const Duration(minutes: 1, seconds: 30)), '1 min 30 sec');
    expect(formatWords(const Duration(hours: 1, minutes: 5)), '1 hr 5 min');
    expect(formatWords(Duration.zero), '0 sec');
  });

  test('formatSeries shares one "min" across whole minutes under an hour', () {
    expect(
      formatSeries([for (final m in [10, 10, 20, 30, 50]) Duration(minutes: m)]),
      '10, 10, 20, 30, 50 min',
    );
    expect(
      formatSeries([for (final m in [10, 10, 20, 30, 50, 80, 130]) Duration(minutes: m)]),
      '10, 10, 20, 30, 50 min, 1 hr 20 min, 2 hr 10 min',
    );
    expect(
      formatSeries(const [Duration(minutes: 1), Duration(seconds: 30), Duration(minutes: 2)]),
      '1 min, 30 sec, 2 min',
    );
    expect(
      formatSeries(const [Duration(seconds: 90), Duration(seconds: 90), Duration(minutes: 3)]),
      '1 min 30 sec, 1 min 30 sec, 3 min',
    );
    expect(formatSeries(const []), '');
  });
}
