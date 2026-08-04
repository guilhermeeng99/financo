// `show Value` only — drift's query builder exports an `isNull` that would
// otherwise shadow the matcher of the same name.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../harness/factories/transaction_factory.dart';

void main() {
  late AppDatabase db;
  late TransactionsDao dao;

  const userId = 'user-1';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.transactionsDao;
  });

  tearDown(() => db.close());

  group('upsertTransaction + getTransactionById', () {
    test('round-trips every field of an expense', () async {
      final transaction = TransactionFactory.expense(
        notes: 'weekly shop',
        linkedTransactionId: 'tx-other',
      );

      await dao.upsertTransaction(transaction);

      expect(await dao.getTransactionById(transaction.id), transaction);
    });

    test('preserves the amount exactly', () async {
      // The cash side stores money as a `double`; SQLite REAL is the same IEEE
      // double, so a value with no exact binary form must survive untouched
      // rather than being coerced through a string or a rounded int.
      final transaction = TransactionFactory.expense(amount: 1234.56);

      await dao.upsertTransaction(transaction);

      final read = await dao.getTransactionById(transaction.id);
      expect(read!.amount, 1234.56);
    });

    test('round-trips the recurrence series fields', () async {
      final transaction = TransactionFactory.expense(
        recurrence: TransactionRecurrence.installment,
        recurrenceGroupId: 'grp-1',
        recurrenceIntervalMonths: 2,
        recurrenceIndex: 3,
        recurrenceTotal: 12,
        recurrenceBaseDescription: 'Notebook',
        recurrenceEndDate: DateTime(2025, 3, 15),
      );

      await dao.upsertTransaction(transaction);

      final read = await dao.getTransactionById(transaction.id);
      expect(read!.recurrence, TransactionRecurrence.installment);
      expect(read.recurrenceGroupId, 'grp-1');
      expect(read.recurrenceIntervalMonths, 2);
      expect(read.recurrenceIndex, 3);
      expect(read.recurrenceTotal, 12);
      expect(read.recurrenceBaseDescription, 'Notebook');
      expect(read.recurrenceEndDate, DateTime(2025, 3, 15));
    });

    test('round-trips the F8 investment cash-flow link', () async {
      final aporte = TransactionFactory.expense().copyWith(
        institutionId: 'inst-avenue',
        linkedInvestmentTransactionId: 'itx-1',
      );

      await dao.upsertTransaction(aporte);

      final read = await dao.getTransactionById(aporte.id);
      expect(read!.institutionId, 'inst-avenue');
      expect(read.linkedInvestmentTransactionId, 'itx-1');
      expect(read.isInvestmentCashFlow, isTrue);
    });

    test('overwrites on conflict rather than duplicating', () async {
      // Sync re-writes the same doc ids on every pull; a second insert has to
      // update the row, not fail or fork it.
      await dao.upsertTransaction(TransactionFactory.expense());
      await dao.upsertTransaction(
        TransactionFactory.expense(amount: 175, description: 'Groceries II'),
      );

      final all = await dao.getTransactions(userId: userId);
      expect(all, hasLength(1));
      expect(all.single.amount, 175);
      expect(all.single.description, 'Groceries II');
    });

    test('returns null for an unknown id', () async {
      expect(await dao.getTransactionById('nope'), isNull);
    });
  });

  group('insertAllTransactions', () {
    test('writes the whole batch and is safe to replay', () async {
      await dao.insertAllTransactions(TransactionFactory.list());
      await dao.insertAllTransactions(TransactionFactory.list());

      expect(await dao.getTransactions(userId: userId), hasLength(3));
    });

    test('accepts an empty batch', () async {
      await dao.insertAllTransactions([]);

      expect(await dao.getTransactions(userId: userId), isEmpty);
    });
  });

  group('getTransactions', () {
    setUp(() async {
      await dao.insertAllTransactions([
        TransactionFactory.income(date: DateTime(2024, 3, 5)),
        TransactionFactory.expense(date: DateTime(2024, 3, 15)),
        TransactionFactory.expense(
          id: 'tx-expense-2',
          accountId: 'acc-2',
          categoryId: 'cat-9',
          date: DateTime(2024, 3, 18),
          settlementStatus: TransactionSettlementStatus.pending,
          dueDate: DateTime(2024, 4, 20),
          recurrence: TransactionRecurrence.fixed,
          recurrenceGroupId: 'grp-rent',
        ),
        TransactionFactory.expense(id: 'tx-foreign', userId: 'user-2'),
      ]);
    });

    test('scopes to the user and orders newest date first', () async {
      final rows = await dao.getTransactions(userId: userId);

      expect(rows.map((t) => t.id).toList(), [
        'tx-expense-2',
        'tx-expense-1',
        'tx-income-1',
      ]);
    });

    test('filters by date range inclusively', () async {
      final rows = await dao.getTransactions(
        userId: userId,
        startDate: DateTime(2024, 3, 5),
        endDate: DateTime(2024, 3, 15),
      );

      expect(rows.map((t) => t.id).toList(), ['tx-expense-1', 'tx-income-1']);
    });

    test('filters by due-date range independently of date', () async {
      // Pending bills are listed by when they are due, not when they were
      // entered — the two ranges must not be conflated.
      final rows = await dao.getTransactions(
        userId: userId,
        dueStartDate: DateTime(2024, 4),
        dueEndDate: DateTime(2024, 4, 30),
      );

      expect(rows.map((t) => t.id).toList(), ['tx-expense-2']);
    });

    test('filters by account, category and settlement status', () async {
      expect(
        (await dao.getTransactions(
          userId: userId,
          accountId: 'acc-2',
        )).single.id,
        'tx-expense-2',
      );
      expect(
        (await dao.getTransactions(
          userId: userId,
          categoryId: 'cat-9',
        )).single.id,
        'tx-expense-2',
      );
      expect(
        (await dao.getTransactions(
          userId: userId,
          settlementStatus: TransactionSettlementStatus.pending,
        )).single.id,
        'tx-expense-2',
      );
    });

    test('filters by recurrence and recurrence group', () async {
      expect(
        (await dao.getTransactions(
          userId: userId,
          recurrence: TransactionRecurrence.fixed,
        )).single.id,
        'tx-expense-2',
      );
      expect(
        (await dao.getTransactions(
          userId: userId,
          recurrenceGroupId: 'grp-rent',
        )).single.id,
        'tx-expense-2',
      );
    });

    test('combines filters as AND, not OR', () async {
      final rows = await dao.getTransactions(
        userId: userId,
        accountId: 'acc-1',
        settlementStatus: TransactionSettlementStatus.pending,
      );

      expect(rows, isEmpty);
    });
  });

  group('getTransactionsUpTo', () {
    test('returns everything on or before the cutoff, newest first', () async {
      // This is the running-balance query — a row on the boundary day must be
      // included or the balance is understated.
      await dao.insertAllTransactions([
        TransactionFactory.income(date: DateTime(2024, 3, 5)),
        TransactionFactory.expense(date: DateTime(2024, 3, 15)),
        TransactionFactory.expense(
          id: 'tx-later',
          date: DateTime(2024, 3, 16),
        ),
      ]);

      final rows = await dao.getTransactionsUpTo(
        userId: userId,
        endDate: DateTime(2024, 3, 15),
      );

      expect(rows.map((t) => t.id).toList(), ['tx-expense-1', 'tx-income-1']);
    });

    test('can narrow to a single account', () async {
      await dao.insertAllTransactions([
        TransactionFactory.expense(),
        TransactionFactory.expense(id: 'tx-other-acc', accountId: 'acc-2'),
      ]);

      final rows = await dao.getTransactionsUpTo(
        userId: userId,
        endDate: DateTime(2024, 12, 31),
        accountId: 'acc-2',
      );

      expect(rows.map((t) => t.id).toList(), ['tx-other-acc']);
    });
  });

  group('deletes', () {
    test('deleteTransaction removes one row only', () async {
      await dao.insertAllTransactions(TransactionFactory.list());

      await dao.deleteTransaction('tx-expense-1');

      final remaining = await dao.getTransactions(userId: userId);
      expect(remaining.map((t) => t.id), isNot(contains('tx-expense-1')));
      expect(remaining, hasLength(2));
    });

    test('deleteTransactions removes the listed ids', () async {
      await dao.insertAllTransactions(TransactionFactory.list());

      await dao.deleteTransactions(['tx-expense-1', 'tx-income-1']);

      expect(
        (await dao.getTransactions(userId: userId)).map((t) => t.id).toList(),
        ['tx-expense-2'],
      );
    });

    test('deleteTransactions with an empty list is a no-op', () async {
      // Guarded explicitly: `isIn([])` would otherwise match nothing, but the
      // early return also avoids a pointless round-trip.
      await dao.insertAllTransactions(TransactionFactory.list());

      await dao.deleteTransactions([]);

      expect(await dao.getTransactions(userId: userId), hasLength(3));
    });

    test('deleteAllTransactions clears every user', () async {
      await dao.insertAllTransactions([
        TransactionFactory.expense(),
        TransactionFactory.expense(id: 'tx-foreign', userId: 'user-2'),
      ]);

      await dao.deleteAllTransactions();

      expect(await dao.getTransactions(userId: userId), isEmpty);
      expect(await dao.getTransactions(userId: 'user-2'), isEmpty);
    });
  });

  group('degraded rows', () {
    /// Writes a row the DAO's own mapper could not produce, to exercise the
    /// read-side fallbacks against data left by older schemas or migrations.
    Future<void> insertRaw({
      required String id,
      String type = 'expense',
      String settlementStatus = 'paid',
      String recurrence = 'single',
      Value<DateTime?> dueDate = const Value.absent(),
    }) => db
        .into(db.localTransactions)
        .insert(
          LocalTransactionsCompanion.insert(
            id: id,
            userId: userId,
            accountId: 'acc-1',
            categoryId: 'cat-1',
            type: type,
            amount: 10,
            description: 'legacy',
            date: DateTime(2024, 1, 2),
            settlementStatus: Value(settlementStatus),
            recurrence: Value(recurrence),
            dueDate: dueDate,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        );

    test('maps the pre-2026-06-10 bills recurrence vocabulary', () async {
      // Rows written by scripts/migrate_bills_to_transactions.js carry the old
      // bill words; dropping this mapping would silently reclassify every
      // migrated recurring bill as a one-off.
      await insertRaw(id: 'tx-oneshot', recurrence: 'oneShot');
      await insertRaw(id: 'tx-monthly', recurrence: 'monthly');

      expect(
        (await dao.getTransactionById('tx-oneshot'))!.recurrence,
        TransactionRecurrence.single,
      );
      expect(
        (await dao.getTransactionById('tx-monthly'))!.recurrence,
        TransactionRecurrence.fixed,
      );
    });

    test('falls back instead of throwing on unknown enum names', () async {
      await insertRaw(
        id: 'tx-junk',
        type: 'transfer',
        settlementStatus: 'scheduled',
        recurrence: 'weekly',
      );

      final read = await dao.getTransactionById('tx-junk');
      expect(read!.type, TransactionType.expense);
      expect(read.settlementStatus, TransactionSettlementStatus.paid);
      expect(read.recurrence, TransactionRecurrence.single);
    });

    test('substitutes date for a null dueDate', () async {
      // The column predates the pending/due split; a null there must not
      // surface as a missing due date on the entity.
      await insertRaw(id: 'tx-nodue');

      final read = await dao.getTransactionById('tx-nodue');
      expect(read!.dueDate, DateTime(2024, 1, 2));
    });
  });
}
