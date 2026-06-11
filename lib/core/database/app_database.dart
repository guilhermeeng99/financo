import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:financo/core/database/daos/accounts_dao.dart';
import 'package:financo/core/database/daos/asset_classes_dao.dart';
import 'package:financo/core/database/daos/asset_holdings_dao.dart';
import 'package:financo/core/database/daos/budgets_dao.dart';
import 'package:financo/core/database/daos/categories_dao.dart';
import 'package:financo/core/database/daos/transactions_dao.dart';
import 'package:financo/core/database/daos/users_dao.dart';
import 'package:financo/core/database/tables/accounts_table.dart';
import 'package:financo/core/database/tables/asset_classes_table.dart';
import 'package:financo/core/database/tables/asset_holdings_table.dart';
import 'package:financo/core/database/tables/budgets_table.dart';
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
    LocalBudgets,
    LocalAssetClasses,
    LocalAssetHoldings,
  ],
  daos: [
    UsersDao,
    AccountsDao,
    TransactionsDao,
    CategoriesDao,
    BudgetsDao,
    AssetClassesDao,
    AssetHoldingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  // Local cache is disposable — Firestore is the source of truth and the
  // sync service repopulates everything on next open. Any version mismatch
  // (upgrade or downgrade) just drops every table and recreates the schema.
  //
  // `beforeOpen` runs every open and self-heals schema drift: on web,
  // drift's shared-worker can keep a stale connection across hot-
  // restarts, occasionally skipping `onUpgrade`. We re-create the
  // tables when a column is missing so the user doesn't need to wipe
  // browser storage manually.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      await customStatement('DROP TABLE IF EXISTS local_bills');
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('DROP TABLE IF EXISTS local_bills');
      if (!details.wasCreated && details.hadUpgrade) return;
      // Belt-and-braces sweep: if any registered table is missing a
      // column the generated schema expects, drop + recreate it. A
      // dropped table re-syncs from Firestore on next read.
      for (final table in allTables) {
        await _ensureSchemaForTable(table);
      }
    },
  );

  Future<void> _ensureSchemaForTable(TableInfo<Table, dynamic> table) async {
    final result = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    if (result.isEmpty) {
      await createMigrator().createTable(table);
      return;
    }
    final existing = result
        .map((row) => row.data['name'] as String?)
        .whereType<String>()
        .toSet();
    final expected = table.$columns.map((c) => c.$name).toSet();
    final missing = expected.difference(existing);
    if (missing.isEmpty) return;
    final m = createMigrator();
    await m.deleteTable(table.actualTableName);
    await m.createTable(table);
  }

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
