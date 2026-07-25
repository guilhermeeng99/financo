import 'package:drift/drift.dart';
import 'package:financo/core/database/app_database.dart';
import 'package:financo/core/database/tables/investment_transactions_table.dart';
import 'package:financo/core/money/currency.dart';
import 'package:financo/core/money/money.dart';
import 'package:financo/features/investing/domain/entities/asset_transaction.dart';

part 'investment_transactions_dao.g.dart';

@DriftAccessor(tables: [LocalInvestmentTransactions])
class InvestmentTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$InvestmentTransactionsDaoMixin {
  InvestmentTransactionsDao(super.attachedDatabase);

  Future<void> insertAllTransactions(List<AssetTransaction> txs) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        localInvestmentTransactions,
        txs.map(_toCompanion).toList(),
      );
    });
  }

  Future<void> upsertTransaction(AssetTransaction tx) => into(
    localInvestmentTransactions,
  ).insertOnConflictUpdate(_toCompanion(tx));

  Future<List<AssetTransaction>> getTransactions(String userId) async {
    final rows =
        await (select(localInvestmentTransactions)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.date)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> deleteTransaction(String id) =>
      (delete(localInvestmentTransactions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllTransactions() =>
      delete(localInvestmentTransactions).go();

  LocalInvestmentTransactionsCompanion _toCompanion(AssetTransaction e) =>
      LocalInvestmentTransactionsCompanion.insert(
        id: e.id,
        userId: e.userId,
        institutionId: e.institutionId,
        assetId: e.assetId,
        kind: e.kind.name,
        quantity: e.quantity,
        unitPriceMinor: e.unitPrice.minorUnits,
        feesMinor: e.fees.minorUnits,
        amountMinor: e.amount.minorUnits,
        currency: e.amount.currency.name,
        date: e.date,
        notes: Value(e.notes),
        fundingAccountId: Value(e.fundingAccountId),
        cashAmountMinor: Value(e.cashAmount?.minorUnits),
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  AssetTransaction _toEntity(LocalInvestmentTransaction row) {
    final ccy = Currency.values.byName(row.currency);
    return AssetTransaction(
      id: row.id,
      userId: row.userId,
      institutionId: row.institutionId,
      assetId: row.assetId,
      kind: TransactionKind.values.byName(row.kind),
      quantity: row.quantity,
      unitPrice: Money(row.unitPriceMinor, ccy),
      fees: Money(row.feesMinor, ccy),
      amount: Money(row.amountMinor, ccy),
      date: row.date,
      notes: row.notes,
      fundingAccountId: row.fundingAccountId,
      cashAmount: row.cashAmountMinor == null
          ? null
          : Money(row.cashAmountMinor!, Currency.brl),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
