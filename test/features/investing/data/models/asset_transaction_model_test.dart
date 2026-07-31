import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/data/models/asset_transaction_model.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../harness/factories/investing_factories.dart';

void main() {
  AssetTransactionModel roundTrip(AssetTransactionModel model) =>
      AssetTransactionModel.fromMap(id: model.id, data: model.toJson());

  Map<String, dynamic> rawTransaction({
    Object? kind = 'buy',
    Object? currency = 'usd',
    Object? unitPriceMinor = 1050,
    Object? feesMinor = 0,
    Object? amountMinor = 10500,
  }) => {
    'userId': 'user-1',
    'institutionId': 'inst-avenue',
    'assetId': 'asset-aapl',
    'kind': kind,
    'quantity': 10.0,
    'unitPriceMinor': unitPriceMinor,
    'feesMinor': feesMinor,
    'amountMinor': amountMinor,
    'currency': currency,
    'date': Timestamp.fromDate(DateTime(2024, 1, 10)),
    'createdAt': Timestamp.fromDate(DateTime(2024, 1, 10)),
    'updatedAt': Timestamp.fromDate(DateTime(2024, 1, 10)),
  };

  group('money round-trip', () {
    // This is the money wire format. Every amount travels as an integer count
    // of minor units; a single rounding slip here silently corrupts a
    // portfolio, so these assert the exact `minorUnits`, never the major
    // double.
    test('preserves unit price, fees and amount to the exact minor unit', () {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(
          quantity: 7,
          unitPrice: const Money(3333, Currency.usd),
          fees: const Money(199, Currency.usd),
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.unitPrice.minorUnits, 3333);
      expect(decoded.fees.minorUnits, 199);
      // 3333 × 7 = 23331 — an odd cent total that a major-unit hop would round.
      expect(decoded.amount.minorUnits, 23331);
      expect(decoded, model);
    });

    test('survives an amount far beyond double cent precision', () {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(
          quantity: 1,
          unitPrice: const Money(999999999999, Currency.brl),
          currency: Currency.brl,
        ),
      );

      expect(roundTrip(model).amount.minorUnits, 999999999999);
    });

    test('one stored currency covers unit price, fees and amount', () {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.sell(currency: Currency.eur),
      );

      final json = model.toJson();
      expect(json['currency'], 'eur');

      final decoded = roundTrip(model);
      expect(decoded.unitPrice.currency, Currency.eur);
      expect(decoded.fees.currency, Currency.eur);
      expect(decoded.amount.currency, Currency.eur);
    });

    test('reads a num that arrived as a double back as an int', () {
      // Firestore hands back `num`; a JS-side write can land as 1050.0.
      final model = AssetTransactionModel.fromMap(
        id: 'tx-1',
        data: rawTransaction(unitPriceMinor: 1050.0, amountMinor: 10500.0),
      );

      expect(model.unitPrice.minorUnits, 1050);
      expect(model.amount.minorUnits, 10500);
    });
  });

  group('funding-account pairing (F8)', () {
    test('fundingAccountId and cashAmountMinor are absent together', () {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(),
      );

      final json = model.toJson();

      expect(json.containsKey('fundingAccountId'), isFalse);
      expect(json.containsKey('cashAmountMinor'), isFalse);
      final decoded = roundTrip(model);
      expect(decoded.fundingAccountId, isNull);
      expect(decoded.cashAmount, isNull);
    });

    test('an aporte round-trips both halves of the pair', () {
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(
          fundingAccountId: 'acc-checking-1',
          cashAmount: const Money(52345, Currency.brl),
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.fundingAccountId, 'acc-checking-1');
      expect(decoded.cashAmount!.minorUnits, 52345);
    });

    test('cash side stays BRL even when the trade is not', () {
      // The checking account that funds a USD buy still moves reais, so the
      // cash leg is stored without a currency and read back as BRL.
      final model = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.buy(
          fundingAccountId: 'acc-checking-1',
          cashAmount: const Money(52345, Currency.brl),
        ),
      );

      final decoded = roundTrip(model);

      expect(decoded.amount.currency, Currency.usd);
      expect(decoded.cashAmount!.currency, Currency.brl);
    });
  });

  group('enum fallback', () {
    test('unknown kind falls back to TransactionKind.buy', () {
      final model = AssetTransactionModel.fromMap(
        id: 'tx-1',
        data: rawTransaction(kind: 'split'),
      );

      expect(model.kind, TransactionKind.buy);
    });

    test('unknown currency falls back to Currency.brl', () {
      final model = AssetTransactionModel.fromMap(
        id: 'tx-1',
        data: rawTransaction(currency: 'jpy'),
      );

      expect(model.amount.currency, Currency.brl);
    });

    test('every TransactionKind round-trips', () {
      for (final kind in TransactionKind.values) {
        final decoded = AssetTransactionModel.fromMap(
          id: 'tx-1',
          data: rawTransaction(kind: kind.name),
        );
        expect(decoded.kind, kind, reason: 'kind ${kind.name}');
      }
    });
  });

  group('notes', () {
    test('omits the key when null and round-trips when set', () {
      final without = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.dividend(),
      );
      expect(without.toJson().containsKey('notes'), isFalse);

      final with_ = AssetTransactionModel.fromEntity(
        AssetTransactionFactory.dividend(notes: 'JCP'),
      );
      expect(roundTrip(with_).notes, 'JCP');
    });
  });
}
