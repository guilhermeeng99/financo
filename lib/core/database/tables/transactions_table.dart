import 'package:drift/drift.dart';

class LocalTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get accountId => text()();
  TextColumn get categoryId => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get settlementStatus =>
      text().withDefault(const Constant('paid'))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get settledAt => dateTime().nullable()();
  TextColumn get recurrence => text().withDefault(const Constant('oneShot'))();
  TextColumn get notes => text().nullable()();
  TextColumn get linkedTransactionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
