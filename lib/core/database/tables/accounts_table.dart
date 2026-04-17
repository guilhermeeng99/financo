import 'package:drift/drift.dart';

class LocalAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get bank => text()();
  RealColumn get initialBalance => real()();
  RealColumn get creditLimit => real().nullable()();
  IntColumn get closingDay => integer().nullable()();
  IntColumn get dueDay => integer().nullable()();
  TextColumn get linkedAccountId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
