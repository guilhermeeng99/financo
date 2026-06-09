import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/transactions_table.dart';
import 'package:financo/features/transactions/domain/entities/transaction_entity.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [LocalTransactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  Future<void> insertAllTransactions(
    List<TransactionEntity> transactions,
  ) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localTransactions,
        transactions.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertTransaction(TransactionEntity transaction) =>
      into(localTransactions).insertOnConflictUpdate(_toCompanion(transaction));

  Future<List<TransactionEntity>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueStartDate,
    DateTime? dueEndDate,
    String? accountId,
    String? categoryId,
    TransactionSettlementStatus? settlementStatus,
  }) async {
    final query = select(localTransactions)
      ..where((t) => t.userId.equals(userId));

    if (startDate != null) {
      query.where(
        (t) => t.date.isBiggerOrEqualValue(startDate),
      );
    }
    if (endDate != null) {
      query.where(
        (t) => t.date.isSmallerOrEqualValue(endDate),
      );
    }
    if (dueStartDate != null) {
      query.where(
        (t) => t.dueDate.isBiggerOrEqualValue(dueStartDate),
      );
    }
    if (dueEndDate != null) {
      query.where(
        (t) => t.dueDate.isSmallerOrEqualValue(dueEndDate),
      );
    }
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    if (settlementStatus != null) {
      query.where((t) => t.settlementStatus.equals(settlementStatus.name));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);

    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  Future<List<TransactionEntity>> getTransactionsUpTo({
    required String userId,
    required DateTime endDate,
    String? accountId,
  }) async {
    final query = select(localTransactions)
      ..where(
        (t) => t.userId.equals(userId) & t.date.isSmallerOrEqualValue(endDate),
      );

    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.date)]);

    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  Future<TransactionEntity?> getTransactionById(String id) async {
    final row = await (select(
      localTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> deleteTransaction(String id) =>
      (delete(localTransactions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllTransactions() => delete(localTransactions).go();

  LocalTransactionsCompanion _toCompanion(TransactionEntity e) =>
      LocalTransactionsCompanion.insert(
        id: e.id,
        userId: e.userId,
        accountId: e.accountId,
        categoryId: e.categoryId,
        type: e.type.name,
        amount: e.amount,
        description: e.description,
        date: e.date,
        settlementStatus: Value(e.settlementStatus.name),
        dueDate: Value(e.dueDate),
        settledAt: Value(e.settledAt),
        recurrence: Value(e.recurrence.name),
        notes: Value(e.notes),
        linkedTransactionId: Value(e.linkedTransactionId),
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  TransactionEntity _toEntity(LocalTransaction row) => TransactionEntity(
    id: row.id,
    userId: row.userId,
    accountId: row.accountId,
    categoryId: row.categoryId,
    type: TransactionType.values.byName(row.type),
    amount: row.amount,
    description: row.description,
    date: row.date,
    settlementStatus: _parseSettlementStatus(row.settlementStatus),
    dueDate: row.dueDate ?? row.date,
    settledAt: row.settledAt,
    recurrence: _parseRecurrence(row.recurrence),
    notes: row.notes,
    linkedTransactionId: row.linkedTransactionId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

TransactionSettlementStatus _parseSettlementStatus(String value) =>
    TransactionSettlementStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TransactionSettlementStatus.paid,
    );

TransactionRecurrence _parseRecurrence(String value) =>
    TransactionRecurrence.values.firstWhere(
      (recurrence) => recurrence.name == value,
      orElse: () => TransactionRecurrence.oneShot,
    );
