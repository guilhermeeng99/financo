import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';

import '../../../core/either.dart';
import '../../../core/failures.dart';
import '../../../database/database_manager.dart';

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

      // Build conditions
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
        query = query..where(conditions.reduce((a, b) => a & b));
      }

      // Apply ordering and pagination
      query = query
        ..orderBy([
          OrderingTerm(
            expression: database.transactions.competenceDate,
            mode: OrderingMode.desc,
          ),
          OrderingTerm(
            expression: database.transactions.createdAt,
            mode: OrderingMode.desc,
          ),
        ]);

      if (limit != null) {
        query = query..limit(limit, offset: offset);
      }

      final result = await query.get();

      final transactionsWithDetails = result.map((row) {
        final transaction = row.readTable(database.transactions);
        final account = row.readTableOrNull(database.accounts);
        final category = row.readTableOrNull(database.categories);

        return TransactionI(
          t: transaction,
          accountName: account?.name ?? 'Unknown Account',
          categoryName: category?.name ?? 'Unknown Category',
        );
      }).toList();

      return Either.right(transactionsWithDetails);
    } catch (e) {
      return Either.left(
        DatabaseFailure('Error getting transactions with details: $e'),
      );
    }
  }
}
