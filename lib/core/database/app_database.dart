import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/database/tables/accounts_table.dart';
import 'package:financo/core/database/tables/categories_table.dart';
import 'package:financo/core/database/tables/transactions_table.dart';
import 'package:financo/core/database/tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [LocalUsers, LocalAccounts, LocalTransactions, LocalCategories],
  daos: [UsersDao, AccountsDao, TransactionsDao, CategoriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE local_accounts RENAME COLUMN balance TO initial_balance',
        );
      }
      if (from < 3) {
        // Remove isDefault and sortOrder columns from local_categories.
        // Recreate the table since SQLite doesn't always support DROP COLUMN.
        await customStatement('DROP TABLE IF EXISTS local_categories');
        await migrator.createTable(localCategories);
      }
      if (from < 4) {
        // Remove isActive column from local_accounts.
        await customStatement('DROP TABLE IF EXISTS local_accounts');
        await migrator.createTable(localAccounts);
      }
      if (from < 5) {
        // Remove isReconciled, add linkedTransactionId to local_transactions.
        await customStatement('DROP TABLE IF EXISTS local_transactions');
        await migrator.createTable(localTransactions);
      }
      if (from < 6) {
        await customStatement(
          'ALTER TABLE local_categories ADD COLUMN parent_id TEXT',
        );
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'financo_local',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  Future<void> clearAllTables() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
