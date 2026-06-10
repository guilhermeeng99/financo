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
  TextColumn get recurrence => text().withDefault(const Constant('single'))();
  TextColumn get recurrenceGroupId => text().nullable()();
  IntColumn get recurrenceIntervalMonths =>
      integer().withDefault(const Constant(1))();
  IntColumn get recurrenceIndex => integer().nullable()();
  IntColumn get recurrenceTotal => integer().nullable()();
  TextColumn get recurrenceBaseDescription => text().nullable()();
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get linkedTransactionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
