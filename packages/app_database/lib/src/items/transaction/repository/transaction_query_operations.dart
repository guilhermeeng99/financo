import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../core/financial_type.dart';
import '../../../database/database_manager.dart';
import '../../category/domain/category_table.dart';

/// Mixin containing advanced query operations for transactions
mixin TransactionQueryOperations {
  DatabaseManager get database;

  Future<Either<Failure, List<TransactionI>>> getTransactionsWithDetails({
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final query = _buildTransactionsQuery(
        accountIds: accountIds,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      final result = await query.get();
      final transactionsWithDetails = await _processQueryResults(result);

      return Either.right(transactionsWithDetails);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting transactions with details: $e'),
      );
    }
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildTransactionsQuery({
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    var query = database.select(database.transactions).join([
      leftOuterJoin(
        database.accounts,
        database.accounts.id.equalsExp(database.transactions.accountId),
      ),
      leftOuterJoin(
        database.categories,
        database.categories.id.equalsExp(database.transactions.categoryId),
      ),
    ]);

    query = _applyFilters(query, accountIds, startDate, endDate);
    query = _applyOrdering(query);

    if (limit != null) {
      return query..limit(limit, offset: offset);
    }

    return query;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _applyFilters(
    JoinedSelectStatement<HasResultSet, dynamic> query,
    Set<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final conditions = <Expression<bool>>[];

    if (accountIds != null && accountIds.isNotEmpty) {
      conditions.add(database.transactions.accountId.isIn(accountIds));
    }

    if (startDate != null && endDate != null) {
      conditions.add(
        database.transactions.actualDate.isBetweenValues(startDate, endDate),
      );
    }

    if (conditions.isNotEmpty) {
      return query..where(conditions.reduce((a, b) => a & b));
    }

    return query;
  }

  /// Applies ordering to the query
  JoinedSelectStatement<HasResultSet, dynamic> _applyOrdering(
    JoinedSelectStatement<HasResultSet, dynamic> query,
  ) {
    return query..orderBy([
      OrderingTerm(
        expression: database.transactions.competenceDate,
        mode: OrderingMode.desc,
      ),
      OrderingTerm(
        expression: database.transactions.createdAt,
        mode: OrderingMode.desc,
      ),
    ]);
  }

  Future<List<TransactionI>> _processQueryResults(
    List<TypedResult> results,
  ) async {
    final transactionsWithDetails = <TransactionI>[];

    for (final row in results) {
      final transaction = row.readTable(database.transactions);
      final account = row.readTableOrNull(database.accounts);
      final category = row.readTableOrNull(database.categories);

      final isTransfer =
          transaction.transferId != null && transaction.targetAccountId != null;
      final categoryName = isTransfer
          ? null
          : await _resolveCategoryName(category);
      final otherAccount = await _resolveOtherAccount(transaction);

      transactionsWithDetails.add(
        TransactionI(
          t: transaction,
          accountName: account?.name ?? 'Unknown Account',
          categoryName: categoryName,
          otherAccount: otherAccount,
        ),
      );
    }

    return transactionsWithDetails;
  }

  Future<String?> _resolveCategoryName(CategoryData? category) async {
    if (category == null) {
      return 'Unknown Category';
    }

    if (category.parentCategoryId != null) {
      final parentQuery = database.select(database.categories)
        ..where((tbl) => tbl.id.equals(category.parentCategoryId!));
      final parentCategory = await parentQuery.getSingleOrNull();

      if (parentCategory != null) {
        return '${parentCategory.name}/${category.name}';
      }
    }

    return category.name;
  }

  /// Resolves other account name for transfer transactions with direction arrows
  Future<String?> _resolveOtherAccount(DataTransaction transaction) async {
    if (transaction.targetAccountId == null || transaction.transferId == null) {
      return null;
    }

    String? accountName;
    String arrow;

    if (transaction.transactionType == FinancialType.expense) {
      // This is the sending transaction - show where money is going
      accountName = await _getAccountNameById(transaction.targetAccountId!);
      arrow = '→';
    } else if (transaction.transactionType == FinancialType.income) {
      // This is the receiving transaction - show where money came from
      accountName = await _getSourceAccountNameForTransfer(
        transaction.transferId!,
      );
      arrow = '←';
    } else {
      return null;
    }

    if (accountName != null) {
      return '$arrow $accountName';
    }

    return null;
  }

  Future<String?> _getAccountNameById(int accountId) async {
    final accountQuery = database.select(database.accounts)
      ..where((tbl) => tbl.id.equals(accountId));
    final account = await accountQuery.getSingleOrNull();
    return account?.name;
  }

  Future<String?> _getSourceAccountNameForTransfer(String transferId) async {
    final sourceTransactionQuery =
        database.select(database.transactions).join([
          leftOuterJoin(
            database.accounts,
            database.accounts.id.equalsExp(database.transactions.accountId),
          ),
        ])..where(
          database.transactions.transferId.equals(transferId) &
              database.transactions.transactionType.equals(
                FinancialType.expense.name,
              ),
        );

    final sourceResult = await sourceTransactionQuery.getSingleOrNull();
    if (sourceResult != null) {
      final sourceAccount = sourceResult.readTableOrNull(database.accounts);
      return sourceAccount?.name;
    }

    return null;
  }
}
