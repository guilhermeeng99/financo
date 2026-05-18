import 'package:drift/drift.dart';

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  // 50/30/20 custom targets. All three nullable as a group — either all
  // set (the user customised) or all null (use the classic default).
  // Stored as fractions of income (e.g. 0.5 for 50%).
  RealColumn get fiftyThirtyTwentyNeeds => real().nullable()();
  RealColumn get fiftyThirtyTwentyWants => real().nullable()();
  RealColumn get fiftyThirtyTwentySavings => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
