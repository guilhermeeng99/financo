import 'dart:io';

import 'package:financo/core/constants/access_control.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isMasterEmail', () {
    test('returns true for master email (case-insensitive)', () {
      expect(isMasterEmail(kMasterEmail), isTrue);
      expect(isMasterEmail(kMasterEmail.toUpperCase()), isTrue);
      expect(isMasterEmail(' GUILHERMEENG99@gmail.com '.trim()), isTrue);
    });

    test('returns false for any other email', () {
      expect(isMasterEmail('friend@example.com'), isFalse);
      expect(isMasterEmail('  '), isFalse);
      expect(isMasterEmail(null), isFalse);
      expect(isMasterEmail(''), isFalse);
    });
  });

  group('normalizeEmail', () {
    test('lowercases and trims', () {
      expect(normalizeEmail('  Friend@EXAMPLE.com '), 'friend@example.com');
    });
  });

  group('master email is in sync across rules + functions config', () {
    test('firestore.rules contains kMasterEmail literal', () {
      final rules = File('firestore.rules').readAsStringSync();
      expect(rules.contains("'$kMasterEmail'"), isTrue);
    });

    test('functions/src/config.ts contains kMasterEmail literal', () {
      final config = File('functions/src/config.ts').readAsStringSync();
      expect(config.contains("'$kMasterEmail'"), isTrue);
    });
  });
}
