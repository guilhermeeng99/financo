import 'package:financo/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Asserts logic (valid → null, invalid → a message) rather than exact copy,
// so the suite stays locale-independent.
void main() {
  group('Validators.requiredField', () {
    test('rejects null and blank', () {
      expect(Validators.requiredField(null), isNotNull);
      expect(Validators.requiredField('   '), isNotNull);
    });

    test('accepts non-blank', () {
      expect(Validators.requiredField('x'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects null/blank', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('foo'), isNotNull);
      expect(Validators.email('foo@'), isNotNull);
      expect(Validators.email('foo@bar'), isNotNull);
      expect(Validators.email('@bar.com'), isNotNull);
    });

    test('accepts valid addresses (trimmed)', () {
      expect(Validators.email('a@b.com'), isNull);
      expect(Validators.email('  user.name+tag@sub.example.co  '), isNull);
    });
  });

  group('Validators.amount', () {
    test('rejects null/blank', () {
      expect(Validators.amount(null), isNotNull);
      expect(Validators.amount(''), isNotNull);
    });

    test('rejects zero, negative and garbage', () {
      expect(Validators.amount('0'), isNotNull);
      expect(Validators.amount('-5'), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
    });

    test('accepts BR and EN positive amounts', () {
      expect(Validators.amount('2.000,00'), isNull);
      expect(Validators.amount('1,234.56'), isNull);
      expect(Validators.amount('10'), isNull);
    });
  });
}
