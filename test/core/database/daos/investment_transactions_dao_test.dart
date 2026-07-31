import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/investment_transactions_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/investing_factories.dart';

void main() {
  late AppDatabase db;
  late InvestmentTransactionsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.investmentTransactionsDao;
  });

  tearDown(() => db.close());

  group('upsertTransaction + getTransactions', () {
    test('round-trips a buy exactly', () async {
      final buy = AssetTransactionFactory.buy(notes: 'first tranche');

      await dao.upsertTransaction(buy);

      expect((await dao.getTransactions(userId)).single, buy);
    });

    test('preserves money to the exact minor unit', () async {
      // The local mirror stores minor units as INTEGER; a slip to REAL and
      // back would round odd cents and quietly desync from Firestore.
      await dao.upsertTransaction(
        AssetTransactionFactory.buy(
          quantity: 7,
          unitPrice: const Money(3333, Currency.usd),
          fees: const Money(199, Currency.usd),
        ),
      );

      final read = (await dao.getTransactions(userId)).single;
      expect(read.unitPrice.minorUnits, 3333);
      expect(read.fees.minorUnits, 199);
      expect(read.amount.minorUnits, 23331);
      expect(read.amount.currency, Currency.usd);
    });

    test('preserves fractional quantities', () async {
      // Crypto and fractional-share positions are the whole reason quantity is
      // a double rather than an int.
      await dao.upsertTransaction(
        AssetTransactionFactory.buy(quantity: 0.00123456),
      );

      expect((await dao.getTransactions(userId)).single.quantity, 0.00123456);
    });

    test('round-trips the F8 funding-account pair', () async {
      await dao.upsertTransaction(
        AssetTransactionFactory.buy(
          fundingAccountId: 'acc-checking-1',
          cashAmount: const Money(52345, Currency.brl),
        ),
      );

      final read = (await dao.getTransactions(userId)).single;
      expect(read.fundingAccountId, 'acc-checking-1');
      expect(read.cashAmount!.minorUnits, 52345);
      // The trade is USD but the cash leg moved reais.
      expect(read.cashAmount!.currency, Currency.brl);
      expect(read.amount.currency, Currency.usd);
    });

    test('leaves both halves of the pair null on a plain trade', () async {
      await dao.upsertTransaction(AssetTransactionFactory.sell());

      final read = (await dao.getTransactions(userId)).single;
      expect(read.fundingAccountId, isNull);
      expect(read.cashAmount, isNull);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertTransaction(AssetTransactionFactory.buy());
      await dao.upsertTransaction(AssetTransactionFactory.buy(quantity: 25));

      final all = await dao.getTransactions(userId);
      expect(all, hasLength(1));
      expect(all.single.quantity, 25);
    });
  });

  group('getTransactions', () {
    test('scopes to the user and orders newest date first', () async {
      await dao.insertAllTransactions([
        AssetTransactionFactory.buy(date: DateTime(2024)),
        AssetTransactionFactory.sell(date: DateTime(2024, 6)),
        AssetTransactionFactory.dividend(date: DateTime(2024, 3)),
        AssetTransactionFactory.buy(id: 'tx-foreign', userId: 'user-2'),
      ]);

      final rows = await dao.getTransactions(userId);

      expect(rows.map((t) => t.id).toList(), [
        'tx-sell-1',
        'tx-div-1',
        'tx-buy-1',
      ]);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getTransactions(userId), isEmpty);
    });
  });

  group('insertAllTransactions', () {
    test('writes the whole batch and is safe to replay', () async {
      final batch = [
        AssetTransactionFactory.buy(),
        AssetTransactionFactory.sell(),
        AssetTransactionFactory.dividend(),
      ];

      await dao.insertAllTransactions(batch);
      await dao.insertAllTransactions(batch);

      expect(await dao.getTransactions(userId), hasLength(3));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllTransactions([]);

      expect(await dao.getTransactions(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteTransaction removes one row only', () async {
      await dao.insertAllTransactions([
        AssetTransactionFactory.buy(),
        AssetTransactionFactory.sell(),
      ]);

      await dao.deleteTransaction('tx-sell-1');

      expect(
        (await dao.getTransactions(userId)).map((t) => t.id).toList(),
        ['tx-buy-1'],
      );
    });

    test('deleteAllTransactions clears every user', () async {
      await dao.insertAllTransactions([
        AssetTransactionFactory.buy(),
        AssetTransactionFactory.buy(id: 'tx-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllTransactions();

      expect(await dao.getTransactions(userId), isEmpty);
      expect(await dao.getTransactions('user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    test('falls back instead of throwing on unknown enum names', () async {
      await db
          .into(db.localInvestmentTransactions)
          .insert(
            LocalInvestmentTransactionsCompanion.insert(
              id: 'itx-junk',
              userId: userId,
              institutionId: 'inst-1',
              assetId: 'asset-1',
              kind: 'split',
              quantity: 1,
              unitPriceMinor: 100,
              feesMinor: 0,
              amountMinor: 100,
              currency: 'jpy',
              date: DateTime(2024),
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          );

      final read = (await dao.getTransactions(userId)).single;
      expect(read.kind, TransactionKind.buy);
      expect(read.amount.currency, Currency.brl);
    });
  });
}
