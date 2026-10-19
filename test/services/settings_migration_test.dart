import 'package:depress_o_buster/services/settings/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings saved before rest-first load with the new defaults', () {
    final s = AppSettings.fromJson({'autoStartRest': false, 'approachMs': 60000});
    expect(s.restFirst, isTrue, reason: 'the new order is the default for everyone');
    expect(s.autoStartNext, isFalse, reason: 'the old automatic-start choice is kept');
    expect(s.approach, const Duration(minutes: 1));
  });

  test('the new keys win over the old one and round-trip', () {
    final s = AppSettings.fromJson({'autoStartRest': false, 'autoStartNext': true, 'restFirst': false});
    expect(s.autoStartNext, isTrue);
    expect(s.restFirst, isFalse);
    final back = AppSettings.fromJson(s.toJson());
    expect(back.restFirst, isFalse);
    expect(back.autoStartNext, isTrue);
    expect(s.toJson().containsKey('autoStartRest'), isFalse);
  });
}
