// `show Value` only — drift's query builder exports matcher-shadowing names.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/account_factory.dart';

void main() {
  late AppDatabase db;
  late AccountsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.accountsDao;
  });

  tearDown(() => db.close());

  group('upsertAccount + getAccountById', () {
    test('round-trips a checking account', () async {
      final account = AccountFactory.checking();

      await dao.upsertAccount(account);

      expect(await dao.getAccountById(account.id), account);
    });

    test('round-trips the credit-card-only fields', () async {
      final card = AccountFactory.creditCard();

      await dao.upsertAccount(card);

      final read = await dao.getAccountById(card.id);
      expect(read!.creditLimit, 5000);
      expect(read.closingDay, 3);
      expect(read.dueDay, 10);
      expect(read.linkedAccountId, 'acc-checking-1');
    });

    test('round-trips a non-BRL currency (F9)', () async {
      // Multi-currency accounts store their native currency; losing it would
      // silently re-denominate the balance as reais.
      final wise = AccountFactory.checking(
        id: 'acc-wise',
        currency: Currency.eur,
        initialBalance: 250.75,
      );

      await dao.upsertAccount(wise);

      final read = await dao.getAccountById('acc-wise');
      expect(read!.currency, Currency.eur);
      expect(read.initialBalance, 250.75);
    });

    test('overwrites on conflict rather than duplicating', () async {
      await dao.upsertAccount(AccountFactory.checking());
      await dao.upsertAccount(
        AccountFactory.checking(name: 'Renamed', initialBalance: 2500),
      );

      final all = await dao.getAccounts(userId);
      expect(all, hasLength(1));
      expect(all.single.name, 'Renamed');
      expect(all.single.initialBalance, 2500);
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getAccountById('nope'), isNull);
    });
  });

  group('getAccounts', () {
    test('scopes to the user and orders by createdAt ascending', () async {
      await dao.insertAllAccounts([
        AccountFactory.checking(id: 'acc-new', createdAt: DateTime(2026, 2)),
        AccountFactory.checking(id: 'acc-old', createdAt: DateTime(2024)),
        AccountFactory.checking(id: 'acc-foreign', userId: 'user-2'),
      ]);

      final accounts = await dao.getAccounts(userId);

      expect(accounts.map((a) => a.id).toList(), ['acc-old', 'acc-new']);
    });

    test('returns an empty list when the user has none', () async {
      expect(await dao.getAccounts(userId), isEmpty);
    });
  });

  group('insertAllAccounts', () {
    test('writes the whole batch and is safe to replay', () async {
      await dao.insertAllAccounts(AccountFactory.list());
      await dao.insertAllAccounts(AccountFactory.list());

      expect(await dao.getAccounts(userId), hasLength(3));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllAccounts([]);

      expect(await dao.getAccounts(userId), isEmpty);
    });
  });

  group('deletes', () {
    test('deleteAccount removes one row only', () async {
      await dao.insertAllAccounts(AccountFactory.list());

      await dao.deleteAccount('acc-cc-1');

      final remaining = await dao.getAccounts(userId);
      expect(remaining.map((a) => a.id), isNot(contains('acc-cc-1')));
      expect(remaining, hasLength(2));
    });

    test('deleteAllAccounts clears every user', () async {
      await dao.insertAllAccounts([
        AccountFactory.checking(),
        AccountFactory.checking(id: 'acc-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllAccounts();

      expect(await dao.getAccounts(userId), isEmpty);
      expect(await dao.getAccounts('user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    test('falls back instead of throwing on unknown enum names', () async {
      // A renamed bank or account type left by an older build must degrade to
      // a usable row, not crash the accounts screen on read.
      await db
          .into(db.localAccounts)
          .insert(
            LocalAccountsCompanion.insert(
              id: 'acc-junk',
              userId: userId,
              name: 'Legacy',
              type: 'savings',
              bank: 'banco_extinto',
              initialBalance: 10,
              currency: const Value('gbp'),
              createdAt: DateTime(2024),
            ),
          );

      final read = await dao.getAccountById('acc-junk');
      expect(read!.type, AccountType.checking);
      expect(read.bank, BankType.others);
      expect(read.currency, Currency.brl);
    });
  });
}
