import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/models/snapshot_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  SnapshotModel roundTrip(SnapshotModel model) =>
      SnapshotModel.fromMap(data: model.toJson());

  Map<String, dynamic> rawSnapshot({Object? currency = 'brl'}) => {
    'userId': 'user-1',
    'date': Timestamp.fromDate(DateTime(2024, 1, 10)),
    'totalValueMinor': 100000,
    'totalInvestedMinor': 80000,
    'unrealizedPlMinor': 20000,
    'currency': currency,
  };

  group('money round-trip', () {
    test('preserves the three totals to the exact minor unit', () {
      final model = SnapshotModel.fromEntity(
        SnapshotFactory.day(
          totalValue: const Money(123456789, Currency.brl),
          totalInvested: const Money(98765432, Currency.brl),
          unrealizedPL: const Money(24691357, Currency.brl),
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.totalValue.minorUnits, 123456789);
      expect(decoded.totalInvested.minorUnits, 98765432);
      expect(decoded.unrealizedPL.minorUnits, 24691357);
      expect(decoded, model);
    });

    test('carries a negative P/L through unchanged', () {
      // A portfolio under water is the case a sign-losing serialiser would
      // quietly flip into a gain.
      final model = SnapshotModel.fromEntity(
        SnapshotFactory.day(
          totalValue: const Money(70000, Currency.brl),
          totalInvested: const Money(80000, Currency.brl),
        ),
      );

      expect(roundTrip(model).unrealizedPL.minorUnits, -10000);
    });

    test('one stored currency covers all three totals', () {
      final model = SnapshotModel.fromEntity(
        SnapshotFactory.day(currency: Currency.usd),
      );

      expect(model.toJson()['currency'], 'usd');
      final decoded = roundTrip(model);
      expect(decoded.totalValue.currency, Currency.usd);
      expect(decoded.totalInvested.currency, Currency.usd);
      expect(decoded.unrealizedPL.currency, Currency.usd);
    });

    test('unknown currency falls back to Currency.brl', () {
      final model = SnapshotModel.fromMap(data: rawSnapshot(currency: 'gbp'));

      expect(model.totalValue.currency, Currency.brl);
    });
  });

  group('docId', () {
    test('is user + day, so re-recording a day overwrites', () {
      final model = SnapshotModel.fromEntity(
        SnapshotFactory.day(date: DateTime(2024, 3, 5, 23, 59)),
      );

      // Zero-padded and time-independent — two runs on the same day must
      // collide on one doc rather than append a second history point.
      expect(model.docId, 'user-1_2024-03-05');
      expect(
        SnapshotModel.fromEntity(
          SnapshotFactory.day(date: DateTime(2024, 3, 5)),
        ).docId,
        model.docId,
      );
    });

    test('is mirrored into the document as dayKey', () {
      final model = SnapshotModel.fromEntity(
        SnapshotFactory.day(date: DateTime(2024, 12, 31)),
      );

      expect(model.toJson()['dayKey'], '2024-12-31');
    });
  });
}
