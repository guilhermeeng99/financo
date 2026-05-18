import 'package:drift/drift.dart';

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get icon => integer()();
  IntColumn get color => integer()();
  TextColumn get type => text()();
  TextColumn get parentId => text().nullable()();
  // Stored as `CategoryBucket.name` ('needs' / 'wants'). Nullable because
  // (a) only expense categories are classified, and (b) legacy categories
  // created before the 50/30/20 feature carry no value yet.
  TextColumn get bucket => text().nullable()();
  // Only meaningful on income categories. Defaults to true so legacy
  // rows (created before this column) keep feeding the 50/30/20 base
  // income when the schema is recreated.
  BoolColumn get countsInFiftyThirtyTwenty =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
