import 'package:financo/features/investing/domain/entities/fixed_income_terms.dart';
import 'package:financo/features/investing/domain/services/fixed_income_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  group('FixedIncomeMetadata.write', () {
    test('encodes the basis name and the rate under their keys', () {
      final result = FixedIncomeMetadata.write(FixedIncomeBasis.cdi, 110);

      expect(result[FixedIncomeMetadata.basisKey], 'cdi');
      expect(result[FixedIncomeMetadata.rateKey], '110');
    });

    test('trims trailing zeros: 110.0 -> "110"', () {
      final result = FixedIncomeMetadata.write(FixedIncomeBasis.prefixed, 110);

      expect(result[FixedIncomeMetadata.rateKey], '110');
    });

    test('keeps a meaningful fractional part: 6.5 -> "6.5"', () {
      final result = FixedIncomeMetadata.write(FixedIncomeBasis.ipca, 6.5);

      expect(result[FixedIncomeMetadata.rateKey], '6.5');
    });

    test('keeps up to four decimals: 12.3456 -> "12.3456"', () {
      final result = FixedIncomeMetadata.write(
        FixedIncomeBasis.prefixed,
        12.3456,
      );

      expect(result[FixedIncomeMetadata.rateKey], '12.3456');
    });
  });

  group('FixedIncomeMetadata.read', () {
    test('round-trips a whole-number rate written by write()', () {
      final asset = AssetFactory.stockUs(
        metadata: FixedIncomeMetadata.write(FixedIncomeBasis.cdi, 110),
      );

      final parsed = FixedIncomeMetadata.read(asset);

      expect(parsed, isNotNull);
      expect(parsed!.$1, FixedIncomeBasis.cdi);
      expect(parsed.$2, 110.0);
    });

    test('round-trips a fractional rate written by write()', () {
      final asset = AssetFactory.stockUs(
        metadata: FixedIncomeMetadata.write(FixedIncomeBasis.ipca, 6.5),
      );

      expect(FixedIncomeMetadata.read(asset), (FixedIncomeBasis.ipca, 6.5));
    });

    test('returns null when no fixed-income metadata is present', () {
      expect(FixedIncomeMetadata.read(AssetFactory.stockUs()), isNull);
    });

    test('returns null when the basis key is absent', () {
      final asset = AssetFactory.stockUs(
        metadata: const {FixedIncomeMetadata.rateKey: '110'},
      );

      expect(FixedIncomeMetadata.read(asset), isNull);
    });

    test('returns null when the rate key is absent', () {
      final asset = AssetFactory.stockUs(
        metadata: const {FixedIncomeMetadata.basisKey: 'cdi'},
      );

      expect(FixedIncomeMetadata.read(asset), isNull);
    });

    test('returns null when the basis name is unknown', () {
      final asset = AssetFactory.stockUs(
        metadata: const {
          FixedIncomeMetadata.basisKey: 'bogus',
          FixedIncomeMetadata.rateKey: '110',
        },
      );

      expect(FixedIncomeMetadata.read(asset), isNull);
    });

    test('returns null when the rate is unparseable', () {
      final asset = AssetFactory.stockUs(
        metadata: const {
          FixedIncomeMetadata.basisKey: 'cdi',
          FixedIncomeMetadata.rateKey: 'abc',
        },
      );

      expect(FixedIncomeMetadata.read(asset), isNull);
    });
  });
}
