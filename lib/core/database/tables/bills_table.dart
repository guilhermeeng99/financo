import 'package:drift/drift.dart';

class LocalBills extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text().withDefault(const Constant('payable'))();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text()();
  TextColumn get recurrence => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  TextColumn get paidTransactionId => text().nullable()();
  TextColumn get parentBillId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
