import 'package:financo/core/utils/enum_parse.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Fruit { apple, banana }

void main() {
  group('enumByNameOrNull', () {
    test('resolves a known name', () {
      expect(enumByNameOrNull(_Fruit.values, 'banana'), _Fruit.banana);
    });

    test('returns null for an unknown name', () {
      expect(enumByNameOrNull(_Fruit.values, 'durian'), isNull);
    });

    // The whole point: a stored value that no longer maps to anything must
    // not throw. `Values.byName` raises ArgumentError here, which crashed the
    // screen reading the row instead of degrading it.
    test('returns null instead of throwing on a retired value', () {
      expect(() => enumByNameOrNull(_Fruit.values, 'quince'), returnsNormally);
    });

    test('returns null for a null or non-string value', () {
      expect(enumByNameOrNull(_Fruit.values, null), isNull);
      expect(enumByNameOrNull(_Fruit.values, 42), isNull);
      expect(enumByNameOrNull(_Fruit.values, <String>['apple']), isNull);
    });

    test('is case-sensitive, matching enum.name exactly', () {
      expect(enumByNameOrNull(_Fruit.values, 'Apple'), isNull);
      expect(enumByNameOrNull(_Fruit.values, 'apple'), _Fruit.apple);
    });

    test('returns null for an empty value list', () {
      expect(enumByNameOrNull(<_Fruit>[], 'apple'), isNull);
    });
  });

  group('enumByName', () {
    test('resolves a known name', () {
      expect(enumByName(_Fruit.values, 'apple', _Fruit.banana), _Fruit.apple);
    });

    test('falls back for an unknown name', () {
      expect(enumByName(_Fruit.values, 'durian', _Fruit.banana), _Fruit.banana);
    });

    test('falls back for a null or non-string value', () {
      expect(enumByName(_Fruit.values, null, _Fruit.apple), _Fruit.apple);
      expect(enumByName(_Fruit.values, 7, _Fruit.apple), _Fruit.apple);
    });
  });
}
