import 'package:drift/drift.dart';

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get icon => integer()();
  IntColumn get color => integer()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}
