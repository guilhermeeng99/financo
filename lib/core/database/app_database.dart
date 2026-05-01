import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/bills_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/database/tables/accounts_table.dart';
import 'package:financo/core/database/tables/bills_table.dart';
import 'package:financo/core/database/tables/categories_table.dart';
import 'package:financo/core/database/tables/transactions_table.dart';
import 'package:financo/core/database/tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalUsers,
    LocalAccounts,
    LocalTransactions,
    LocalCategories,
    LocalBills,
  ],
  daos: [UsersDao, AccountsDao, TransactionsDao, CategoriesDao, BillsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Local cache is disposable — Firestore is the source of truth and the
  // sync service repopulates everything on next open. Any version mismatch
  // (upgrade or downgrade) just drops every table and recreates the schema.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
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
