import 'package:financo/core/app_info/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppVersion', () {
    test('display returns the bare semver', () {
      const v = AppVersion(version: '1.0.1');
      expect(v.display, '1.0.1');
    });

    test('equality compares version', () {
      const a = AppVersion(version: '1.0.1');
      const b = AppVersion(version: '1.0.1');
      const c = AppVersion(version: '1.0.2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
