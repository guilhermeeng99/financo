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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Make description column nullable
          await customStatement(
            'ALTER TABLE transactions ALTER COLUMN description DROP NOT NULL',
          );
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
