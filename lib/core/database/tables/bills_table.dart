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
  // Comma-separated transaction ids the user has rejected as a match for
  // this bill. Stored as a delimited string to keep the schema flat —
  // we never query into it, only round-trip the whole list.
  TextColumn get rejectedTransactionIds =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
