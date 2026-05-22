import 'package:financo/core/utils/string_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeForMatch', () {
    test('lowercases and trims', () {
      expect(normalizeForMatch('  Hello  '), 'hello');
    });

    test('strips Portuguese diacritics', () {
      expect(normalizeForMatch('Cartão de Crédito'), 'cartao de credito');
      expect(normalizeForMatch('Conta Corrente'), 'conta corrente');
      expect(normalizeForMatch('Saúde'), 'saude');
    });

    test('handles ç and ñ', () {
      expect(normalizeForMatch('Açaí'), 'acai');
      expect(normalizeForMatch('Niño'), 'nino');
    });

    test('leaves already-normalised text untouched', () {
      expect(normalizeForMatch('transferencia'), 'transferencia');
    });

    test('returns empty for blank input', () {
      expect(normalizeForMatch('   '), '');
    });
  });
}
