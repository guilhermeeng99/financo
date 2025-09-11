import 'dart:io';

import 'package:app_database/src/items/transaction/domain/index.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../core/financial_type.dart';
import '../items/account/domain/index.dart';
import '../items/category/domain/index.dart';

part 'database_manager.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions])
class DatabaseManager extends _$DatabaseManager {
  DatabaseManager() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Make description column nullable (SQLite workaround requires table rebuild; leaving as legacy comment)
          // Legacy step retained; actual change likely already applied in code generation.
        }
        if (from < 3) {
          // Apply category_id nullable + add transfer columns if missing
          // SQLite doesn't support altering a column to drop NOT NULL directly; need rebuild.
          // We'll rebuild the transactions table preserving data.
          await customStatement('PRAGMA foreign_keys=off');
          await customStatement('''
CREATE TABLE transactions_temp (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_type TEXT NOT NULL,
  actual_date INTEGER NOT NULL,
  competence_date INTEGER NOT NULL,
  amount REAL NOT NULL,
  description TEXT NULL,
  payment_status TEXT NOT NULL,
  recurrence_type TEXT NOT NULL,
  recurrence_frequency TEXT NULL,
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  category_id INTEGER NULL REFERENCES categories(id),
  target_account_id INTEGER NULL REFERENCES accounts(id),
  transfer_id TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);''');
          await customStatement('''
INSERT INTO transactions_temp (
  id, transaction_type, actual_date, competence_date, amount, description,
  payment_status, recurrence_type, recurrence_frequency, account_id,
  category_id, target_account_id, transfer_id, created_at, updated_at
)
SELECT id, transaction_type, actual_date, competence_date, amount, description,
  payment_status, recurrence_type, recurrence_frequency, account_id,
  category_id, target_account_id, transfer_id, created_at, updated_at
FROM transactions;''');
          await customStatement('DROP TABLE transactions');
          await customStatement(
            'ALTER TABLE transactions_temp RENAME TO transactions',
          );
          await customStatement('PRAGMA foreign_keys=on');
        }
        if (from < 4) {
          // Rebuild again to add DEFAULT constraints for created_at and updated_at
          await customStatement('PRAGMA foreign_keys=off');
          await customStatement('''
CREATE TABLE transactions_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_type TEXT NOT NULL,
  actual_date INTEGER NOT NULL,
  competence_date INTEGER NOT NULL,
  amount REAL NOT NULL,
  description TEXT NULL,
  payment_status TEXT NOT NULL,
  recurrence_type TEXT NOT NULL,
  recurrence_frequency TEXT NULL,
  account_id INTEGER NOT NULL REFERENCES accounts(id),
  category_id INTEGER NULL REFERENCES categories(id),
  target_account_id INTEGER NULL REFERENCES accounts(id),
  transfer_id TEXT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
);''');
          await customStatement('''
INSERT INTO transactions_new (
  id, transaction_type, actual_date, competence_date, amount, description,
  payment_status, recurrence_type, recurrence_frequency, account_id,
  category_id, target_account_id, transfer_id, created_at, updated_at
)
SELECT id, transaction_type, actual_date, competence_date, amount, description,
  payment_status, recurrence_type, recurrence_frequency, account_id,
  category_id, target_account_id, transfer_id,
  COALESCE(created_at, strftime('%s','now')),
  COALESCE(updated_at, strftime('%s','now'))
FROM transactions;''');
          await customStatement('DROP TABLE transactions');
          await customStatement(
            'ALTER TABLE transactions_new RENAME TO transactions',
          );
          await customStatement('PRAGMA foreign_keys=on');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      String? localPath;
      if (Platform.isWindows) {
        final appData = Platform.environment['LOCALAPPDATA'];
        if (appData != null) {
          localPath = p.join(appData, 'Financo');
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          localPath = p.join(home, '.local', 'share', 'financo');
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          localPath = p.join(home, 'Library', 'Application Support', 'Financo');
        }
      }

      if (localPath != null) {
        final dbDir = Directory(localPath);
        if (!dbDir.existsSync()) {
          dbDir.createSync(recursive: true);
        }
        final file = File(p.join(dbDir.path, 'financo_db.sqlite'));
        return NativeDatabase.createInBackground(file);
      }

      final currentDir = Directory.current;
      final dbDir = Directory(p.join(currentDir.path, 'data'));
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      final file = File(p.join(dbDir.path, 'financo_db.sqlite'));
      return NativeDatabase.createInBackground(file);
    } catch (e) {
      return NativeDatabase.memory();
    }
  });
}
